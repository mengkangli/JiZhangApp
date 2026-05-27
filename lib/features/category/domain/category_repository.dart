import '../../../core/database/database_constants.dart';
import '../../../core/database/database_helper.dart';
import 'category.dart';

class CategoryRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Category>> getAll() async {
    final rows = await _db.query(
      DatabaseConstants.tableCategories,
      orderBy: 'sort_order ASC',
    );
    return rows.map(Category.fromJson).toList();
  }

  Future<List<Category>> getByType(String type) async {
    final rows = await _db.query(
      DatabaseConstants.tableCategories,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'sort_order ASC',
    );
    return rows.map(Category.fromJson).toList();
  }

  Future<void> insert(Category category) async {
    await _db.insert(DatabaseConstants.tableCategories, category.toJson());
  }

  Future<void> update(Category category) async {
    await _db.update(
      DatabaseConstants.tableCategories,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      DatabaseConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
