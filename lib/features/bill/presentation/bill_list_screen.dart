import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/bill.dart';
import '../domain/bill_repository.dart';
import 'add_bill_screen.dart';

final billListProvider = FutureProvider<List<Bill>>((ref) async {
  return BillRepository().getAll();
});

class BillListScreen extends ConsumerWidget {
  const BillListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账单提醒'),
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: '暂无账单',
              subtitle: '添加定期账单，不再忘记缴费',
              actionLabel: '添加账单',
              onAction: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBillScreen()),
                );
                ref.invalidate(billListProvider);
              },
            );
          }

          final overdue = bills.where((b) => b.isOverdue).toList();
          final upcoming =
              bills.where((b) => !b.isPaid && !b.isOverdue).toList();
          final paid = bills.where((b) => b.isPaid).toList();

          return ListView(
            children: [
              if (overdue.isNotEmpty) ...[
                _sectionHeader(context, '已逾期', AppColors.expense),
                ...overdue.map((b) => _buildBillCard(context, b, ref)),
              ],
              if (upcoming.isNotEmpty) ...[
                _sectionHeader(context, '即将到期', AppColors.budgetWarning),
                ...upcoming.map((b) => _buildBillCard(context, b, ref)),
              ],
              if (paid.isNotEmpty) ...[
                _sectionHeader(context, '已支付', AppColors.income),
                ...paid.map((b) => _buildBillCard(context, b, ref)),
              ],
              AppSpacing.gapXxl,
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddBillScreen()),
          );
          ref.invalidate(billListProvider);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.gapSm,
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, Bill bill, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    Color borderColor;
    String statusLabel;
    if (bill.isPaid) {
      borderColor = AppColors.income;
      statusLabel = '已付';
    } else if (bill.isOverdue) {
      borderColor = AppColors.expense;
      statusLabel = '已逾期';
    } else {
      borderColor = AppColors.budgetWarning;
      final days = bill.daysUntilDue;
      statusLabel = days == 0 ? '今天到期' : '$days 天后到期';
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: borderColor,
            size: 22,
          ),
        ),
        title: Text(
          bill.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
            color: bill.isPaid ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Text('每月${bill.dueDay}日 · ¥${bill.amount.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusLabel,
              style: TextStyle(
                color: borderColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (bill.isPaid)
              IconButton(
                icon: const Icon(Icons.undo_rounded,
                    color: AppColors.budgetWarning, size: 22),
                onPressed: () async {
                  try {
                    await BillRepository().markUnpaid(bill.id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('操作失败，请重试')),
                      );
                    }
                  }
                  ref.invalidate(billListProvider);
                },
                tooltip: '取消已付',
              )
            else ...[
              AppSpacing.gapSm,
              IconButton(
                icon: Icon(Icons.check_circle_outline,
                    color: AppColors.income, size: 22),
                onPressed: () async {
                  try {
                    await BillRepository().markPaid(bill.id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('操作失败，请重试')),
                      );
                    }
                  }
                  ref.invalidate(billListProvider);
                },
                tooltip: '标记已付',
              ),
            ],
          ],
        ),
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('删除账单'),
              content: Text('确定要删除"${bill.name}"吗？'),
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
          if (confirm == true) {
            try {
              await BillRepository().delete(bill.id);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除失败，请重试')),
                );
              }
            }
            ref.invalidate(billListProvider);
          }
        },
      ),
    );
  }
}
