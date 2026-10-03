import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/astrologers/screens/astrologer_detail_screen.dart';
import '../../presentation/astrologers/screens/astrologers_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/otp_verification_screen.dart';
import '../../presentation/auth/screens/profile_setup_screen.dart';
import '../../presentation/bookings/screens/bookings_screen.dart';
import '../../presentation/consultations/screens/consultations_screen.dart';
import '../../presentation/home/screens/home_screen.dart';
import '../../presentation/puja/screens/puja_detail_screen.dart';
import '../../presentation/puja/screens/pujas_screen.dart';
import '../../presentation/shop/screens/prasad_orders_screen.dart';
import '../../presentation/splash/screens/splash_screen.dart';
import '../../presentation/temples/screens/temples_screen.dart';
import '../../services/supabase_service.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final auth = SupabaseService();
      final isLoggedIn = auth.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' ||
          location == '/otp-verify' ||
          location == '/splash' ||
          location == '/profile-setup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && (location == '/login' || location == '/otp-verify')) {
        return '/home';
      }

      return null;
    },
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
      GoRoute(
        path: '/bookings',
        builder: (BuildContext context, GoRouterState state) {
          return const BookingsScreen();
        },
      ),
      GoRoute(
        path: '/consultations',
        builder: (BuildContext context, GoRouterState state) {
          return const ConsultationsScreen();
        },
      ),
      GoRoute(
        path: '/prasad-orders',
        builder: (BuildContext context, GoRouterState state) {
          return const PrasadOrdersScreen();
        },
      ),
      GoRoute(
        path: '/temples',
        builder: (BuildContext context, GoRouterState state) {
          return const TemplesScreen();
        },
      ),
      GoRoute(
        path: '/pujas',
        builder: (BuildContext context, GoRouterState state) {
          return const PujasScreen();
        },
      ),
      GoRoute(
        path: '/puja-detail',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PujaDetailScreen(puja: extra);
        },
      ),
      GoRoute(
        path: '/astrologers',
        builder: (BuildContext context, GoRouterState state) {
          return const AstrologersScreen();
        },
      ),
      GoRoute(
        path: '/astrologer-detail',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AstrologerDetailScreen(astrologer: extra);
        },
      ),
    ],
  );
}
