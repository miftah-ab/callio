import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallioDesign {
  // Spacing System (8dp grid)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Radius System
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;

  // Motion System
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasizedDecelerate = Curves.easeOutCubic;

  // Typography Scale (Using Google Fonts 'Inter' or fallback if not available)
  static TextTheme getTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
      headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.5),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.4),
      bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  // Theme Generator
  static ThemeData buildTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        color: colorScheme.surfaceContainer,
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, spacing48),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(spacing16),
      ),
    );
  }
}
