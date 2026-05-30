import 'package:flutter/material.dart';

/// Single source of truth for corner radii.
///
/// Refactoring UI: pick from a fixed scale instead of typing arbitrary
/// `BorderRadius.circular(13)`. Pair size with intent — `xs/sm` for inline
/// chips, `md` for buttons & inputs, `lg` for cards, `xl` for sheets/modals,
/// `pill` for fully-rounded badges and capsules.
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get allXs => BorderRadius.circular(xs);
  static BorderRadius get allSm => BorderRadius.circular(sm);
  static BorderRadius get allMd => BorderRadius.circular(md);
  static BorderRadius get allLg => BorderRadius.circular(lg);
  static BorderRadius get allXl => BorderRadius.circular(xl);
  static BorderRadius get allPill => BorderRadius.circular(pill);

  /// Top-only radius for bottom sheets.
  static BorderRadius get topXl =>
      const BorderRadius.vertical(top: Radius.circular(xl));
}
