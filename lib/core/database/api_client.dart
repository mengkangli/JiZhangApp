import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_config.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<bool> healthCheck() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/health'));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final body = <String, dynamic>{'table': table};
    if (columns != null) body['columns'] = columns;
    if (where != null) body['where'] = where;
    if (whereArgs != null) body['whereArgs'] = whereArgs;
    if (orderBy != null) body['orderBy'] = orderBy;
    if (limit != null) body['limit'] = limit;

    final resp = await http.post(
      Uri.parse('$baseUrl/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _parseList(resp);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/raw_query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sql': sql, 'args': args ?? []}),
    );
    return _parseList(resp);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/insert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'table': table, 'row': row}),
    );
    return 1;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final body = <String, dynamic>{'table': table, 'row': row};
    if (where != null) body['where'] = where;
    if (whereArgs != null) body['whereArgs'] = whereArgs;

    final resp = await http.post(
      Uri.parse('$baseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['count'] as int;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final body = <String, dynamic>{'table': table};
    if (where != null) body['where'] = where;
    if (whereArgs != null) body['whereArgs'] = whereArgs;

    final resp = await http.post(
      Uri.parse('$baseUrl/delete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['count'] as int;
  }

  List<Map<String, dynamic>> _parseList(http.Response resp) {
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
