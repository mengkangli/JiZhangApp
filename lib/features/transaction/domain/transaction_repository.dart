import '../../../core/database/database_constants.dart';
import '../../../core/database/database_helper.dart';
import 'transaction.dart';

class TransactionRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Transaction>> getAll() async {
    final rows = await _db.query(
      DatabaseConstants.tableTransactions,
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<List<Transaction>> getByMonth(int year, int month) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = '$year-${month.toString().padLeft(2, '0')}-$lastDay';

    final rows = await _db.query(
      DatabaseConstants.tableTransactions,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<double> sumByMonth(int year, int month, String type) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = '$year-${month.toString().padLeft(2, '0')}-$lastDay';

    final result = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseConstants.tableTransactions} '
      'WHERE type = ? AND date >= ? AND date <= ?',
      [type, startDate, endDate],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> sumExpenseByCategories(int year, int month) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = '$year-${month.toString().padLeft(2, '0')}-$lastDay';

    final result = await _db.rawQuery(
      'SELECT category_id, SUM(amount) as total FROM ${DatabaseConstants.tableTransactions} '
      'WHERE type = ? AND date >= ? AND date <= ? GROUP BY category_id',
      ['expense', startDate, endDate],
    );
    final map = <String, double>{};
    for (final row in result) {
      map[row['category_id'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<double> sumByCategory(String categoryId, int year, int month, String type) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = '$year-${month.toString().padLeft(2, '0')}-$lastDay';

    final result = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseConstants.tableTransactions} '
      'WHERE type = ? AND category_id = ? AND date >= ? AND date <= ?',
      [type, categoryId, startDate, endDate],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Transaction>> getRecent({int limit = 5}) async {
    final rows = await _db.query(
      DatabaseConstants.tableTransactions,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );
    return rows.map(Transaction.fromJson).toList();
  }

  Future<void> insert(Transaction tx) async {
    await _db.insert(DatabaseConstants.tableTransactions, tx.toJson());
  }

  Future<void> update(Transaction tx) async {
    await _db.update(
      DatabaseConstants.tableTransactions,
      tx.toJson(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      DatabaseConstants.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
