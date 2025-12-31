import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const primary = Color(0xFF00796B); // Medical Teal
  static const secondary = Color(0xFF004D40);
  static const accent = Color(0xFF00BFA5);

  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const error = Color(0xFFEF4444);

  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  // Dark Theme Colors - Significantly Lighter Grey
  // আগে ছিল অনেক ডার্ক, এখন ডার্ক গ্রে (Material Dark Grey Style)
  static const darkBackground = Color(
    0xFF252525,
  ); // Lighter Dark Grey (Not pitch black)
  static const darkSurface = Color(
    0xFF353535,
  ); // Distinct lighter surface for cards

  static const darkPrimary = Color(0xFF80CBC4); // Soft Teal
  static const darkTextPrimary = Color(0xFFEEEEEE);
  static const darkTextSecondary = Color(0xFFBDBDBD);
}
