import 'package:flutter/material.dart';

class AppTheme {
  // --- Color Palette ---
  static const Color _primaryBlue = Color(0xFF0288D1); // Deep Ocean
  static const Color _secondaryTeal = Color(0xFF26C6DA); // Tropical Water
  static const Color _backgroundLight = Color(0xFFF0F8FF); // Alice Blue
  static const Color _surfaceWhite = Colors.white;
  static const Color _errorRed = Color(0xFFE57373);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto', // Default, but explicit helps if you add fonts later
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      primary: _primaryBlue,
      secondary: _secondaryTeal,
      surface: _surfaceWhite,
      background: _backgroundLight,
      error: _errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    
    scaffoldBackgroundColor: _backgroundLight,

    // AppBar Styling
    appBarTheme: const AppBarTheme(
      backgroundColor: _backgroundLight,
      surfaceTintColor: Colors.transparent, // Removes the scroll tint
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _primaryBlue),
      titleTextStyle: TextStyle(
        color: _primaryBlue,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),

    // Card Styling
    cardTheme: CardThemeData(
      color: _surfaceWhite,
      elevation: 4,
      shadowColor: _primaryBlue.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // ElevatedButton Styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),

    // TextField Styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryBlue.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _errorRed),
      ),
      prefixIconColor: _primaryBlue,
      labelStyle: TextStyle(color: _primaryBlue.withValues(alpha: 0.7)),
      floatingLabelStyle: const TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
    ),
    
    // Icon Styling
    iconTheme: const IconThemeData(
      color: _primaryBlue,
      size: 24,
    ),
  );
}