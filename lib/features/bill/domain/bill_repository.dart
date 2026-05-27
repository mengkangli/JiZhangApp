import '../../../core/database/database_constants.dart';
import '../../../core/database/database_helper.dart';
import 'bill.dart';

class BillRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Bill>> getAll() async {
    final rows = await _db.query(
      DatabaseConstants.tableBills,
      orderBy: 'is_paid ASC, due_day ASC',
    );
    return rows.map(Bill.fromJson).toList();
  }

  Future<List<Bill>> getUpcoming({int days = 7}) async {
    final bills = await getAll();
    bills.sort((a, b) => a.dueDay.compareTo(b.dueDay));
    return bills.where((b) => !b.isPaid && b.daysUntilDue <= days && b.daysUntilDue >= -7).toList();
  }

  Future<void> insert(Bill bill) async {
    await _db.insert(DatabaseConstants.tableBills, bill.toJson());
  }

  Future<void> update(Bill bill) async {
    await _db.update(
      DatabaseConstants.tableBills,
      bill.toJson(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      DatabaseConstants.tableBills,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markPaid(String id) async {
    await _db.update(
      DatabaseConstants.tableBills,
      {'is_paid': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markUnpaid(String id) async {
    await _db.update(
      DatabaseConstants.tableBills,
      {'is_paid': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
