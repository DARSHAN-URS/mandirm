import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth/auth_service.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../home/screens/main_hub_screen.dart';

class AstrologerOtpScreen extends StatefulWidget {
  final String target;
  final bool isPhone;

  const AstrologerOtpScreen({
    super.key,
    required this.target,
    this.isPhone = false,
  });

  @override
  State<AstrologerOtpScreen> createState() => _AstrologerOtpScreenState();
}

class _AstrologerOtpScreenState extends State<AstrologerOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 30;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() async {
    _startTimer();
    try {
      await AuthService().sendOtp(
        target: widget.target,
        isPhone: widget.isPhone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A fresh verification code has been dispatched to your email.'),
          backgroundColor: AppColors.statusOnline,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.statusOffline,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _verifyOtp() async {
    final otp = _enteredOtp.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter full 6-digit verification code.'),
          backgroundColor: AppColors.statusOffline,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profile = await AuthService().verifyOtp(
        target: widget.target,
        isPhone: widget.isPhone,
        otp: otp,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome ${profile.name}! Acharya session authenticated.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.statusOnline,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.statusOffline,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header with Back button
          const MandirmHeader(
            showBackButton: true,
            showNotification: false,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Shield Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.warmCream,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepAmber.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: AppColors.primaryMaroon,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Enter Verification Code',
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit verification code to your email\n${widget.target}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 6 OTP Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 46,
                        height: 56,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryMaroon,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.lightBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.lightBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryMaroon,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (_enteredOtp.length == 6) {
                              _verifyOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Verify & Proceed to Live Hub',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _countdown > 0
                            ? 'Resend code in ${_countdown}s'
                            : 'Didn’t receive the code?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_countdown == 0)
                        TextButton(
                          onPressed: _resendCode,
                          child: Text(
                            'Resend Code',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryMaroon,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
