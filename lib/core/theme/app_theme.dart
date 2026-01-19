import 'package:flutter/material.dart';

class AppTheme {
  // --- New "Logo-Inspired" Palette ---
  // A vibrant, friendly light blue matching the droplet's body
  static const Color _primaryBlue = Color(0xFF29B6F6); 
  // A softer cyan/teal for accents, matching the glow
  static const Color _secondaryCyan = Color(0xFF81D4FA); 
  // Very pale blue for backgrounds (Alice Blue)
  static const Color _backgroundLight = Color(0xFFF0F8FF); 
  // Darker blue for text to ensure readability on light backgrounds
  static const Color _textDarkBlue = Color(0xFF01579B); 
  static const Color _surfaceWhite = Colors.white;
  static const Color _errorRed = Color(0xFFE57373);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      primary: _primaryBlue,
      secondary: _secondaryCyan,
      surface: _surfaceWhite,
      background: _backgroundLight,
      error: _errorRed,
      // Text on primary buttons should be white
      onPrimary: Colors.white, 
      // Text on background should be the dark blue for contrast
      onSurface: _textDarkBlue,
      onBackground: _textDarkBlue,
    ),
    
    scaffoldBackgroundColor: _backgroundLight,
    
    // Text Theme (Global Text Colors)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textDarkBlue),
      bodyMedium: TextStyle(color: _textDarkBlue),
      titleLarge: TextStyle(color: _textDarkBlue, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: _textDarkBlue, fontWeight: FontWeight.bold),
    ),

    // AppBar Styling
    appBarTheme: const AppBarTheme(
      backgroundColor: _backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _primaryBlue),
      titleTextStyle: TextStyle(
        color: _primaryBlue, // Title matches the logo color
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),

    // Card Styling
    cardTheme: CardThemeData(
      color: _surfaceWhite,
      elevation: 3,
      // Softer, light blue shadow to match the "glow"
      shadowColor: _primaryBlue.withValues(alpha: 0.25), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // ElevatedButton Styling
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: _primaryBlue.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),

    // TextField Styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _primaryBlue.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _errorRed),
      ),
      prefixIconColor: _primaryBlue,
      labelStyle: TextStyle(color: _primaryBlue.withValues(alpha: 0.8)),
      floatingLabelStyle: const TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
    ),
    
    // Icon Styling
    iconTheme: const IconThemeData(
      color: _primaryBlue,
      size: 24,
    ),
  );
}