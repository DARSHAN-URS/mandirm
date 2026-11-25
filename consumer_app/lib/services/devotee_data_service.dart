import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DevoteeDataService {
  static final DevoteeDataService _instance = DevoteeDataService._internal();
  factory DevoteeDataService() => _instance;
  DevoteeDataService._internal() {
    loadBirthDetails();
    refreshWalletBalance();
  }

  static const String keyDevoteeBirthDetails = 'mandirm_devotee_birth_details';

  final List<Map<String, dynamic>> _bookings = [];
  final List<Map<String, dynamic>> _consultations = [];
  final List<Map<String, dynamic>> _prasadOrders = [];

  Map<String, dynamic>? _birthDetails;
  final ValueNotifier<double> walletBalanceNotifier = ValueNotifier<double>(0.0);

  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);
  List<Map<String, dynamic>> get consultations => List.unmodifiable(_consultations);
  List<Map<String, dynamic>> get prasadOrders => List.unmodifiable(_prasadOrders);

  bool get hasBirthDetails =>
      _birthDetails != null &&
      (_birthDetails!['name']?.toString().trim().isNotEmpty ?? false);

  Map<String, dynamic>? get birthDetails => _birthDetails;

  /// Load devotee birth details saved from SharedPreferences (asked once)
  Future<Map<String, dynamic>?> loadBirthDetails() async {
    if (_birthDetails != null) return _birthDetails;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyDevoteeBirthDetails);
      if (raw != null && raw.isNotEmpty) {
        _birthDetails = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        return _birthDetails;
      }
    } catch (e) {
      debugPrint('[DevoteeDataService] loadBirthDetails error: $e');
    }
    return null;
  }

  /// Save devotee birth details permanently so they are never asked again
  Future<void> saveBirthDetails(Map<String, dynamic> details) async {
    _birthDetails = Map<String, dynamic>.from(details);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyDevoteeBirthDetails, jsonEncode(details));
      debugPrint('[DevoteeDataService] Birth details saved: ${details['name']}');
    } catch (e) {
      debugPrint('[DevoteeDataService] saveBirthDetails error: $e');
    }
  }

  /// Fetch live wallet balance from backend and update notifier
  Future<double> refreshWalletBalance() async {
    try {
      final overview = await ApiService().getWalletOverview();
      if (overview != null && overview.containsKey('balance')) {
        final bal = (overview['balance'] as num?)?.toDouble() ?? 0.0;
        walletBalanceNotifier.value = bal;
        return bal;
      }
    } catch (e) {
      debugPrint('[DevoteeDataService] refreshWalletBalance error: $e');
    }
    return walletBalanceNotifier.value;
  }

  /// Deduct per-minute rate from Sacred Wallet
  Future<bool> deductChatMinute({
    required double amount,
    required String astrologerName,
    required String consultationId,
  }) async {
    // Optimistically deduct locally
    final currentBal = walletBalanceNotifier.value;
    if (currentBal < amount) return false;

    final newBal = (currentBal - amount).clamp(0.0, double.infinity);
    walletBalanceNotifier.value = newBal;

    try {
      final res = await ApiService().deductWalletBalance(
        amount: amount,
        referenceType: 'astrologer_chat',
        referenceId: consultationId,
        description: '1 min chat consultation with $astrologerName',
      );
      if (res != null && res['wallet_balance'] != null) {
        walletBalanceNotifier.value = (res['wallet_balance'] as num).toDouble();
        return true;
      }
    } catch (e) {
      debugPrint('[DevoteeDataService] deductChatMinute backend sync notice: $e');
    }
    return true;
  }

  void addBooking(Map<String, dynamic> booking) {
    // Avoid duplicate booking ID
    _bookings.removeWhere((b) => b['id'] == booking['id']);
    _bookings.insert(0, booking);
  }

  void addConsultation(Map<String, dynamic> consultation) {
    _consultations.removeWhere((c) => c['id'] == consultation['id']);
    _consultations.insert(0, consultation);
  }

  void addPrasadOrder(Map<String, dynamic> order) {
    _prasadOrders.removeWhere((o) => o['id'] == order['id']);
    _prasadOrders.insert(0, order);
  }

  void syncBackendBookings(List<Map<String, dynamic>> backendList) {
    for (final b in backendList) {
      final id = b['id']?.toString() ?? 'BK-${b.hashCode}';
      if (!_bookings.any((item) => item['id'] == id)) {
        _bookings.add({
          'id': id,
          'title': b['puja_name'] ?? b['title'] ?? 'Vedic Puja Ritual',
          'mandir': b['temple_name'] ?? b['mandir'] ?? 'Sacred Temple Sanctum',
          'date': b['date'] ?? 'Scheduled',
          'amount': '₹${b['amount'] ?? 1100}',
          'status': b['status'] ?? 'Confirmed',
          'gotra': b['gotra'] ?? 'Devotee Gotra',
          'devoteeName': b['devotee_name'] ?? 'Devotee',
          'pandit': b['pandit_name'] ?? 'Verified Mandirm Acharya',
          'prasadTracking': b['tracking_id'] ?? 'IN${DateTime.now().millisecondsSinceEpoch % 10000000}POST',
          'prasadStatus': b['prasad_status'] ?? 'In Preparation',
        });
      }
    }
  }

  void syncBackendConsultations(List<Map<String, dynamic>> backendList) {
    for (final c in backendList) {
      final id = c['id']?.toString() ?? 'CNS-${c.hashCode}';
      if (!_consultations.any((item) => item['id'] == id)) {
        _consultations.add({
          'id': id,
          'astrologerName': c['astrologer_name'] ?? 'Vedic Astrologer',
          'specialty': c['specialty'] ?? 'Vedic • Kundali',
          'date': c['date'] ?? 'Recent Session',
          'duration': '${c['duration_minutes'] ?? 15} mins',
          'amount': 'Free Sacred Consultation',
          'remedy': c['notes'] ?? c['remedy'] ?? 'Chant Gayatri Mantra daily for peace and clarity.',
          'rating': (c['rating'] as num?)?.toDouble() ?? 5.0,
        });
      }
    }
  }

  void syncBackendOrders(List<Map<String, dynamic>> backendList) {
    for (final o in backendList) {
      final id = o['id']?.toString() ?? 'ORD-${o.hashCode}';
      if (!_prasadOrders.any((item) => item['id'] == id)) {
        _prasadOrders.add({
          'id': id,
          'title': o['item_name'] ?? o['title'] ?? 'Sacred Item',
          'mandir': o['source_temple'] ?? o['mandir'] ?? 'Mandirm Divine Store',
          'orderDate': o['order_date'] ?? 'Recent',
          'status': o['status'] ?? 'In Transit',
          'currentStep': (o['step'] as int?) ?? 1,
          'trackingNumber': o['tracking_no'] ?? 'BLUEDART-${DateTime.now().millisecondsSinceEpoch % 1000000}',
          'carrier': o['carrier'] ?? 'BlueDart Express',
          'expectedDelivery': o['delivery_eta'] ?? 'In 2-3 Days',
          'address': o['address'] ?? 'Home Address',
        });
      }
    }
  }
}
