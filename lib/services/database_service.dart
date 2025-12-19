import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'petmart.db';
  static const int _dbVersion = 1;

  static const String _favoritesTable = 'favorites';
  static const String _cartTable = 'cart';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_favoritesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER UNIQUE NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_cartTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        product_data TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(pet_id)
      )
    ''');
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(_favoritesTable);
    await db.delete(_cartTable);
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
