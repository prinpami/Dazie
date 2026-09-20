import 'package:flutter/material.dart';

// These are the colors from the Dazie design-system document.
abstract final class DazieColors {
  static const midnightIndigo = Color(0xFF312E81);
  static const tangerineOrange = Color(0xFFFB923C);
  static const electricViolet = Color(0xFF8B5CF6);
  static const darkIndigo = Color(0xFF1E1B4B);
  static const searchPurple = Color(0xFF5E5A9F);
  static const mutedText = Color(0xFF9998A5);
  static const line = Color(0xFFE7E6ED);
  static const white = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: DazieColors.midnightIndigo,
      onPrimary: DazieColors.white,
      secondary: DazieColors.tangerineOrange,
      onSecondary: DazieColors.darkIndigo,
      tertiary: DazieColors.electricViolet,
      onTertiary: Colors.black,
      surface: DazieColors.white,
      onSurface: DazieColors.darkIndigo,
      error: Color(0xFFB3261E),
      onError: DazieColors.white,
    ),
    scaffoldBackgroundColor: DazieColors.white,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: DazieColors.darkIndigo,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: DazieColors.darkIndigo,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 16,
        color: DazieColors.darkIndigo,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 14,
        color: DazieColors.mutedText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: DazieColors.darkIndigo,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 12,
        color: DazieColors.mutedText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DazieColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DazieColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DazieColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: DazieColors.midnightIndigo,
          width: 1.5,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: DazieColors.tangerineOrange,
        foregroundColor: DazieColors.darkIndigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
