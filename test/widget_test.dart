import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jizhang/core/router/app_router.dart';

/// Cheap smoke test — just verifies the router instantiates and exposes
/// the four expected top-level branches. Full widget tests require the
/// database layer to be mocked and live in feature-specific test files.
void main() {
  test('appRouter has 4 shell branches with the new top-level routes', () {
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

  test('FAB / pushed routes are reachable from the root navigator', () {
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
}
