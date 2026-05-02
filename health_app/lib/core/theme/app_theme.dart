import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Soft pastel palette — Capi-style
  static const Color background = Color(0xFFFAFBF7);
  static const Color primary = Color(0xFF6BBE8E);          // soft mint
  static const Color primaryDark = Color(0xFF4FA876);
  static const Color secondary = Color(0xFF9DD9B8);        // pale mint
  static const Color accent = Color(0xFFFF9A8B);           // soft coral
  static const Color muted = Color(0xFFD4E8DB);
  static const Color light = Color(0xFFE8F5EC);
  static const Color surface = Color(0xFFF3F6F0);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF7A6B);
  static const Color success = Color(0xFF6BBE8E);
  static const Color warning = Color(0xFFFFC371);
  static const Color textPrimary = Color(0xFF26312A);
  static const Color textSecondary = Color(0xFF6F7E72);
  static const Color textHint = Color(0xFFAFB8B0);
  static const Color divider = Color(0xFFEDF1EC);
  static const Color transparent = Color(0x00000000);

  // Pastel category palette (Capi-inspired)
  static const Color sleepBg = Color(0xFFFFF5D6);          // soft butter yellow
  static const Color sleepFg = Color(0xFFE8B23A);
  static const Color waterBg = Color(0xFFE0F0FF);          // sky blue
  static const Color waterFg = Color(0xFF4FA3E8);
  static const Color foodBg = Color(0xFFFFE5E5);           // blush pink
  static const Color foodFg = Color(0xFFEC7A8E);
  static const Color exerciseBg = Color(0xFFD8F0DD);       // pale mint
  static const Color exerciseFg = Color(0xFF4FA876);
  static const Color medsBg = Color(0xFFEEE5FF);           // lavender
  static const Color medsFg = Color(0xFF8B7BD8);
  static const Color mindBg = Color(0xFFFFE4D1);           // peach
  static const Color mindFg = Color(0xFFE89466);

  // Chart accent (kept for compatibility)
  static const Color chartBlue = Color(0xFF4FA3E8);
  static const Color chartPurple = Color(0xFF8B7BD8);
  static const Color chartCoral = Color(0xFFEC7A8E);
  static const Color chartTeal = Color(0xFF4FBBA8);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(44, 52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(44, 52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.divider,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primary,
        trackHeight: 5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.12),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.divider),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

BoxDecoration cardDecoration({
  Color? color,
  double radius = 20,
  bool withShadow = true,
}) {
  return BoxDecoration(
    color: color ?? AppColors.cardSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: withShadow
        ? [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ]
        : null,
  );
}
