import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/shell_tab_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../shared/providers/category_list_provider.dart';
import '../../../shared/providers/selected_month_provider.dart';
import '../../category/domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';
import 'add_transaction_screen.dart';

final transactionsByMonthProvider =
    FutureProvider.family<List<Transaction>, DateTime>((ref, month) async {
  return TransactionRepository().getByMonth(month.year, month.month);
});

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final transactionsAsync = ref.watch(transactionsByMonthProvider(month));
    final colorScheme = Theme.of(context).colorScheme;

    return ShellTabScaffold(
      title: GestureDetector(
        onTap: () => _pickMonth(context, ref),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('yyyy年M月', 'zh_CN').format(month),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurface),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: ref.read(selectedMonthProvider).year <= 2020 &&
                  ref.read(selectedMonthProvider).month <= 1
              ? null
              : () {
                  ref.read(selectedMonthProvider.notifier).update(
                      (state) => DateTime(state.year, state.month - 1));
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: ref.read(selectedMonthProvider).year >= 2030 &&
                  ref.read(selectedMonthProvider).month >= 12
              ? null
              : () {
                  ref.read(selectedMonthProvider.notifier).update(
                      (state) => DateTime(state.year, state.month + 1));
                },
        ),
      ],
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: '本月暂无记录',
              subtitle: '点击下方 + 按钮记一笔',
              actionLabel: '记一笔',
              onAction: () => context.push('/transaction/add'),
            );
          }
          return _buildTransactionList(context, transactions, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<Transaction> transactions,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final grouped = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = DateFormat('MM月dd日 EEEE', 'zh_CN').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final categoriesAsync = ref.watch(sharedCategoryListProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final txs = grouped[dateKey]!;

        final dailyTotal = txs.fold<double>(
          0,
          (sum, tx) => sum + (tx.isIncome ? tx.amount : -tx.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '¥${dailyTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: dailyTotal >= 0
                          ? AppColors.income
                          : AppColors.expense,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...txs.map((tx) => _buildTransactionCard(
                  context,
                  tx,
                  categoriesAsync.valueOrNull,
                  ref,
                )),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction tx,
    List<Category>? categories,
    WidgetRef ref,
  ) {
    final category = categories?.where((c) => c.id == tx.categoryId).firstOrNull;
    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: AppColors.expense,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除记录'),
            content: const Text('确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除',
                    style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        try {
          await TransactionRepository().delete(tx.id);
          ref.invalidate(transactionsByMonthProvider);
        } catch (_) {
          ref.invalidate(transactionsByMonthProvider);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: ListTile(
          leading: category != null
              ? CategoryIcon(
                  iconCodePoint: category.iconCodePoint,
                  color: Color(category.colorValue),
                )
              : null,
          title: Text(
            category?.name ?? '未知分类',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: tx.note != null && tx.note!.isNotEmpty
              ? Text(
                  tx.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : null,
          trailing: AmountText(
            amount: tx.amount,
            isIncome: tx.isIncome,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _pickMonth(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedMonthProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ref
          .read(selectedMonthProvider.notifier)
          .update((_) => DateTime(picked.year, picked.month));
    }
  }
}
