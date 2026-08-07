import 'package:flutter/material.dart';

class AppColors {
  // Core
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = Colors.red;
  static const MaterialColor grey = Colors.grey;

  // Brand palette
  static const Color primary = Color(0xFFFF4D88);
  static const Color primaryDeep = Color(0xFFE03372);
  static const Color primarySoft = Color(0xFFFFD1E0);
  static const Color bg = Color(0xFFFFF5F8);
  static const Color chip = Color(0xFFFFE8F0);

  // Text
  static const Color text = Color(0xFF2A0E1B);
  static const Color textMuted = Color(0xFF7A5A6A);
  static const Color textFaint = Color(0xFFB89DAA);

  // UI
  static const Color line = Color(0xFFF2DDE5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF27AE60);
  static const Color warn = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);
  static const Color gold = Color(0xFFF7C948);

  // Legacy aliases
  static const Color pink = primary;
  static const Color focusedBorder = primary;
  static const Color darkPink = primaryDeep;
  static const Color lightPink = bg;
  static const Color bottomBar = Color(0xFFEED1E3);
  static const Color iconColor = Color(0xFF525151);
  static const Color textDark = text;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [primarySoft, Color(0xFFFFE9F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
