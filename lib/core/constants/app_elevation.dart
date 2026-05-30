import 'package:flutter/material.dart';

/// Three semantic shadow tiers.
///
/// Refactoring UI: shadows give depth without darkening the layout. The
/// trick is to use a soft, low-opacity, slightly-offset shadow that hints
/// at hierarchy without screaming for attention. Light theme uses warm
/// near-black; dark theme uses pure black with a touch more spread.
class AppShadow {
  AppShadow._();

  /// Resting cards, list items that should *barely* lift off the surface.
  /// Use sparingly — too many subtle shadows turn into visual noise.
  static List<BoxShadow> subtle(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x0A1A1A17), // ~4% warm-black
        blurRadius: 8,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color(0x081A1A17), // ~3%
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ];
  }

  /// Buttons hovered, FABs at rest, sticky headers.
  /// Visible but never harsh.
  static List<BoxShadow> raised(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x141A1A17), // ~8%
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x0A1A1A17),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
  }

  /// Modals, popovers, the FAB while pressed. Strong but still soft.
  static List<BoxShadow> overlay(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x1F1A1A17), // ~12%
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
      BoxShadow(
        color: Color(0x0F1A1A17),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];
  }
}
