import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_service.dart';
import '../../common/widgets/mandirm_header.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  bool _isPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-+]'), '');
    return RegExp(r'^[0-9]{10,12}$').hasMatch(cleaned);
  }

  void _onSendOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final identifier = _identifierController.text.trim();
    if (_isPhoneNumber(identifier)) {
      context.read<AuthBloc>().add(SendPhoneOtpEvent(identifier));
    } else {
      context.read<AuthBloc>().add(SendEmailOtpEvent(identifier));
    }
  }

  void _onContinueWithGoogle() {
    context.read<AuthBloc>().add(const SignInWithGoogleEvent());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          final isCurrentRoute =
              GoRouterState.of(context).matchedLocation == '/login';
          if (state is AuthOtpSent) {
            if (isCurrentRoute) {
              context.push(
                '/otp-verify',
                extra: {
                  'target': state.target,
                  'isPhone': state.isPhone,
                },
              );
            }
          } else if (state is AuthProfileRequired) {
            if (isCurrentRoute) {
              context.go('/profile-setup');
            }
          } else if (state is AuthAuthenticated) {
            if (isCurrentRoute) {
              context.go('/home');
            }
          } else if (state is AuthError) {
            if (isCurrentRoute) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.message,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF8B1E1E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isGoogleLoading = state is AuthLoading &&
              (state.message?.toLowerCase().contains('google') ?? false);
          // Only show send-OTP button loading if an OTP is actively being dispatched
          final isOtpLoading = state is AuthLoading &&
              (state.message?.toLowerCase().contains('sending') ?? false);
          final isAnyLoading = isGoogleLoading || isOtpLoading;

          return Scaffold(
            backgroundColor: const Color(0xFF1E0703),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Column(
                  children: [
                    // 1. Top Section: Temple Artwork with Lotus Emblem, Mandiram Title & Feature Cards
                    SizedBox(
                      width: double.infinity,
                      height: math.max(340.0, screenHeight * 0.44),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Devotional Header Artwork Image
                          Image.asset(
                            AppConstants.loginTopHeaderAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                AppConstants.splashBackgroundAsset,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              );
                            },
                          ),

                          // Top Bar with Language Toggle Button
                          Positioned(
                            top: mediaQuery.padding.top + 8,
                            right: 16,
                            child: const LanguageToggleButton(),
                          ),
                        ],
                      ),
                    ),

                    // 2. Bottom Section: Elevated Sign In Ivory Card with Ornamental Crest & Mandalas
                    Transform.translate(
                      offset: const Offset(0, -18),
                      child: _buildSignInCard(
                        context: context,
                        isGoogleLoading: isGoogleLoading,
                        isOtpLoading: isOtpLoading,
                        isAnyLoading: isAnyLoading,
                        screenWidth: screenWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInCard({
    required BuildContext context,
    required bool isGoogleLoading,
    required bool isOtpLoading,
    required bool isAnyLoading,
    required double screenWidth,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: const Color(0xFFEFE5D5),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corner Decorative Mandalas
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: CustomPaint(
                painter: _CornerMandalaPainter(),
              ),
            ),
          ),

          // Little Golden Lotus Crest Tab at Top Center
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 54,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border.all(
                    color: const Color(0xFFE2D0AF),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.spa_outlined,
                    size: 19,
                    color: Color(0xFFC5983A),
                  ),
                ),
              ),
            ),
          ),

          // Main Card Form Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title: "Sign In / Register"
                  Center(
                    child: Text(
                      LocaleService().isHindi ? 'लॉग इन / पंजीकरण' : 'Sign In / Register',
                      style: GoogleFonts.cinzel(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B1118),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Center(
                    child: Text(
                      LocaleService().isHindi
                          ? 'सत्यापन OTP प्राप्त करने के लिए अपना ईमेल या मोबाइल दर्ज करें'
                          : 'Enter your Email or Mobile to receive a verification OTP',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6560),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email ID / Mobile Number Field
                  _buildInputField(
                    controller: _identifierController,
                    hintText: LocaleService().isHindi
                        ? 'ईमेल पता या मोबाइल नंबर'
                        : 'Email Address / Mobile Number',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleService().isHindi
                            ? 'कृपया ईमेल पता या मोबाइल नंबर दर्ज करें'
                            : 'Please enter your Email or Mobile Number';
                      }
                      final trimmed = value.trim();
                      if (_isPhoneNumber(trimmed)) {
                        return null; // Valid phone format
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(trimmed)) {
                        return LocaleService().isHindi
                            ? 'कृपया एक मान्य ईमेल आईडी या 10-अंकों का नंबर दर्ज करें'
                            : 'Please enter a valid email or 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Send OTP Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isAnyLoading ? null : _onSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A0C16),
                        disabledBackgroundColor:
                            const Color(0xFF7A0C16).withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isOtpLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleService().isHindi ? 'OTP प्राप्त करें' : 'Send Sacred OTP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE5DDD0),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          AppStrings.t('or_divider'),
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8C8278),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE5DDD0),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Continue with Google Button
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0D6C4),
                        width: 1.1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isAnyLoading ? null : _onContinueWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isGoogleLoading) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF7A0C16),
                                  strokeWidth: 2.0,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                LocaleService().isHindi
                                    ? 'Google से जोड़ा जा रहा है...'
                                    : 'Connecting to Google...',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7A0C16),
                                ),
                              ),
                            ] else ...[
                              _buildGoogleGLogo(),
                              const SizedBox(width: 10),
                              Text(
                                AppStrings.t('continue_with_google'),
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Informational Note
                  Center(
                    child: Text(
                      LocaleService().isHindi
                          ? 'बिना पासवर्ड के सुरक्षित व त्वरित प्रवेश'
                          : 'Password-free, secure devotional login',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF756D65),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Supabase Secure Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF8C7B70)),
                      const SizedBox(width: 5),
                      Text(
                        AppStrings.t('supabase_auth_note'),
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF8C7B70),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        color: const Color(0xFF231E1B),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.5,
          color: const Color(0xFF9E958C),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF7A0C16),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2D7C5), width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2D7C5), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7A0C16), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.6),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGoogleGLogo() {
    return Image.asset(
      'assets/icons/google.png',
      width: 20,
      height: 20,
      errorBuilder: (_, __, ___) => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _GoogleGLogoPainter(),
        ),
      ),
    );
  }
}

/// Custom painter for the delicate golden mandala watermarks at the corners of the Sign In card
class _CornerMandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5983A).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawCornerMandala(canvas, const Offset(0, 0), paint, 0);
    _drawCornerMandala(canvas, Offset(size.width, 0), paint, math.pi / 2);
    _drawCornerMandala(canvas, Offset(0, size.height), paint, -math.pi / 2);
    _drawCornerMandala(
        canvas, Offset(size.width, size.height), paint, math.pi);
  }

  void _drawCornerMandala(
      Canvas canvas, Offset origin, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rotation);

    for (double r = 18; r <= 56; r += 12) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: r),
        0,
        math.pi / 2,
        false,
        paint,
      );
    }

    // Radiating petals
    for (int i = 0; i <= 6; i++) {
      final angle = (math.pi / 12) * i;
      final x1 = math.cos(angle) * 20;
      final y1 = math.sin(angle) * 20;
      final x2 = math.cos(angle) * 52;
      final y2 = math.sin(angle) * 52;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double stroke = w * 0.22;
    final rect =
        Rect.fromLTWH(stroke / 2, stroke / 2, w - stroke, h - stroke);

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Red (top arc)
    canvas.drawArc(rect, -2.4, 1.45, false, paintRed);
    // Yellow (left arc)
    canvas.drawArc(rect, 2.35, 1.58, false, paintYellow);
    // Green (bottom arc)
    canvas.drawArc(rect, 0.78, 1.57, false, paintGreen);
    // Blue (right arc)
    canvas.drawArc(rect, -0.78, 1.56, false, paintBlue);

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - stroke / 2, h / 2 - stroke / 2, w / 2, stroke),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
