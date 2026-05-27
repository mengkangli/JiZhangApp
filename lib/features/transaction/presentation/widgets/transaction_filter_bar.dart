import 'package:flutter/material.dart';

class TransactionFilterBar extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  const TransactionFilterBar({
    super.key,
    this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('全部'),
            selected: selectedType == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('支出'),
            selected: selectedType == 'expense',
            onSelected: (_) {
              onChanged(selectedType == 'expense' ? null : 'expense');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('收入'),
            selected: selectedType == 'income',
            onSelected: (_) {
              onChanged(selectedType == 'income' ? null : 'income');
            },
          ),
        ],
      ),
    );
  }
}
