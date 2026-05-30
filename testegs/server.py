"""
Apurse remote database server
Run: python server.py
Default: http://localhost:8080
"""
import sqlite3, json, os
from flask import Flask, request, jsonify

app = Flask(__name__)
DB = os.path.join(os.path.dirname(__file__), 'apurse_remote.db')

def get_db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    conn.executescript('''
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, icon_code INTEGER NOT NULL,
            color_value INTEGER NOT NULL DEFAULT 0xFFD4914A,
            type TEXT NOT NULL CHECK(type IN ('income','expense')),
            sort_order INTEGER NOT NULL DEFAULT 0, is_default INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS transactions (
            id TEXT PRIMARY KEY, amount REAL NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('income','expense')),
            category_id TEXT NOT NULL, date TEXT NOT NULL, note TEXT,
            account_id TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS budgets (
            id TEXT PRIMARY KEY, category_id TEXT NOT NULL, amount REAL NOT NULL,
            month INTEGER NOT NULL, year INTEGER NOT NULL,
            spent REAL NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS bills (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, amount REAL NOT NULL,
            category_id TEXT NOT NULL, due_day INTEGER NOT NULL CHECK(due_day BETWEEN 1 AND 31),
            is_recurring INTEGER NOT NULL DEFAULT 1, is_paid INTEGER NOT NULL DEFAULT 0,
            notification_id INTEGER, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS accounts (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT NOT NULL,
            balance REAL, icon_code INTEGER NOT NULL DEFAULT 0,
            color_value INTEGER NOT NULL DEFAULT 0xFF4A90D9,
            sort_order INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        );
    ''')
    conn.commit()
    conn.close()

@app.route('/query', methods=['POST'])
def query():
    data = request.get_json()
    table = data['table']
    columns = data.get('columns')
    where = data.get('where')
    where_args = data.get('whereArgs', [])
    order_by = data.get('orderBy')
    limit = data.get('limit')

    cols = ', '.join(columns) if columns else '*'
    sql = f'SELECT {cols} FROM {table}'
    if where:
        sql += f' WHERE {where}'
    if order_by:
        sql += f' ORDER BY {order_by}'
    if limit is not None:
        sql += f' LIMIT {limit}'

    conn = get_db()
    rows = conn.execute(sql, where_args).fetchall()
    conn.close()
    return jsonify([dict(r) for r in rows])

@app.route('/raw_query', methods=['POST'])
def raw_query():
    data = request.get_json()
    sql = data['sql']
    args = data.get('args', [])

    conn = get_db()
    rows = conn.execute(sql, args).fetchall()
    conn.close()
    return jsonify([dict(r) for r in rows])

@app.route('/insert', methods=['POST'])
def insert():
    data = request.get_json()
    table = data['table']
    row = data['row']
    columns = ', '.join(row.keys())
    placeholders = ', '.join(['?' for _ in row])
    sql = f'INSERT OR REPLACE INTO {table} ({columns}) VALUES ({placeholders})'

    conn = get_db()
    conn.execute(sql, list(row.values()))
    conn.commit()
    conn.close()
    return jsonify({'id': row.get('id', 'ok')})

@app.route('/update', methods=['POST'])
def update():
    data = request.get_json()
    table = data['table']
    row = data['row']
    where = data.get('where')
    where_args = data.get('whereArgs', [])

    sets = ', '.join([f'{k} = ?' for k in row.keys()])
    sql = f'UPDATE {table} SET {sets}'
    args = list(row.values())
    if where:
        sql += f' WHERE {where}'
        args.extend(where_args)

    conn = get_db()
    cur = conn.execute(sql, args)
    conn.commit()
    conn.close()
    return jsonify({'count': cur.rowcount})

@app.route('/delete', methods=['POST'])
def delete():
    data = request.get_json()
    table = data['table']
    where = data.get('where')
    where_args = data.get('whereArgs', [])

    sql = f'DELETE FROM {table}'
    if where:
        sql += f' WHERE {where}'

    conn = get_db()
    cur = conn.execute(sql, where_args)
    conn.commit()
    conn.close()
    return jsonify({'count': cur.rowcount})

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    init_db()
    print(f'Server running on http://localhost:8080')
    print(f'Database: {DB}')
    app.run(host='0.0.0.0', port=5000, debug=False)
