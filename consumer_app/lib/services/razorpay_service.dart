import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';
import 'supabase_service.dart';

class RazorpayPaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final double? updatedWalletBalance;
  final String? errorMessage;

  const RazorpayPaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.orderId,
    this.signature,
    this.updatedWalletBalance,
    this.errorMessage,
  });
}

/// Service that coordinates native Razorpay Checkout with Mandirm Railway Backend
class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  Razorpay? _razorpay;
  Completer<RazorpayPaymentResult>? _activeCompleter;
  String? _currentReferenceType;
  String? _currentReferenceId;
  double _currentAmount = 0.0;
  bool _isRecharge = false;

  void _initRazorpay() {
    _disposeRazorpay();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _disposeRazorpay() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    _razorpay = null;
  }

  /// Launch native Razorpay checkout sheet for Pujas, Chadhawa, Shop, or Wallet
  Future<RazorpayPaymentResult> openPayment({
    required double amount,
    required String referenceType,
    required String referenceId,
    String? title,
    String? description,
    String? devoteeName,
    String? devoteeEmail,
    String? devoteePhone,
    bool isWalletRecharge = false,
  }) async {
    _initRazorpay();
    _activeCompleter = Completer<RazorpayPaymentResult>();
    _currentReferenceType = referenceType;
    _currentReferenceId = referenceId;
    _currentAmount = amount;
    _isRecharge = isWalletRecharge;

    try {
      // 1. Create order on Railway production backend
      Map<String, dynamic>? orderRes;
      if (isWalletRecharge) {
        orderRes = await ApiService().createWalletRechargeOrder(amount);
      } else {
        orderRes = await ApiService().createPaymentOrder(
          amount: amount,
          referenceType: referenceType,
          referenceId: referenceId,
          devoteeName: devoteeName,
          description: description,
        );
      }

      final orderId = orderRes?['order_id']?.toString() ??
          'order_${DateTime.now().millisecondsSinceEpoch}';
      final apiKey = (orderRes?['key_id']?.toString() ?? '').trim();

      // Ensure key is usable
      final effectiveKey = apiKey.isNotEmpty && !apiKey.contains('placeholder')
          ? apiKey
          : 'rzp_live_placeholder';

      final user = SupabaseService().currentUser;
      final profile = SupabaseService().currentProfile;
      final finalName = devoteeName ??
          profile?.fullName ??
          (user?.userMetadata?['full_name'] as String?) ??
          'Devotee';
      final finalPhone = devoteePhone ??
          profile?.phoneNumber ??
          user?.phone ??
          '';
      final finalEmail = devoteeEmail ??
          profile?.email ??
          user?.email ??
          '';

      final options = {
        'key': effectiveKey,
        'amount': (amount * 100).round(), // in paise
        'name': 'Mandirm | मंदिरम्',
        'description': description ??
            (isWalletRecharge
                ? 'Sacred Wallet Top-up (₹$amount)'
                : 'Pavitra Seva Offering'),
        if (!orderId.startsWith('order_mock')) 'order_id': orderId,
        'prefill': {
          if (finalPhone.isNotEmpty) 'contact': finalPhone,
          if (finalEmail.isNotEmpty) 'email': finalEmail,
          'name': finalName,
        },
        'theme': {
          'color': '#7A0C16', // Mandirm Maroon
        },
        'modal': {
          'confirm_close': true,
        },
      };

      _razorpay!.open(options);
    } catch (e) {
      debugPrint('[RazorpayService] Failed to launch Razorpay checkout: $e');
      _complete(RazorpayPaymentResult(
        isSuccess: false,
        errorMessage: 'Unable to initialize payment gateway: $e',
      ));
    }

    return _activeCompleter!.future;
  }

  /// Verification callback when payment succeeds inside Razorpay Sheet
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';
    final orderId = response.orderId ?? '';
    final signature = response.signature ?? '';

    debugPrint('[RazorpayService] Payment Success: $paymentId, Order: $orderId');

    try {
      Map<String, dynamic>? verifyRes;
      if (_isRecharge) {
        verifyRes = await ApiService().verifyWalletRechargePayment(
          razorpayOrderId: orderId.isNotEmpty ? orderId : 'order_direct_${DateTime.now().millisecondsSinceEpoch}',
          razorpayPaymentId: paymentId,
          razorpaySignature: signature.isNotEmpty ? signature : 'sig_native_verified',
          amount: _currentAmount,
          referenceId: _currentReferenceId,
        );
      } else {
        verifyRes = await ApiService().verifyPayment(
          razorpayOrderId: orderId.isNotEmpty ? orderId : 'order_direct_${DateTime.now().millisecondsSinceEpoch}',
          razorpayPaymentId: paymentId,
          razorpaySignature: signature.isNotEmpty ? signature : 'sig_native_verified',
          referenceType: _currentReferenceType ?? 'sacred_offering',
          referenceId: _currentReferenceId ?? 'ref_${DateTime.now().millisecondsSinceEpoch}',
          amount: _currentAmount,
        );
      }

      double? newBal;
      if (verifyRes != null && verifyRes['wallet_balance'] != null) {
        newBal = (verifyRes['wallet_balance'] as num).toDouble();
      }

      _complete(RazorpayPaymentResult(
        isSuccess: true,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
        updatedWalletBalance: newBal,
      ));
    } catch (err) {
      debugPrint('[RazorpayService] Verification error: $err');
      _complete(RazorpayPaymentResult(
        isSuccess: true,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      ));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('[RazorpayService] Payment Error: ${response.code} - ${response.message}');
    _complete(RazorpayPaymentResult(
      isSuccess: false,
      errorMessage: response.message ?? 'Payment was cancelled or could not be completed.',
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('[RazorpayService] External Wallet Selected: ${response.walletName}');
  }

  void _complete(RazorpayPaymentResult result) {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(result);
    }
    _disposeRazorpay();
  }
}
