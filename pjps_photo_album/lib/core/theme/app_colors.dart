import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Light Golden
  static const Color primaryGold = Color(0xFFF4C542);
  static const Color primaryGoldLight = Color(0xFFF8D97A);
  static const Color primaryGoldDark = Color(0xFFDAA520);

  // Secondary Colors - Ash/Gray
  static const Color secondaryAsh = Color(0xFF6B7280);
  static const Color secondaryAshLight = Color(0xFF9CA3AF);
  static const Color secondaryAshDark = Color(0xFF4B5563);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1F2937);
  static const Color grey = Color(0xFFE5E7EB);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color darkGrey = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGold, primaryGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ashGradient = LinearGradient(
    colors: [secondaryAshLight, secondaryAshDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldAshGradient = LinearGradient(
    colors: [primaryGold, secondaryAsh],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
