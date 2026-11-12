import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); 

  static const Color primary = Color(0xFF6558D3);
  static const Color primaryLight = Color(0xFF8A7DF0);
  static const Color primaryDark = Color(0xFF6254CF);

  static const Color scaffoldBackground = Color(0xFFFCFCFF);
  static const Color gradientStart = Color(0xFFF3F0FF);
  static const Color gradientMiddle = Color(0xFFFCFCFF);
  static const Color gradientEnd = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF20202B);
  static const Color textSecondary = Color(0xFF858592);
  static const Color textDark = Color(0xFF383844);
  static const Color textHint = Color(0xFF9A9AA8);
  static const Color textGray = Color(0xFF92919D);
  static const Color textBlack = Color(0xFF34343D);

  static const Color border = Color(0xFFE8E7EF);
  static const Color divider = Color(0xFFE6E5EC);
  static const Color inputFill = Color(0xD1FFFFFF); 
  static const Color prefixIcon = Color(0xFF88889A);

  static const Color googleBlue = Color(0xFF4285F4);

  static Color primaryShadow = primary.withValues(alpha: 0.22);
  static Color buttonShadow = primary.withValues(alpha: 0.28);
}