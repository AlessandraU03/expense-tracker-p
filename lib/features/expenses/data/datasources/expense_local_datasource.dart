import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:tracker/features/expenses/data/models/expense_model.dart';

class ExpenseLocalDatasource {
  ExpenseLocalDatasource({this.databaseName = 'expenses.db'});

  final String databaseName;
  Database? _db;

  static const _expensesTable = 'expenses';
  static const _metaTable = 'meta';
  static const _seededKey = 'seeded';

  Future<Database> _database() async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, databaseName),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_expensesTable (
            id TEXT PRIMARY KEY,
            concept TEXT NOT NULL,
            amount_cents INTEGER NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_expenses_date ON $_expensesTable (date)',
        );
        await db.execute('''
          CREATE TABLE $_metaTable (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_expensesTable '
            'ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<bool> isSeeded() async {
    final db = await _database();
    final rows = await db.query(
      _metaTable,
      where: 'key = ?',
      whereArgs: [_seededKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> seed(List<ExpenseModel> items) async {
    final db = await _database();
    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          _expensesTable,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await txn.insert(
        _metaTable,
        {'key': _seededKey, 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<ExpenseModel>> getAll() async {
    final db = await _database();
    final rows = await db.query(_expensesTable, orderBy: 'date DESC, created_at DESC');
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<void> insert(ExpenseModel model) async {
    final db = await _database();
    await db.insert(
      _expensesTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(ExpenseModel model) async {
    final db = await _database();
    return db.update(
      _expensesTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _database();
    return db.delete(_expensesTable, where: 'id = ?', whereArgs: [id]);
  }
}
