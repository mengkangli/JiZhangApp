import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'illustrations.dart';

/// Reusable empty / "nothing here yet" state.
///
/// Two visual variants:
/// - **Illustration** (preferred for first-time / discovery moments) —
///   pass `illustration:` to render the hand-drawn `EmptyArtwork`.
/// - **Icon** (compact, lower-effort fallback) — pass `icon:` for inline
///   empties inside scrolling lists where a 120px painting would be too
///   loud.
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final EmptyIllustration? illustration;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : assert(icon != null || illustration != null,
            'Provide either icon or illustration');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              EmptyArtwork(kind: illustration!, size: 120)
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer
                      .withValues(alpha: AppColors.opacityIllustrationBg),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon!,
                  size: 36,
                  color: colorScheme.primary
                      .withValues(alpha: AppColors.opacityIllustrationFg),
                ),
              ),
            AppSpacing.gapXl,
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapXl,
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
