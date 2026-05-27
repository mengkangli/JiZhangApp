import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Warm amber-gold — primary brand color
  static const primary = Color(0xFFD4914A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFE8CC);
  static const onPrimaryContainer = Color(0xFF4A2D00);

  // Deep ink-blue — secondary
  static const secondary = Color(0xFF2C3E50);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDCE8F0);
  static const onSecondaryContainer = Color(0xFF0D1B2A);

  // Functional
  static const income = Color(0xFF2E7D32);
  static const incomeBg = Color(0xFFE8F5E9);
  static const expense = Color(0xFFC62828);
  static const expenseBg = Color(0xFFFFEBEE);

  // Surfaces
  static const background = Color(0xFFFAF7F2); // Rice paper warm white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F0E8);

  // Dark mode
  static const darkBackground = Color(0xFF1A1D23);
  static const darkSurface = Color(0xFF252830);
  static const darkSurfaceVariant = Color(0xFF32353D);

  // Budget status
  static const budgetSafe = Color(0xFF2E7D32);
  static const budgetWarning = Color(0xFFF57C00);
  static const budgetExceeded = Color(0xFFC62828);
}
