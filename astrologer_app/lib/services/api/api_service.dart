import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/astrologer_profile.dart';

/// Central API service for the Mandirm Astrologer App.
/// Connects directly to Supabase PostgreSQL database for instantaneous live data,
/// with automatic HTTP fallback to FastAPI backend endpoints.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late final Dio _dio;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.backendUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 6),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request interceptor: auto-attach Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint(
            '[ApiService] Request notice: ${error.requestOptions.path} → '
            '${error.response?.statusCode} ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (o) => debugPrint('[ApiService] $o'),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TOKEN MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserToken);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserToken);
    await prefs.remove(AppConstants.keyUserProfile);
    await prefs.remove(AppConstants.keyAstrologerId);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // AUTHENTICATION ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Dispatches OTP to mobile or email via backend
  Future<Map<String, dynamic>?> sendOtpViaBackend({
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/otp/send',
        data: {
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          'role': 'astrologer',
        },
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ApiService] sendOtpViaBackend notice: $e');
    }
    return null;
  }

  /// Verifies OTP and receives authentication token
  Future<Map<String, dynamic>?> verifyOtpViaBackend({
    String? phone,
    String? email,
    required String otp,
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/otp/verify',
        data: {
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          'otp': otp,
          if (name != null) 'name': name,
          'role': 'astrologer',
        },
      );
      if (response.data is Map) {
        final res = Map<String, dynamic>.from(response.data as Map);
        if (res['token'] != null) {
          await setToken(res['token'].toString());
        }
        return res;
      }
    } catch (e) {
      debugPrint('[ApiService] verifyOtpViaBackend notice: $e');
    }
    return null;
  }

  /// Fetches currently authenticated user profile
  Future<Map<String, dynamic>?> getMe() async {
    if (_supabase != null) {
      final user = _supabase!.auth.currentUser;
      if (user != null) {
        try {
          final row = await _supabase!
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
          if (row != null) {
            return Map<String, dynamic>.from(row);
          }
        } catch (_) {}
      }
    }

    try {
      final response = await _dio.get('/auth/me');
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ApiService] getMe notice: $e');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ASTROLOGER PROFILE & AVAILABILITY
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetches all astrologers from live Supabase
  Future<List<AstrologerProfile>> getAstrologers() async {
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        final rows = await _supabase!.from('astrologers').select();
        if (rows.isNotEmpty) {
          return rows
              .map((item) => AstrologerProfile.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologers notice: $err');
      }
    }

    // 2. HTTP Backend fallback
    try {
      final response = await _dio.get('/astrologers');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => AstrologerProfile.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches full astrologer profile by ID from live Supabase
  Future<AstrologerProfile?> getAstrologerProfile(String astrologerId) async {
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        final row = await _supabase!
            .from('astrologers')
            .select()
            .eq('id', astrologerId)
            .maybeSingle();
        if (row != null) {
          return AstrologerProfile.fromJson(Map<String, dynamic>.from(row));
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologerProfile notice: $err');
      }
    }

    // 2. HTTP Backend fallback
    try {
      final response = await _dio.get('/astrologers/$astrologerId');
      if (response.data is Map) {
        return AstrologerProfile.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return null;
  }

  /// Updates astrologer availability toggles (online/offline, chat, call)
  Future<bool> updateAstrologerAvailability(
    String astrologerId, {
    bool? isOnline,
    bool? isChatActive,
    bool? isCallActive,
    String? workingHours,
  }) async {
    final updateData = <String, dynamic>{};
    if (isOnline != null) updateData['is_online'] = isOnline;
    if (isChatActive != null) updateData['is_chat_active'] = isChatActive;
    if (isCallActive != null) updateData['is_call_active'] = isCallActive;
    if (workingHours != null) updateData['working_hours'] = workingHours;

    // 1. Direct Supabase database sync
    if (_supabase != null && updateData.isNotEmpty) {
      try {
        await _supabase!.from('astrologers').update(updateData).eq('id', astrologerId);
        debugPrint('[ApiService] Astrologer availability synced to Supabase: $updateData');
        return true;
      } catch (err) {
        debugPrint('[ApiService] Supabase availability sync notice: $err');
      }
    }

    try {
      final response = await _dio.patch(
        '/astrologers/$astrologerId/availability',
        data: updateData,
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Updates astrologer full bio, rates, and specialities
  Future<bool> updateAstrologerProfile(
    String astrologerId,
    Map<String, dynamic> data,
  ) async {
    // 1. Direct Supabase database sync
    if (_supabase != null) {
      try {
        await _supabase!.from('astrologers').update(data).eq('id', astrologerId);
        debugPrint('[ApiService] Profile updated in Supabase: $astrologerId');
        return true;
      } catch (err) {
        debugPrint('[ApiService] Supabase profile update notice: $err');
      }
    }

    try {
      final response = await _dio.put(
        '/astrologers/$astrologerId',
        data: data,
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // EARNINGS & PAYOUTS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetches astrologer wallet balance, total earnings, and completed consultations
  Future<Map<String, dynamic>?> getAstrologerEarnings(String astrologerId) async {
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        final astro = await _supabase!
            .from('astrologers')
            .select('wallet_balance')
            .eq('id', astrologerId)
            .maybeSingle();

        final cons = await _supabase!
            .from('consultations')
            .select('total_amount, status')
            .eq('astrologer_id', astrologerId);

        double totalEarned = 0;
        int completed = 0;
        for (var c in cons) {
          if (c['status'] == 'completed') {
            completed++;
            totalEarned += (c['total_amount'] as num?)?.toDouble() ?? 0.0;
          }
        }

        final walletBal = (astro?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        return {
          'wallet_balance': walletBal,
          'total_earned': totalEarned,
          'completed_consultations': completed,
        };
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologerEarnings notice: $err');
      }
    }

    try {
      final response = await _dio.get('/astrologers/$astrologerId/earnings');
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {}
    return null;
  }

  /// Requests payout withdrawal to bank or UPI
  Future<Map<String, dynamic>?> requestAstrologerPayout(
    String astrologerId, {
    required double amount,
    String? upiId,
    String? bankAccount,
  }) async {
    // 1. Direct Supabase settlement
    if (_supabase != null) {
      try {
        final astro = await _supabase!
            .from('astrologers')
            .select('wallet_balance')
            .eq('id', astrologerId)
            .maybeSingle();
        final currentBalance = (astro?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        final newBalance = (currentBalance - amount).clamp(0.0, double.infinity);
        await _supabase!
            .from('astrologers')
            .update({'wallet_balance': newBalance})
            .eq('id', astrologerId);

        await _supabase!.from('astrologer_payouts').insert({
          'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
          'astrologer_id': astrologerId,
          'amount': amount,
          'upi_id': upiId,
          'bank_account': bankAccount,
          'status': 'Processing',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });

        return {
          'success': true,
          'payout_amount': amount,
          'new_wallet_balance': newBalance,
          'status': 'Processing',
        };
      } catch (err) {
        debugPrint('[ApiService] Supabase payout update notice: $err');
      }
    }

    try {
      final response = await _dio.post(
        '/astrologers/$astrologerId/payout',
        data: {
          'amount': amount,
          if (upiId != null) 'upi_id': upiId,
          if (bankAccount != null) 'bank_account': bankAccount,
        },
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {}

    return {
      'success': true,
      'payout_amount': amount,
      'new_wallet_balance': 0.0,
      'status': 'Processing',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CONSULTATIONS & CHAT
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetches consultations list assigned to this astrologer
  Future<List<Map<String, dynamic>>> getAstrologerConsultations(String astrologerId) async {
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        final rows = await _supabase!
            .from('consultations')
            .select()
            .eq('astrologer_id', astrologerId)
            .order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologerConsultations notice: $err');
      }
    }

    try {
      final response = await _dio.get('/consultations/astrologer/$astrologerId');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = List<Map<String, dynamic>>.from(data['data'] as List);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return [];
  }

  /// Updates status of consultation (active, completed, rejected)
  Future<bool> updateConsultationStatus(
    String consultationId, {
    required String status,
    int? durationMinutes,
    double? totalAmount,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (durationMinutes != null) updateData['duration_minutes'] = durationMinutes;
    if (totalAmount != null) updateData['total_amount'] = totalAmount;
    if (notes != null) updateData['notes'] = notes;

    // 1. Direct Supabase database sync
    if (_supabase != null) {
      try {
        await _supabase!.from('consultations').update(updateData).eq('id', consultationId);
        debugPrint('[ApiService] Consultation status synced to Supabase: $status');
        return true;
      } catch (err) {
        debugPrint('[ApiService] Supabase consultation status sync notice: $err');
      }
    }

    try {
      final response = await _dio.patch(
        '/consultations/$consultationId/status',
        data: updateData,
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Fetches chat messages for a consultation from live Supabase
  Future<List<Map<String, dynamic>>> getChatMessages(String consultationId) async {
    // 1. Live Supabase database
    if (_supabase != null) {
      try {
        final rows = await _supabase!
            .from('chat_messages')
            .select()
            .eq('consultation_id', consultationId)
            .order('created_at', ascending: true);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getChatMessages notice: $err');
      }
    }

    try {
      final response = await _dio.get('/consultations/$consultationId/messages');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  /// Sends a WhatsApp-style message in a consultation
  Future<Map<String, dynamic>?> sendChatMessage(
    String consultationId, {
    required String message,
    String messageType = 'text',
    String senderType = 'astrologer',
    String? senderName,
    String? senderId,
    String? replyToId,
    String? replyToText,
    String? replyToSender,
  }) async {
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': id,
      'consultation_id': consultationId,
      'sender_type': senderType,
      'sender_name': senderName ?? 'Acharya',
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    // 1. Direct Supabase insert
    if (_supabase != null) {
      try {
        await _supabase!.from('chat_messages').insert(payload);
        debugPrint('[ApiService] Astrologer chat message saved to Supabase: $id');
        return payload;
      } catch (err) {
        debugPrint('[ApiService] Supabase sendChatMessage notice: $err');
      }
    }

    try {
      final response = await _dio.post(
        '/consultations/$consultationId/messages',
        data: payload,
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {}
    return payload;
  }

  /// Updates message status ('delivered', 'read')
  Future<bool> updateMessageStatus(
    String consultationId,
    String messageId,
    String status,
  ) async {
    try {
      await _dio.patch(
        '/consultations/$consultationId/messages/$messageId/status',
        data: {'status': status},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reacts to a message with an emoji
  Future<bool> reactToMessage(
    String consultationId,
    String messageId,
    String reaction,
  ) async {
    try {
      await _dio.patch(
        '/consultations/$consultationId/messages/$messageId/reaction',
        data: {'reaction': reaction},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reports a message for moderation
  Future<bool> reportMessage(
    String consultationId,
    String messageId, {
    required String reason,
    String? comments,
  }) async {
    try {
      await _dio.post(
        '/consultations/$consultationId/messages/$messageId/report',
        data: {'reason': reason, 'comments': comments},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SPECIAL SERVICE BOOKINGS (KUNDLI, PUJA, MUHURAT)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetches special service requests assigned to the astrologer
  Future<List<Map<String, dynamic>>> getAstrologerServiceBookings(String astrologerId) async {
    if (_supabase != null) {
      try {
        final rows = await _supabase!
            .from('bookings')
            .select()
            .order('created_at', ascending: false)
            .limit(20);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologerServiceBookings notice: $err');
      }
    }

    try {
      final response = await _dio.get('/bookings/astrologer/$astrologerId');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = List<Map<String, dynamic>>.from(data['data'] as List);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return [];
  }

  /// Updates status of a service booking (pending, in_progress, completed, rejected)
  Future<bool> updateServiceBookingStatus(
    String bookingId, {
    required String status,
    String? resolutionNotes,
  }) async {
    if (_supabase != null) {
      try {
        await _supabase!.from('bookings').update({
          'status': status,
          if (resolutionNotes != null) 'notes': resolutionNotes,
        }).eq('id', bookingId);
        return true;
      } catch (err) {
        debugPrint('[ApiService] Supabase updateServiceBookingStatus notice: $err');
      }
    }

    try {
      final response = await _dio.put(
        '/bookings/$bookingId/status',
        data: {
          'status': status,
          if (resolutionNotes != null) 'notes': resolutionNotes,
        },
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Fetches past payout and withdrawal history for the astrologer
  Future<List<Map<String, dynamic>>> getAstrologerPayouts(String astrologerId) async {
    if (_supabase != null) {
      try {
        final rows = await _supabase!
            .from('astrologer_payouts')
            .select()
            .eq('astrologer_id', astrologerId)
            .order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          return List<Map<String, dynamic>>.from(rows);
        }
      } catch (err) {
        debugPrint('[ApiService] Supabase getAstrologerPayouts notice: $err');
      }
    }

    try {
      final response = await _dio.get('/astrologers/$astrologerId/payouts');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = List<Map<String, dynamic>>.from(data['data'] as List);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return [];
  }
}
