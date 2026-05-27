import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transaction/presentation/transaction_list_screen.dart';
import '../../features/transaction/presentation/add_transaction_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/budget/presentation/budget_list_screen.dart';
import '../../features/bill/presentation/bill_list_screen.dart';
import '../../features/category/presentation/category_management_screen.dart';
import '../../features/category/presentation/add_category_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/export_screen.dart';
import '../../features/budget/presentation/add_budget_screen.dart';
import '../../features/bill/presentation/add_bill_screen.dart';
import '../../features/ai_scan/presentation/ai_scan_screen.dart';
import '../../features/account/presentation/account_list_screen.dart';
import '../../features/user/data/user_service.dart';
import '../../features/user/presentation/edit_profile_screen.dart';
import 'scaffold_key.dart';

part 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budgets',
              builder: (context, state) => const BudgetListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountListScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/ai-scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiScanScreen(),
    ),
    GoRoute(
      path: '/transaction/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/statistics',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/transactions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TransactionListScreen(),
    ),
    GoRoute(
      path: '/bills',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BillListScreen(),
    ),
    GoRoute(
      path: '/bill/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddBillScreen(),
    ),
    GoRoute(
      path: '/category/manage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CategoryManagementScreen(),
    ),
    GoRoute(
      path: '/category/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddCategoryScreen(),
    ),
    GoRoute(
      path: '/budget/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddBudgetScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/export',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExportScreen(),
    ),
  ],
);

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  UserProfile _profile = UserProfile();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await UserService.load();
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _editProfile() async {
    Navigator.of(context).pop();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (result == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: shellScaffoldKey,
      body: widget.navigationShell,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_profile.avatar, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(_profile.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_profile.monthlyBudget > 0)
                    Text('月预算: ¥${_profile.monthlyBudget.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                ],
              ),
            ),
            _drawerItem(
              context,
              icon: Icons.home_rounded,
              label: '首页',
              index: 0,
            ),
            _drawerItem(
              context,
              icon: Icons.bar_chart_rounded,
              label: '统计',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/statistics');
              },
            ),
            _drawerItem(
              context,
              icon: Icons.description_rounded,
              label: '提醒',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/bills');
              },
            ),
            const Divider(),
            _drawerItem(
              context,
              icon: Icons.person_rounded,
              label: '编辑资料',
              onTap: _editProfile,
            ),
            _drawerItem(
              context,
              icon: Icons.category_rounded,
              label: '分类管理',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/category/manage');
              },
            ),
            _drawerItem(
              context,
              icon: Icons.settings_rounded,
              label: '设置',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            _drawerItem(
              context,
              icon: Icons.ios_share_rounded,
              label: '数据导出',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings/export');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai-scan'),
        tooltip: '智能记账',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz_rounded),
            label: '账单',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: '预算',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: '账户',
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    int? index,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final shell = widget.navigationShell;
    final selected = index != null && shell.currentIndex == index;

    return ListTile(
      leading: Icon(icon, color: selected ? colorScheme.primary : null),
      title: Text(label,
          style: selected
              ? TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)
              : null),
      selected: selected,
      onTap: onTap ??
          () {
            shell.goBranch(index!);
            Navigator.of(context).pop();
          },
    );
  }
}
