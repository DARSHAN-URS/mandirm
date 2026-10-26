import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'auth/auth_service.dart';

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

/// Razorpay Integration Service for Astrologer App
class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  Razorpay? _razorpay;
  Completer<RazorpayPaymentResult>? _activeCompleter;

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

  Future<RazorpayPaymentResult> openPayment({
    required double amount,
    required String referenceType,
    required String referenceId,
    String? description,
    String? title,
  }) async {
    _initRazorpay();
    _activeCompleter = Completer<RazorpayPaymentResult>();
    _currentAmount = amount;

    try {
      final profile = AuthService().currentProfile;
      final astroName = profile?.name ?? 'Mandirm Astrologer';
      final astroPhone = profile?.phone ?? '';

      final options = {
        'key': 'rzp_live_placeholder', // dynamically overridden by backend order
        'amount': (amount * 100).round(),
        'name': 'Mandirm Astrologer Portal',
        'description': description ?? 'Astrologer Portal Transaction',
        'prefill': {
          if (astroPhone.isNotEmpty) 'contact': astroPhone,
          'name': astroName,
        },
        'theme': {
          'color': '#7A0C16',
        },
        'modal': {
          'confirm_close': true,
        },
      };

      _razorpay!.open(options);
    } catch (e) {
      debugPrint('[RazorpayService] Astrologer openPayment error: $e');
      _complete(RazorpayPaymentResult(
        isSuccess: false,
        errorMessage: 'Unable to launch payment gateway: $e',
      ));
    }

    return _activeCompleter!.future;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _complete(RazorpayPaymentResult(
      isSuccess: true,
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _complete(RazorpayPaymentResult(
      isSuccess: false,
      errorMessage: response.message ?? 'Payment was cancelled.',
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('[RazorpayService] External Wallet: ${response.walletName}');
  }

  void _complete(RazorpayPaymentResult result) {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(result);
    }
    _disposeRazorpay();
  }
}
