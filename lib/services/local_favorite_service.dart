import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class LocalFavoriteService {
  static Future<void> add(int petId) async {
    final db = await AppDatabase.database;
    await db.insert('favorites', {
      'pet_id': petId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> remove(int petId) async {
    final db = await AppDatabase.database;
    await db.delete('favorites', where: 'pet_id = ?', whereArgs: [petId]);
  }

  static Future<Set<int>> getAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query('favorites');
    return rows.map((e) => e['pet_id'] as int).toSet();
  }
}
