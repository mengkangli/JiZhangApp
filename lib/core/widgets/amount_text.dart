import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showSign;

  const AmountText({
    super.key,
    required this.amount,
    required this.isIncome,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final sign = isIncome ? '+' : '-';
    final color = isIncome ? AppColors.income : AppColors.expense;
    final text = showSign ? '$sign¥${amount.toStringAsFixed(2)}' : '¥${amount.toStringAsFixed(2)}';

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -0.3,
      ),
    );
  }
}
