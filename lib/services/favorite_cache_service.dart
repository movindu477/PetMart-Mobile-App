import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class FavoriteCacheService {
  static const String _table = 'favorites';

  static Future<Set<int>> getCachedFavorites() async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(_table);
      return maps.map((map) => map['pet_id'] as int).toSet();
    } catch (e) {
      return <int>{};
    }
  }

  static Future<void> cacheFavorites(Set<int> favoriteIds) async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table);

      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final petId in favoriteIds) {
        batch.insert(_table, {
          'pet_id': petId,
          'created_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to cache favorites: $e');
    }
  }

  static Future<void> addFavorite(int petId) async {
    try {
      final db = await DatabaseService.database;
      await db.insert(_table, {
        'pet_id': petId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to add favorite to cache: $e');
    }
  }

  static Future<void> removeFavorite(int petId) async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table, where: 'pet_id = ?', whereArgs: [petId]);
    } catch (e) {
      throw Exception('Failed to remove favorite from cache: $e');
    }
  }

  static Future<void> clearFavorites() async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table);
    } catch (e) {
      throw Exception('Failed to clear favorites cache: $e');
    }
  }
}
