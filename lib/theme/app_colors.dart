import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Deep Blue Palette
  static const Color primary = Color(0xFF0F172A); // Very deep blue/slate
  static const Color primaryBlue = Color(0xFF1E3A8A); // Royal deep blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // Secondary colors - Teal / Green Accents
  static const Color secondary = Color(0xFF0D9488); // Deep Teal
  static const Color tealLight = Color(0xFF14B8A6);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color greenContainer = Color(0xFFECFDF5);

  // Action colors - Warm Orange Callouts
  static const Color actionOrange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFF97316);
  static const Color orangeContainer = Color(0xFFFFF7ED);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Clean neutral off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
