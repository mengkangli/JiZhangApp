import '../../../core/database/database_constants.dart';
import '../../../core/database/database_helper.dart';
import 'account.dart';

class AccountRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Account>> getAll() async {
    final rows = await _db.query(
      DatabaseConstants.tableAccounts,
      orderBy: 'sort_order ASC',
    );
    return rows.map(Account.fromJson).toList();
  }

  Future<Account?> getById(String id) async {
    final rows = await _db.query(
      DatabaseConstants.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Account.fromJson(rows.first);
  }

  Future<void> insert(Account account) async {
    await _db.insert(DatabaseConstants.tableAccounts, account.toJson());
  }

  Future<void> update(Account account) async {
    await _db.update(
      DatabaseConstants.tableAccounts,
      account.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      DatabaseConstants.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
