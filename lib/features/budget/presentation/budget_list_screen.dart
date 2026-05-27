import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/shell_tab_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../shared/providers/selected_month_provider.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';
import 'add_budget_screen.dart';

final budgetProgressListProvider =
    FutureProvider<List<BudgetProgress>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final budgets = await BudgetRepository().getByMonth(month.year, month.month);
  final catRepo = CategoryRepository();
  final allCats = await catRepo.getAll();

  final results = <BudgetProgress>[];
  for (final budget in budgets) {
    final cat = allCats.where((c) => c.id == budget.categoryId).firstOrNull;
    if (cat != null) {
      results.add(BudgetProgress(
        budget: budget,
        categoryName: cat.name,
        categoryIconCode: cat.iconCodePoint,
        categoryColorValue: cat.colorValue,
      ));
    }
  }
  return results;
});

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final progressAsync = ref.watch(budgetProgressListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ShellTabScaffold.simple(
      title: DateFormat('yyyy年M月', 'zh_CN').format(month),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: '添加预算',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
            );
            ref.invalidate(budgetProgressListProvider);
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () {
            ref
                .read(selectedMonthProvider.notifier)
                .update((state) => DateTime(state.year, state.month - 1));
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () {
            ref
                .read(selectedMonthProvider.notifier)
                .update((state) => DateTime(state.year, state.month + 1));
          },
        ),
      ],
      body: progressAsync.when(
        data: (progressList) {
          if (progressList.isEmpty) {
            return EmptyState(
              icon: Icons.savings_outlined,
              title: '暂无预算',
              subtitle: '点击下方按钮为支出类别设置预算',
              actionLabel: '添加预算',
              onAction: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
                );
                ref.invalidate(budgetProgressListProvider);
              },
            );
          }

          final hasWarning =
              progressList.any((p) => p.budget.status != 'safe');

          return ListView(
            children: [
              if (hasWarning) _buildAlertBanner(progressList, colorScheme),
              ...progressList.map((p) => _buildBudgetCard(context, p, ref)),
              AppSpacing.gapXl,
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildAlertBanner(
    List<BudgetProgress> progressList,
    ColorScheme colorScheme,
  ) {
    final exceeded =
        progressList.where((p) => p.budget.status == 'exceeded').length;
    final warning =
        progressList.where((p) => p.budget.status == 'warning').length;

    String message = '';
    if (exceeded > 0) message = '$exceeded 项预算已超支';
    if (warning > 0) message += '${message.isEmpty ? '' : '，'}$warning 项接近上限';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: exceeded > 0
            ? AppColors.expenseBg
            : AppColors.budgetWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(
          color: exceeded > 0 ? AppColors.expense : AppColors.budgetWarning,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: exceeded > 0 ? AppColors.expense : AppColors.budgetWarning,
            size: 20,
          ),
          AppSpacing.gapSm,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: exceeded > 0 ? AppColors.expense : AppColors.budgetWarning,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    BudgetProgress progress,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final budget = progress.budget;
    final pct = budget.percentage / 100;
    final color = Color(progress.categoryColorValue);

    Color progressColor;
    if (pct >= 1) {
      progressColor = AppColors.budgetExceeded;
    } else if (pct >= 0.8) {
      progressColor = AppColors.budgetWarning;
    } else {
      progressColor = AppColors.budgetSafe;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(
                  iconCodePoint: progress.categoryIconCode,
                  color: color,
                  size: 44,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.categoryName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      AppSpacing.gapXs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '已用 ¥${budget.spent.toStringAsFixed(0)} / ¥${budget.amount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${budget.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: progressColor.withValues(alpha: 0.12),
                color: progressColor,
                minHeight: 8,
              ),
            ),
            AppSpacing.gapXs,
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                budget.status == 'exceeded'
                    ? '超出 ¥${(-budget.remaining).toStringAsFixed(0)}'
                    : '剩余 ¥${budget.remaining.toStringAsFixed(0)}',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
