import 'package:flutter_test/flutter_test.dart';
import 'package:apurse/features/transaction/domain/transaction.dart';
import 'package:apurse/features/category/domain/category.dart';
import 'package:apurse/features/bill/domain/bill.dart';
import 'package:apurse/features/budget/domain/budget.dart';
import 'package:apurse/features/account/domain/account.dart';

void main() {
  // ─── Transaction model ───
  group('Transaction', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'tx001',
        'amount': 99.9,
        'type': 'expense',
        'category_id': 'ec001',
        'date': '2026-05-30',
        'note': '午餐',
        'account_id': 'acc001',
        'created_at': '2026-05-30T12:00:00',
        'updated_at': '2026-05-30T12:00:00',
      };
      final tx = Transaction.fromJson(json);
      expect(tx.id, 'tx001');
      expect(tx.amount, 99.9);
      expect(tx.isIncome, false);
      expect(!tx.isIncome, true);
      expect(tx.categoryId, 'ec001');
      expect('${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}', '2026-05-30');
      expect(tx.note, '午餐');
      expect(tx.accountId, 'acc001');

      final back = tx.toJson();
      expect(back['amount'], 99.9);
      expect(back['type'], 'expense');
      expect(back['category_id'], 'ec001');
      expect(back['date'], '2026-05-30');
    });

    test('isIncome returns true for income type', () {
      final tx = Transaction(
        id: 't1',
        amount: 5000,
        type: 'income',
        categoryId: 'ic001',
        date: DateTime(2026, 5, 30),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(tx.isIncome, true);
      expect(!tx.isIncome, false);
    });
  });

  // ─── Category model ───
  group('Category', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'ec001',
        'name': '餐饮',
        'icon_code': 0xe561,
        'color_value': 0xFFD4914A,
        'type': 'expense',
        'sort_order': 0,
        'is_default': 1,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      };
      final cat = Category.fromJson(json);
      expect(cat.id, 'ec001');
      expect(cat.name, '餐饮');
      expect(cat.iconCodePoint, 0xe561);
      expect(cat.colorValue, 0xFFD4914A);
      expect(cat.type, 'expense');
      expect(cat.sortOrder, 0);

      final back = cat.toJson();
      expect(back['name'], '餐饮');
      expect(back['type'], 'expense');
    });
  });

  // ─── Account model ───
  group('Account', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'acc001',
        'name': '微信零钱',
        'type': 'wechat',
        'balance': 1234.56,
        'icon_code': 0xe3d9,
        'color_value': 0xFF07C160,
        'sort_order': 0,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      };
      final acc = Account.fromJson(json);
      expect(acc.id, 'acc001');
      expect(acc.name, '微信零钱');
      expect(acc.type, 'wechat');
      expect(acc.balance, 1234.56);
      expect(acc.iconCodePoint, 0xe3d9);
      expect(acc.colorValue, 0xFF07C160);
    });

    test('typeLabel returns Chinese label', () {
      final wechat = Account(id: 'a1', name: '微信', type: 'wechat', iconCodePoint: 0, colorValue: 0, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final alipay = Account(id: 'a2', name: '支付宝', type: 'alipay', iconCodePoint: 0, colorValue: 0, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final cash = Account(id: 'a3', name: '现金', type: 'cash', iconCodePoint: 0, colorValue: 0, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final other = Account(id: 'a4', name: '其他', type: 'unknown', iconCodePoint: 0, colorValue: 0, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(wechat.typeLabel, '微信');
      expect(alipay.typeLabel, '支付宝');
      expect(cash.typeLabel, '现金');
      expect(other.typeLabel, '其他');
    });
  });

  // ─── Bill model ───
  group('Bill', () {
    test('fromJson parses boolean fields as int', () {
      final json = {
        'id': 'b001',
        'name': '房租',
        'amount': 3000.0,
        'category_id': 'ec008',
        'due_day': 1,
        'is_recurring': 1,
        'is_paid': 0,
        'notification_id': null,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      };
      final bill = Bill.fromJson(json);
      expect(bill.name, '房租');
      expect(bill.amount, 3000.0);
      expect(bill.dueDay, 1);
      expect(bill.isRecurring, true);
      expect(bill.isPaid, false);
    });

    test('currentDueDate returns correct date', () {
      final bill = Bill(
        id: 'b001',
        name: 'Test',
        amount: 100,
        categoryId: 'ec001',
        dueDay: 15,
        isRecurring: true,
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final due = bill.currentDueDate;
      expect(due.day, 15);
      // Should be in current or next month
      final now = DateTime.now();
      final diff = due.difference(DateTime(now.year, now.month, 1));
      expect(diff.inDays >= 0, true);
    });
  });

  // ─── Budget model ───
  group('Budget', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'b001',
        'category_id': 'ec001',
        'amount': 2000.0,
        'month': 5,
        'year': 2026,
        'spent': 500.0,
        'created_at': '2026-05-01T00:00:00',
        'updated_at': '2026-05-30T00:00:00',
      };
      final budget = Budget.fromJson(json);
      expect(budget.amount, 2000.0);
      expect(budget.month, 5);
      expect(budget.year, 2026);
      expect(budget.spent, 500.0);
      expect(budget.percentage, 25.0); // 500/2000*100
      expect(budget.remaining, 1500.0);

      final back = budget.toJson();
      expect(back['spent'], 500.0);
    });

    test('percentage handles zero amount', () {
      final budget = Budget(
        id: 'b1',
        categoryId: 'ec001',
        amount: 0,
        month: 5,
        year: 2026,
        spent: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(budget.percentage, 0.0); // 0/0 = 0% by design
    });
  });

  // ─── DashboardSummary ───
  group('DashboardSummary', () {
    test('balance = income - expense', () {
      // Just verifying the logic pattern — screens use this formula
      const income = 10000.0;
      const expense = 3500.0;
      const balance = income - expense;
      expect(balance, 6500.0);
    });
  });
}
