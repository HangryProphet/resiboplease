import 'package:flutter/material.dart';

abstract final class ResiboColors {
  static const cream = Color(0xFFF7F0DF);
  static const paper = Color(0xFFFFFBF1);
  static const navy = Color(0xFF16263B);
  static const teal = Color(0xFF237A76);
  static const mutedRed = Color(0xFFAA3F4B);
  static const gold = Color(0xFFE3A82B);
  static const ink = Color(0xFF24303E);
}

ThemeData buildResiboTheme({bool highContrast = false}) {
  final ink = highContrast ? const Color(0xFF07111D) : ResiboColors.ink;
  final paper = highContrast ? Colors.white : ResiboColors.paper;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: ResiboColors.teal,
        brightness: Brightness.light,
        surface: paper,
      ).copyWith(
        primary: highContrast ? const Color(0xFF005B57) : ResiboColors.teal,
        secondary: ResiboColors.gold,
        error: highContrast ? const Color(0xFF8D1021) : ResiboColors.mutedRed,
        onSurface: ink,
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: highContrast
        ? const Color(0xFFFFF8E6)
        : ResiboColors.cream,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: ResiboColors.navy,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highContrast ? ResiboColors.navy : const Color(0x1F16263B),
          width: highContrast ? 2 : 1,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: ResiboColors.navy,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: ResiboColors.navy,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(height: 1.45),
      bodyMedium: TextStyle(height: 1.4),
    ),
  );
}
