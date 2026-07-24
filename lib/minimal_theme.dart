import 'package:flutter/material.dart';

class MinimalTheme {
  static ThemeData get light {
    const primary = Color(0xFF111111);
    const secondary = Color(0xFF666666);

    const background = Color(0xFFF9F9F9);
    const surface = Color(0xFFFFFFFF);
    const border = Color(0xFFE5E5E5);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: surface,
        onSurface: primary,
      ),

      scaffoldBackgroundColor: background,
      canvasColor: background,

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: Color(0xFF222222),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: secondary,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: border,
          ),
        ),
      ),

      dividerColor: border,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
            minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(120, 50),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),

      iconTheme: const IconThemeData(
        color: primary,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}