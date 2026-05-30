import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets hPaddingMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hPaddingLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets vPaddingSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vPaddingMd = EdgeInsets.symmetric(vertical: md);

  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);

  static const double cardRadius = 16;
  static const double buttonRadius = 12;
  static const double chipRadius = 8;
  static const double inputRadius = 12;
}

/// Note: prefer [AppRadius] for new code. The four `*Radius` doubles above
/// are kept for backward compatibility with existing call sites and will
/// be migrated incrementally.
