import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // Check authentication after splash delay
    _authTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
  }

  void _handleNavigation(AuthState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (state is AuthAuthenticated) {
      context.go('/home');
    } else if (state is AuthProfileRequired) {
      context.go('/profile-setup');
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go('/login');
    }
  }

  void _onSkipTap() {
    if (_hasNavigated || !mounted) return;
    final currentState = context.read<AuthBloc>().state;
    if (currentState is AuthAuthenticated) {
      _handleNavigation(currentState);
    } else {
      _hasNavigated = true;
      context.go('/login');
    }
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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _handleNavigation(state);
        },
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
                    AppConstants.splashBackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback in case asset cannot be loaded
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE5A638),
                              Color(0xFF8B2510),
                              Color(0xFF1E0703),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.appName,
                            style: GoogleFonts.cinzel(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade200,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Subtle Divine Breathing Golden Aura near Diya & Temple
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.14,
                      right: MediaQuery.of(context).size.width * 0.15,
                      child: Container(
                        width: 90 * _pulseAnimation.value,
                        height: 90 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300).withValues(
                                alpha: 0.18 * _pulseAnimation.value,
                              ),
                              blurRadius: 36 * _pulseAnimation.value,
                              spreadRadius: 16 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 3. Active Golden Rotating Circular Loader & "Loading..."
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.082,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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

                          // Pulsing "Loading..." Typography
                          Opacity(
                            opacity: 0.75 + (0.25 * _pulseAnimation.value),
                            child: Text(
                              'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFDE68A),
                                letterSpacing: 0.8,
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
      ),
    );
  }
}
