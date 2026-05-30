part of 'app_router.dart';

abstract class RouteNames {
  // Tab branches (bottom nav).
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const statistics = '/statistics';
  static const profile = '/profile';

  // Pushed routes (above the shell).
  static const addTransaction = '/transaction/add';
  static const aiScan = '/ai-scan';
  static const accounts = '/accounts';
  static const budgets = '/budgets';
  static const addBudget = '/budget/add';
  static const bills = '/bills';
  static const addBill = '/bill/add';
  static const categoryManage = '/category/manage';
  static const addCategory = '/category/add';
  static const settings = '/settings';
  static const export = '/settings/export';
}
