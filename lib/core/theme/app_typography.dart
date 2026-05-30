import 'package:flutter/material.dart';

/// Typographic scale. Refactoring UI: pick from a fixed set of sizes /
/// weights — never type a one-off `fontSize: 13`. Two weights only:
/// 400 (regular body) and 600 (emphasis). Size carries the rest of the
/// hierarchy.
///
/// Numeric styles are tabular and slightly tighter — keep amounts aligned
/// in lists and avoid the dancing-zero problem when totals animate.
class AppTypography {
  AppTypography._();

  // Use system fonts — reliable on all platforms (web, Android, iOS).
  // On Chinese Windows/Android, this resolves to the system CJK font.
  // When swapping in a custom typeface later, set `fontFamily:` on each
  // TextStyle below rather than threading a private field through.

  // ─── Display / Headline ──────────────────────────────────────────
  static TextStyle get displayLarge => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      );

  // ─── Body / Title ────────────────────────────────────────────────
  static TextStyle get titleMedium => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  // ─── Numeric (tabular figures) ──────────────────────────────────
  /// Hero amounts on the dashboard — pair with `AmountText` size 48.
  static TextStyle get numericHero => const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        height: 1.05,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// Add-transaction screen amount input.
  static TextStyle get numericLarge => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.1,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  /// List-row amounts — keeps decimals aligned across rows.
  static TextStyle get numericMedium => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextTheme buildTextTheme(ColorScheme colorScheme, TextTheme base) {
    return base.copyWith(
      displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
      bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: colorScheme.outline),
    );
  }
}
