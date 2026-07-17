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

ThemeData buildResiboTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: ResiboColors.teal,
        brightness: Brightness.light,
        surface: ResiboColors.paper,
      ).copyWith(
        primary: ResiboColors.teal,
        secondary: ResiboColors.gold,
        error: ResiboColors.mutedRed,
        onSurface: ResiboColors.ink,
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: ResiboColors.cream,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: ResiboColors.navy,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: ResiboColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x1F16263B)),
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
