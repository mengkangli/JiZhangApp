import 'package:flutter/material.dart';

/// Neutral grayscale with a subtle warm bias (~+1° hue toward the brand
/// amber). Used for borders, dividers, muted text, and disabled states.
///
/// Refactoring UI rule of thumb: pick from this scale for everything that
/// is not a brand or semantic color. Resist reaching for pure black/white
/// or arbitrary `Colors.grey.shade*` values.
class AppNeutrals {
  AppNeutrals._();

  // Light scale — warm-tinted gray, tuned against #FAF7F2 surface.
  static const n50 = Color(0xFFFAF8F5);
  static const n100 = Color(0xFFF2EEE8);
  static const n200 = Color(0xFFE6E0D6);
  static const n300 = Color(0xFFD3CCBF);
  static const n400 = Color(0xFFAFA89B);
  static const n500 = Color(0xFF847E73);
  static const n600 = Color(0xFF5E5950);
  static const n700 = Color(0xFF40403A);
  static const n800 = Color(0xFF2A2A26);
  static const n900 = Color(0xFF1A1A17);

  // Dark scale — cool-shifted neutrals tuned against #1A1D23.
  static const dn50 = Color(0xFFE8E6E1);
  static const dn100 = Color(0xFFC9C7C2);
  static const dn200 = Color(0xFF9C9A95);
  static const dn300 = Color(0xFF6F6D68);
  static const dn400 = Color(0xFF4E4C48);
  static const dn500 = Color(0xFF393734);
  static const dn600 = Color(0xFF2D2B29);
  static const dn700 = Color(0xFF252320);
  static const dn800 = Color(0xFF1A1D23);
  static const dn900 = Color(0xFF101216);
}
