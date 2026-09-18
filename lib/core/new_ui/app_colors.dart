import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Light Green
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryVeryLight = Color(0xFFEAFBF1);

  // Accent - Orange (for highlights like in the reference image)
  static const Color accent = Color(0xFFE8963C);
  static const Color accentLight = Color(0xFFF5B96E);

  // Background - White
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF9CA3AF);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Grade Colors
  static const Color primarySchoolColor = Color(0xFF22C55E);
  static const Color middleSchoolColor = Color(0xFF5B7FA6);
  static const Color highSchoolColor = Color(0xFF8B5CF6);
  static const Color kgColor = Color(0xFFE8963C);
}
