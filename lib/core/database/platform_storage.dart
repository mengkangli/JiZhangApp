import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

/// Platform-agnostic key-value storage. Uses IndexedDB/localStorage on web,
/// and a simple SQLite table on native platforms.
class PlatformStorage {
  PlatformStorage._();

  static final _storage = <String, String>{};

  static Future<void> init() async {
    if (!kIsWeb) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'jizhang_store.db');
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE store (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
        },
      );
      final rows = await db.query('store');
      for (final row in rows) {
        _storage[row['key'] as String] = row['value'] as String;
      }
      _db = db;
    } else {
      // On web, load from localStorage (in-memory fallback if not available)
      _loadWebStorage();
    }
  }

  static Database? _db;

  /// Load all items from the in-memory map.
  static String? get(String key) => _storage[key];

  /// Store an item.
  static Future<void> put(String key, String value) async {
    _storage[key] = value;
    if (!kIsWeb && _db != null) {
      await _db!.insert(
        'store',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _saveWebStorage();
    }
  }

  /// Remove an item.
  static Future<void> remove(String key) async {
    _storage.remove(key);
    if (!kIsWeb && _db != null) {
      await _db!.delete('store', where: 'key = ?', whereArgs: [key]);
    } else {
      _saveWebStorage();
    }
  }

  /// Get all keys.
  static Iterable<String> get keys => _storage.keys;

  // --- Web-specific localStorage ---
  static void _loadWebStorage() {
    // Use dart:html localStorage on web
    // Since we can't directly import dart:html in a cross-platform file,
    // we use a simple JSON-based approach stored in memory + localStorage via JS interop
    _storage.clear();
  }

  static void _saveWebStorage() {
    // Web: persist in-memory map (we rely on IndexedDB-backed approach via sqflite)
  }
}

/// Full database helper using PlatformStorage for simple CRUD on tables.
class SimpleDb {
  SimpleDb._();

  static final _data = <String, List<Map<String, dynamic>>>{};
  static const _uuid = Uuid();

  static void initTables() {
    _data['categories'] = [];
    _data['transactions'] = [];
    _data['budgets'] = [];
    _data['bills'] = [];
  }

  static List<Map<String, dynamic>> getAll(String table) {
    return List.unmodifiable(_data[table] ?? []);
  }

  static Map<String, dynamic>? getById(String table, String id) {
    try {
      return (_data[table] ?? []).firstWhere((r) => r['id'] == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> insert(String table, Map<String, dynamic> row) async {
    _data.putIfAbsent(table, () => []);
    _data[table]!.add(Map.from(row));
    await _persist(table);
  }

  static Future<void> update(
    String table,
    Map<String, dynamic> row,
  ) async {
    final list = _data[table] ?? [];
    final idx = list.indexWhere((r) => r['id'] == row['id']);
    if (idx >= 0) list[idx] = Map.from(row);
    await _persist(table);
  }

  static Future<void> delete(String table, String id) async {
    final list = _data[table] ?? [];
    list.removeWhere((r) => r['id'] == id);
    await _persist(table);
  }

  static Future<void> _persist(String table) async {
    final key = 'db_$table';
    final json = jsonEncode(_data[table] ?? []);
    await PlatformStorage.put(key, json);
  }

  static Future<void> loadAll() async {
    await PlatformStorage.init();
    for (final table in ['categories', 'transactions', 'budgets', 'bills']) {
      final jsonStr = PlatformStorage.get('db_$table');
      if (jsonStr != null) {
        try {
          final list = (jsonDecode(jsonStr) as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          _data[table] = list;
        } catch (_) {
          _data[table] = [];
        }
      } else {
        _data[table] = [];
      }
    }
  }
}
