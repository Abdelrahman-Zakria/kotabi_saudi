import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF008080);
  static const Color secondaryColor = Color(0xFF006064);
  static const Color accentColor = Color(0xFFFF8F00); // Orange for FAB
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D3436);
  static const Color subTextColor = Color(0xFF636E72);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006064), Color(0xFF009688)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
        titleMedium: const TextStyle(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: cardColor,
      ),
    );
  }
}
