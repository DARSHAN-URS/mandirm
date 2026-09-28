import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/otp_verification_screen.dart';
import '../../presentation/auth/screens/profile_setup_screen.dart';
import '../../presentation/home/screens/home_screen.dart';
import '../../presentation/splash/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final target = extra?['target'] as String? ?? '';
          final isPhone = extra?['isPhone'] as bool? ?? true;

          return OtpVerificationScreen(
            target: target,
            isPhone: isPhone,
          );
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
    ],
  );
}
