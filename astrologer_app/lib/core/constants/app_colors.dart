import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Divine Saffron & Marigold Primary Tones
  static const Color saffronPrimary = Color(0xFFFF6B35);
  static const Color saffronDark = Color(0xFFD64D18);
  static const Color saffronLight = Color(0xFFFF9166);
  static const Color marigoldGold = Color(0xFFF59E0B);
  static const Color deepAmber = Color(0xFFD97706);
  static const Color templeGold = Color(0xFFFFC107);

  // Sacred Kumkum & Maroon Accent Tones (Consumer App Exact)
  static const Color primaryMaroon = Color(0xFF7A0C16);
  static const Color kumkumMaroon = Color(0xFF8B1E1E);
  static const Color sacredCrimson = Color(0xFF991B1B);
  static const Color divineRuby = Color(0xFFB91C1C);

  // Calming Spiritual Neutrals & Backgrounds (Consumer App Exact)
  static const Color backgroundLight = Color(0xFFFCFBF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color headerBg = Color(0xFFFFFDF9);
  static const Color lightBorder = Color(0xFFEDE4D4);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F1C1A);
  static const Color textSecondary = Color(0xFF6E6862);
  static const Color textMuted = Color(0xFF9E9790);

  static const Color textPrimaryLight = Color(0xFF1F1C1A);
  static const Color textSecondaryLight = Color(0xFF6E6862);
  static const Color textMutedLight = Color(0xFF9E9790);

  // Status & Feedback
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusBusy = Color(0xFFF59E0B);
  static const Color statusOffline = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Sacred Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient divineMaroonGradient = LinearGradient(
    colors: [Color(0xFF7A0C16), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldShimmerGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFFD54F), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
