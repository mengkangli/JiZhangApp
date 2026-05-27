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
import '../../../core/widgets/section_header.dart';
import '../../../shared/providers/category_list_provider.dart';
import '../../../shared/providers/selected_month_provider.dart';
import '../../category/domain/category.dart';
import '../../transaction/domain/transaction.dart';
import '../../transaction/domain/transaction_repository.dart';
import '../../bill/domain/bill.dart';
import '../../bill/domain/bill_repository.dart';
import '../../budget/domain/budget.dart';
import '../../budget/domain/budget_repository.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final txRepo = TransactionRepository();
  final billRepo = BillRepository();
  final budgetRepo = BudgetRepository();

  final results = await Future.wait([
    txRepo.sumByMonth(month.year, month.month, 'income'),
    txRepo.sumByMonth(month.year, month.month, 'expense'),
    txRepo.getRecent(limit: 5),
    billRepo.getUpcoming(days: 7),
    budgetRepo.getByMonth(month.year, month.month),
  ]);

  return DashboardSummary(
    totalIncome: (results[0] as double),
    totalExpense: (results[1] as double),
    balance: (results[0] as double) - (results[1] as double),
    recentTransactions: results[2] as List<Transaction>,
    upcomingBills: results[3] as List<Bill>,
    budgets: results[4] as List<Budget>,
  );
});

class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<Transaction> recentTransactions;
  final List<Bill> upcomingBills;
  final List<Budget> budgets;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.recentTransactions,
    required this.upcomingBills,
    required this.budgets,
  });
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(sharedCategoryListProvider);

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
          icon: const Icon(Icons.document_scanner_outlined),
          tooltip: '智能记账',
          onPressed: () async {
            await context.push('/ai-scan');
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(sharedCategoryListProvider);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
      body: summaryAsync.when(
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Balance card
              SliverToBoxAdapter(
                child: _buildBalanceCard(context, summary, colorScheme),
              ),
              // Income/Expense row
              SliverToBoxAdapter(
                child: _buildIncomeExpenseRow(context, summary),
              ),

              // Budget overview
              if (summary.budgets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: '预算',
                    actionLabel: '查看全部',
                    onAction: () => context.push('/budgets'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildBudgetOverview(context, summary.budgets),
                ),
              ],

              // Upcoming bills
              if (summary.upcomingBills.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: '即将到期账单',
                    actionLabel: '查看全部',
                    onAction: () => context.push('/bills'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildUpcomingBills(context, summary.upcomingBills),
                ),
              ],

              // Recent transactions
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: '最近记录',
                  actionLabel: '查看全部',
                  onAction: () => context.push('/transactions'),
                ),
              ),
              if (summary.recentTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: '暂无记录',
                    subtitle: '点击底部 + 按钮开始记账',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = summary.recentTransactions[index];
                      final cat = categoriesAsync.valueOrNull
                          ?.where((c) => c.id == tx.categoryId)
                          .firstOrNull;
                      return _buildTransactionTile(context, tx, cat);
                    },
                    childCount: summary.recentTransactions.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败', style: TextStyle(color: colorScheme.error)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(dashboardSummaryProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    DashboardSummary summary,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE8A860)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本月结余',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          AppSpacing.gapSm,
          Text(
            '¥${summary.balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(
    BuildContext context,
    DashboardSummary summary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.incomeBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_downward_rounded,
                        color: Colors.white, size: 18),
                  ),
                  AppSpacing.gapSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('收入',
                          style: TextStyle(
                              color: AppColors.income.withValues(alpha: 0.8),
                              fontSize: 12)),
                      Text(
                        '¥${summary.totalIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.income,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.expenseBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 18),
                  ),
                  AppSpacing.gapSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('支出',
                          style: TextStyle(
                              color: AppColors.expense.withValues(alpha: 0.8),
                              fontSize: 12)),
                      Text(
                        '¥${summary.totalExpense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview(BuildContext context, List<Budget> budgets) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final pct = budget.percentage / 100;
          Color progressColor;
          if (pct >= 1) {
            progressColor = AppColors.budgetExceeded;
          } else if (pct >= 0.8) {
            progressColor = AppColors.budgetWarning;
          } else {
            progressColor = AppColors.budgetSafe;
          }

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${budget.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${budget.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    backgroundColor: progressColor.withValues(alpha: 0.15),
                    color: progressColor,
                    minHeight: 6,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  '剩余 ¥${budget.remaining.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingBills(BuildContext context, List<Bill> bills) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          final days = bill.daysUntilDue;
          final dueColor = bill.isOverdue ? AppColors.expense : AppColors.budgetWarning;

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border(left: BorderSide(color: dueColor, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${bill.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      bill.isOverdue ? '已逾期' : '${days}天后',
                      style: TextStyle(color: dueColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    Transaction tx,
    Category? cat,
  ) {
    return ListTile(
      leading: cat != null
          ? CategoryIcon(
              iconCodePoint: cat.iconCodePoint,
              color: Color(cat.colorValue),
            )
          : null,
      title: Text(cat?.name ?? '未知'),
      subtitle: tx.note != null && tx.note!.isNotEmpty
          ? Text(tx.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: AmountText(amount: tx.amount, isIncome: tx.isIncome),
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
