import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apurse/core/constants/app_colors.dart';
import 'package:apurse/core/constants/app_spacing.dart';
import 'package:apurse/core/router/app_router.dart';
import 'package:apurse/core/theme/app_theme.dart';
import 'package:apurse/features/account/presentation/account_list_screen.dart';
import 'package:apurse/features/settings/presentation/settings_screen.dart';
import 'package:apurse/features/settings/presentation/export_screen.dart';

Widget wrapWithMaterial(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  // ─── Router structure ───
  group('Router', () {
    test('has 4 shell branches for bottom tabs', () {
      final shellRoute = appRouter.configuration.routes
          .whereType<StatefulShellRoute>()
          .single;

      expect(shellRoute.branches.length, 4);

      final paths = shellRoute.branches
          .expand((b) => b.routes.whereType<GoRoute>())
          .map((r) => r.path)
          .toList();

      expect(paths, containsAll(<String>[
        '/dashboard',
        '/transactions',
        '/statistics',
        '/profile',
      ]));
    });

    test('push routes are reachable from root navigator', () {
      final pushedPaths = appRouter.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(pushedPaths, containsAll(<String>[
        '/transaction/add',
        '/ai-scan',
        '/accounts',
        '/budgets',
        '/bills',
        '/category/manage',
        '/settings',
        '/settings/export',
      ]));
    });

    test('all 15 routes are unique', () {
      final tabRoutes = appRouter.configuration.routes
          .whereType<StatefulShellRoute>()
          .expand((s) => s.branches)
          .expand((b) => b.routes.whereType<GoRoute>())
          .map((r) => r.path);
      final pushedRoutes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path);
      final all = [...tabRoutes, ...pushedRoutes].toList();
      expect(all.toSet().length, all.length);
      expect(all.length, 15);
    });
  });

  // ─── Screen smoke tests ───
  group('Screen smoke tests', () {
    testWidgets('AccountListScreen builds with title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(wrapWithMaterial(const AccountListScreen()));
      // Should at least show the title and loading indicator
      expect(find.text('账户'), findsOneWidget);
    });

    testWidgets('SettingsScreen builds with title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(wrapWithMaterial(const SettingsScreen()));
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('ExportScreen builds with title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(wrapWithMaterial(const ExportScreen()));
      expect(find.text('导出数据'), findsOneWidget);
    });
  });

  // ─── Theme ───
  group('Theme', () {
    test('light theme uses material 3', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.light);
    });

    test('dark theme uses material 3', () {
      final theme = AppTheme.dark();
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.dark);
    });
  });

  // ─── App colors ───
  group('AppColors', () {
    test('income and expense colors are distinct', () {
      expect(AppColors.income != AppColors.expense, true);
    });
  });

  // ─── Spacing constants ───
  group('Dimensions', () {
    test('spacing values are non-zero', () {
      expect(AppSpacing.xs > 0, true);
      expect(AppSpacing.sm > 0, true);
      expect(AppSpacing.md > 0, true);
      expect(AppSpacing.lg > 0, true);
      expect(AppSpacing.xl > 0, true);
    });
  });
}
