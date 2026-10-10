import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AstrologerColors {
  // Sacred Ivory, Divine Maroon & Vedic Saffron Palette (Matches Consumer App Exactly)
  static const Color cosmicDark = AppColors.backgroundLight; // 0xFFFCFBF7 - Warm Sacred Ivory
  static const Color cosmicCard = AppColors.cardLight; // 0xFFFFFFFF - Pure Card White
  static const Color cosmicSurface = AppColors.warmCream; // 0xFFFFF9ED - Soft Cream Surface
  static const Color borderSubtle = AppColors.lightBorder; // 0xFFEDE4D4 - Subtle Border

  static const Color royalPurple = AppColors.primaryMaroon; // 0xFF7A0C16 - Divine Maroon
  static const Color mysticalViolet = AppColors.kumkumMaroon; // 0xFF8B1E1E - Kumkum Maroon
  
  static const Color vedicGold = AppColors.deepAmber; // 0xFFD97706 - Vedic Gold
  static const Color saffronAccent = AppColors.saffronPrimary; // 0xFFFF6B35 - Sacred Saffron
  static const Color amberGlow = Color(0xFFFEF3C7);
  
  static const Color statusOnline = AppColors.statusOnline; // 0xFF10B981
  static const Color statusBusy = AppColors.statusBusy; // 0xFFF59E0B
  static const Color statusOffline = AppColors.statusOffline; // 0xFFEF4444
  
  static const Color textPrimary = AppColors.textPrimary; // 0xFF1F1C1A - Dark Charcoal Espresso
  static const Color textSecondary = AppColors.textSecondary; // 0xFF6E6862
  static const Color textMuted = AppColors.textMuted; // 0xFF9E9790
}

class AstrologerTheme {
  static ThemeData get darkTheme => lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryMaroon,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMaroon,
        secondary: AppColors.deepAmber,
        surface: AppColors.surfaceLight,
        error: AppColors.statusOffline,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primaryMaroon),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMaroon,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
