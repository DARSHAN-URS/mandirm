import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth/auth_service.dart';
import '../../home/screens/main_hub_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class AstrologerSplashScreen extends StatefulWidget {
  const AstrologerSplashScreen({super.key});

  @override
  State<AstrologerSplashScreen> createState() => _AstrologerSplashScreenState();
}

class _AstrologerSplashScreenState extends State<AstrologerSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _authTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animController.repeat(reverse: true);

    // Check authentication after splash animation
    _authTimer = Timer(const Duration(milliseconds: 2400), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    try {
      await AuthService().restoreSession();
    } catch (e) {
      debugPrint('[SplashScreen] Auth check notice: $e');
    }

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
      if (!mounted) return;

      if (!hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AstrologerOnboardingScreen()),
        );
        return;
      }
    } catch (_) {}

    if (!mounted) return;

    if (AuthService().isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AstrologerLoginScreen()),
      );
    }
  }

  void _onSkipTap() {
    _authTimer?.cancel();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _authTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1E0703),
        body: GestureDetector(
          onTap: _onSkipTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Divine Temple Sunset & Emblem Artwork Background
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/splash_bg_clean.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2A0845),
                            Color(0xFF641010),
                            Color(0xFF0F172A),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Subtle Cosmic Violet / Gold Breathing Aura
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.16,
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: Container(
                      width: 90 * _pulseAnimation.value,
                      height: 90 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(
                              alpha: 0.22 * _pulseAnimation.value,
                            ),
                            blurRadius: 40 * _pulseAnimation.value,
                            spreadRadius: 20 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 3. Acharya Portal Branding & Rotating Golden Loader
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height * 0.085,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Astrologer Portal Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AstrologerColors.cosmicCard.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AstrologerColors.vedicGold.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AstrologerColors.vedicGold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'VEDIC ACHARYA PORTAL',
                                style: GoogleFonts.cinzel(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: AstrologerColors.vedicGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Radiant Golden Circular Spinner
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEAA031).withValues(
                                  alpha: 0.35 * _pulseAnimation.value,
                                ),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3.2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF6B842),
                            ),
                            backgroundColor:
                                const Color(0xFF5D240E).withValues(alpha: 0.35),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Pulsing "Authenticating..." Typography
                        Opacity(
                          opacity: 0.80 + (0.20 * _pulseAnimation.value),
                          child: Text(
                            'Connecting to Mandirm Cosmos...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFDE68A),
                              letterSpacing: 0.6,
                              shadows: const [
                                Shadow(
                                  color: Color(0x99000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
