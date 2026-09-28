import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AstrologerColors {
  // Cosmic Royal & Vedic Gold Palette
  static const Color cosmicDark = Color(0xFF0F172A);
  static const Color cosmicCard = Color(0xFF1E293B);
  static const Color cosmicSurface = Color(0xFF334155);
  
  static const Color royalPurple = Color(0xFF6D28D9);
  static const Color mysticalViolet = Color(0xFF8B5CF6);
  
  static const Color vedicGold = Color(0xFFF59E0B);
  static const Color saffronAccent = Color(0xFFD97706);
  static const Color amberGlow = Color(0xFFFEF3C7);
  
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusBusy = Color(0xFFF59E0B);
  static const Color statusOffline = Color(0xFFEF4444);
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  static const Color borderSubtle = Color(0xFF334155);
}

class AstrologerTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AstrologerColors.cosmicDark,
      primaryColor: AstrologerColors.royalPurple,
      colorScheme: const ColorScheme.dark(
        primary: AstrologerColors.mysticalViolet,
        secondary: AstrologerColors.vedicGold,
        surface: AstrologerColors.cosmicCard,
        error: AstrologerColors.statusOffline,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AstrologerColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AstrologerColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AstrologerColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AstrologerColors.cosmicCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AstrologerColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AstrologerColors.vedicGold,
          foregroundColor: const Color(0xFF1E1B4B),
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
