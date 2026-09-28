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

  // Sacred Kumkum & Maroon Accent Tones
  static const Color kumkumMaroon = Color(0xFF831843);
  static const Color sacredCrimson = Color(0xFF991B1B);
  static const Color divineRuby = Color(0xFFB91C1C);

  // Calming Spiritual Neutrals & Backgrounds
  static const Color backgroundLight = Color(0xFFFCFBF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color lightBorder = Color(0xFFE2DFD8);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF120E0D);
  static const Color surfaceDark = Color(0xFF1E1715);
  static const Color cardDark = Color(0xFF281E1B);
  static const Color darkBorder = Color(0xFF3B2E2A);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F1C1A);
  static const Color textSecondaryLight = Color(0xFF6E6862);
  static const Color textMutedLight = Color(0xFF9E9790);

  static const Color textPrimaryDark = Color(0xFFF9F6F0);
  static const Color textSecondaryDark = Color(0xFFC7BFB5);
  static const Color textMutedDark = Color(0xFF8A8279);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Sacred Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient divineMaroonGradient = LinearGradient(
    colors: [Color(0xFF991B1B), Color(0xFFD64D18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldShimmerGradient = LinearGradient(
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF241C1A), Color(0xFF1A1312)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
