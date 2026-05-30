import 'package:flutter/material.dart';
import 'app_neutrals.dart';

/// Brand and semantic colors.
///
/// Neutral grays live in [AppNeutrals]. Reach for semantic tokens like
/// [overlayMuted] / [overlaySubtle] instead of `.withValues(alpha: 0.x)`
/// at call sites — keeps opacity choices auditable in one place.
class AppColors {
  AppColors._();

  // Warm amber-gold — primary brand color.
  static const primary = Color(0xFFD4914A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFE8CC);
  static const onPrimaryContainer = Color(0xFF4A2D00);

  // Deep ink-blue — secondary.
  static const secondary = Color(0xFF2C3E50);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDCE8F0);
  static const onSecondaryContainer = Color(0xFF0D1B2A);

  // Functional — income / expense semantics.
  static const income = Color(0xFF2E7D32);
  static const incomeBg = Color(0xFFE8F5E9);
  static const expense = Color(0xFFC62828);
  static const expenseBg = Color(0xFFFFEBEE);

  // Surfaces.
  static const background = Color(0xFFFAF7F2); // Rice paper warm white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F0E8);

  // Dark mode.
  static const darkBackground = Color(0xFF1A1D23);
  static const darkSurface = Color(0xFF252830);
  static const darkSurfaceVariant = Color(0xFF32353D);

  // Budget status.
  static const budgetSafe = Color(0xFF2E7D32);
  static const budgetWarning = Color(0xFFF57C00);
  static const budgetExceeded = Color(0xFFC62828);

  // ─── Named opacity tokens ─────────────────────────────────────────
  // Use these instead of `.withValues(alpha: 0.x)` at call sites.

  /// 4%  — hairline overlays, ghost backgrounds (e.g. selected list row).
  static const double opacityHairline = 0.04;

  /// 8%  — soft tinted background (category-icon container, chips).
  static const double opacitySoft = 0.08;

  /// 12% — muted accent (CategoryIcon background, hover states).
  static const double opacityMuted = 0.12;

  /// 15% — soft accent fill (selected chips, progress-track tint).
  static const double opacityAccentFill = 0.15;

  /// 24% — subdued foreground (placeholder text icon, disabled items).
  static const double opacitySubtle = 0.24;

  /// 30% — accent border / outline tint.
  static const double opacityAccentBorder = 0.30;

  /// 40% — soft illustrative backgrounds (empty-state circle).
  static const double opacityIllustrationBg = 0.40;

  /// 50% — soft illustrative foregrounds (empty-state icon stroke).
  static const double opacityIllustrationFg = 0.50;

  /// 60% — secondary foreground when full-strength is too loud.
  static const double opacitySecondary = 0.60;

  /// 70% — semi-transparent text on tinted hero blocks.
  static const double opacityHeroSecondary = 0.70;

  /// 80% — inverted text on tinted hero blocks.
  static const double opacityProminent = 0.80;
}
