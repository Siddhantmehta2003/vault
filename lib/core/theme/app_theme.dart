import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Purple
  static const purple = Color(0xFF8B5CF6);
  static const purpleDark = Color(0xFF6D28D9);
  static const purpleLight = Color(0xFFA78BFA);

  // Semantic Colors
  static const red = Color(0xFFEF4444);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);

  // Light Theme
  static const lightBgPrimary = Color(0xFFFFFFFF);
  static const lightBgSecondary = Color(0xFFF5F5F5);
  static const lightTextPrimary = Color(0xFF0A0A0A);
  static const lightTextSecondary = Color(0xFF525252);
  static const lightBorder = Color(0xFFE5E5E5);

  // Dark Theme
  static const darkBgPrimary = Color(0xFF0A0A0A);
  static const darkBgSecondary = Color(0xFF1A1A1A);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA3A3A3);
  static const darkBorder = Color(0xFF404040);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBgPrimary,
    primaryColor: AppColors.purple,
    colorScheme: const ColorScheme.light(
      primary: AppColors.purple,
      secondary: AppColors.purpleLight,
      surface: AppColors.lightBgSecondary,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBgPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightBgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBgPrimary,
    primaryColor: AppColors.purple,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.purpleLight,
      surface: AppColors.darkBgSecondary,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBgPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkBgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
}
