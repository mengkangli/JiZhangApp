import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../shared/providers/selected_month_provider.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  String? _categoryId;
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  final _uuid = const Uuid();
  bool _loadingCategories = true;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入预算金额')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    final month = ref.read(selectedMonthProvider);
    final now = DateTime.now();
    final budget = Budget(
      id: _uuid.v4(),
      categoryId: _categoryId!,
      amount: amount,
      month: month.month,
      year: month.year,
      spent: 0,
      createdAt: now,
      updatedAt: now,
    );

    await BudgetRepository().insert(budget);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加预算'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy年M月', 'zh_CN').format(month),
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
            ),
            AppSpacing.gapXl,
            Text('分类', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            FutureBuilder<List<Category>>(
              future: CategoryRepository().getByType('expense'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final cats = snapshot.data!;
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: cats.map((cat) {
                    final selected = cat.id == _categoryId;
                    final color = Color(cat.colorValue);
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryIcon(
                            iconCodePoint: cat.iconCodePoint,
                            color: color,
                            size: 24,
                          ),
                          AppSpacing.gapXs,
                          Text(cat.name),
                        ],
                      ),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _categoryId = cat.id;
                          _selectedCategory = cat;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            AppSpacing.gapXl,
            Text('预算金额', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '输入月预算金额',
                prefixText: '¥ ',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
