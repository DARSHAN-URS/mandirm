import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth/auth_service.dart';
import '../../home/screens/main_hub_screen.dart';
import '../../auth/screens/login_screen.dart';

class AstrologerSplashScreen extends StatefulWidget {
  const AstrologerSplashScreen({super.key});

  @override
  State<AstrologerSplashScreen> createState() => _AstrologerSplashScreenState();
}

class _AstrologerSplashScreenState extends State<AstrologerSplashScreen>
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

    // Direct routing to Main Hub or Login without onboarding
    if (!mounted) return;

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
                  fit: BoxFit.fill,
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
            ],
          ),
        ),
      ),
    );
  }
}
