import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Renders a money amount with sign + currency symbol, color-coded for
/// income/expense.
///
/// Accessibility: color alone isn't enough — colour-blind users (8% of
/// men) can't reliably distinguish red from green. We pair every amount
/// with a small leading ↓/↑ arrow icon as a non-color signal, plus the
/// `+`/`-` sign in the text itself. Set `showIcon: false` only when the
/// surrounding context already conveys direction (e.g. a row inside a
/// pill that's clearly labelled "支出").
class AmountText extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showSign;
  final bool showIcon;

  const AmountText({
    super.key,
    required this.amount,
    required this.isIncome,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.showSign = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final sign = isIncome ? '+' : '-';
    final color = isIncome ? AppColors.income : AppColors.expense;
    final text = showSign
        ? '$sign¥${amount.toStringAsFixed(2)}'
        : '¥${amount.toStringAsFixed(2)}';
    final iconData = isIncome ? Icons.south_rounded : Icons.north_rounded;
    final semantic = '${isIncome ? "收入" : "支出"} ¥${amount.toStringAsFixed(2)}';

    final amountStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Semantics(
      label: semantic,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(iconData, size: fontSize * 0.85, color: color),
            const SizedBox(width: 2),
          ],
          Text(text, style: amountStyle),
        ],
      ),
    );
  }
}
