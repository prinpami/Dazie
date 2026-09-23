import 'package:flutter/material.dart';

// These colors come from the Dazie brand guide, with dark surfaces for this demo.
abstract final class DazieColors {
  static const midnightIndigo = Color(0xFF312E81);
  static const tangerineOrange = Color(0xFFFB923C);
  static const electricViolet = Color(0xFF8B5CF6);
  static const darkIndigo = Color(0xFF1E1B4B);
  static const background = darkIndigo;
  static const surface = Color(0xFF5E5A9F);
  static const searchPurple = Color(0xFF5E5A9F);
  static const mutedText = Color(0xFFB9B8C9);
  static const line = Color(0xFFDADADA);
  static const fieldFill = Color(0xFFF1F1F1);
  static const fieldText = Color(0xFF999999);
  static const violetText = Color(0xFF77749F);
  static const black = Color(0xFF101010);
  static const white = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: DazieColors.midnightIndigo,
      onPrimary: DazieColors.white,
      secondary: DazieColors.tangerineOrange,
      onSecondary: DazieColors.white,
      tertiary: DazieColors.electricViolet,
      onTertiary: DazieColors.white,
      surface: DazieColors.white,
      onSurface: DazieColors.black,
      error: Color(0xFFB3261E),
      onError: DazieColors.white,
    ),
    scaffoldBackgroundColor: DazieColors.white,
    fontFamily: 'Nunito Sans',
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: DazieColors.black,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: DazieColors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 14,
        color: DazieColors.fieldText,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 13,
        color: DazieColors.fieldText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: DazieColors.violetText,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 13,
        color: DazieColors.fieldText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: DazieColors.fieldFill,
      hintStyle: const TextStyle(color: DazieColors.fieldText, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DazieColors.tangerineOrange),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB3261E)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: DazieColors.tangerineOrange,
        foregroundColor: DazieColors.white,
        elevation: 2,
        shadowColor: const Color(0xFFDB782A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: DazieColors.fieldText,
        backgroundColor: DazieColors.fieldFill,
        side: const BorderSide(color: Color(0xFFE2E2E2)),
        elevation: 1,
        shadowColor: const Color(0xFFD5D5D5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DazieColors.tangerineOrange,
        textStyle: const TextStyle(
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: DazieColors.midnightIndigo,
      onPrimary: DazieColors.white,
      secondary: DazieColors.tangerineOrange,
      onSecondary: DazieColors.darkIndigo,
      tertiary: DazieColors.electricViolet,
      onTertiary: DazieColors.white,
      surface: DazieColors.darkIndigo,
      onSurface: DazieColors.white,
      error: Color(0xFFFF8A80),
      onError: DazieColors.darkIndigo,
    ),
    scaffoldBackgroundColor: DazieColors.background,
    fontFamily: 'Nunito Sans',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: DazieColors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: DazieColors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: DazieColors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 16,
        color: DazieColors.white,
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
        color: DazieColors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Nunito Sans',
        fontSize: 12,
        color: DazieColors.mutedText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DazieColors.surface,
      labelStyle: const TextStyle(color: DazieColors.mutedText),
      hintStyle: const TextStyle(color: DazieColors.mutedText),
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
          color: DazieColors.tangerineOrange,
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DazieColors.tangerineOrange,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
