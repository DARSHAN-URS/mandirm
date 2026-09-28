import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  Timer? _authTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.repeat(reverse: true);

    // Check authentication after splash delay
    _authTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
  }

  @override
  void dispose() {
    _authTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthProfileRequired) {
          context.go('/profile-setup');
        } else if (state is AuthUnauthenticated || state is AuthError) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF330B04),
                Color(0xFF6B1D0E),
                Color(0xFF8B2510),
                Color(0xFF1E0703),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle background mandala / divine circles
              Positioned(
                top: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.saffronPrimary.withAlpha(20),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.marigoldGold.withAlpha(15),
                  ),
                ),
              ),

              // Main Animated Content
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Divine Glowing Emblem with Logo
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing outer gold aura
                              Container(
                                width: 140 + (14 * _glowAnimation.value),
                                height: 140 + (14 * _glowAnimation.value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.templeGold.withAlpha(
                                        (80 * _glowAnimation.value).toInt(),
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: AppColors.saffronPrimary.withAlpha(
                                        (100 * _glowAnimation.value).toInt(),
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),

                              // Golden decorative border ring
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFDF7D),
                                      Color(0xFFF59E0B),
                                      Color(0xFFD97706),
                                      Color(0xFFFFE89E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 2.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: ClipOval(
                                  child: Image.asset(
                                    AppConstants.logoAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback temple icon if asset is loading
                                      return Container(
                                        color: const Color(0xFF6B1D0E),
                                        child: const Icon(
                                          Icons.temple_hindu_rounded,
                                          size: 64,
                                          color: AppColors.templeGold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title with Cinzel font
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            AppConstants.appName.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.0,
                              color: const Color(0xFFFFF7ED),
                              shadows: [
                                Shadow(
                                  color: AppColors.marigoldGold.withAlpha(160),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.marigoldGold.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              AppConstants.appTagline,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFFDE68A),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Loading Indicator with Divine Theme
                        Column(
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.templeGold.withAlpha(220),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Awakening Divine Presence...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFFE2DFD8).withAlpha(180),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
