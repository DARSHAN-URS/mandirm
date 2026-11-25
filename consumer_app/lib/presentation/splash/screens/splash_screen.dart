import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

    _animController.forward();

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
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
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
                            style: TextStyle(fontFamily: 'Headway', 
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
