import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'database_service.dart';

class CartCacheService {
  static const String _table = 'cart';

  static Future<List<Map<String, dynamic>>> getCachedCart() async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(_table);
      return maps.map((map) {
        final productData = map['product_data'] as String?;
        final Map<String, dynamic> result = {
          'pet_id': map['pet_id'] as int,
          'quantity': map['quantity'] as int,
        };
        if (productData != null) {
          final decoded = jsonDecode(productData) as Map<String, dynamic>;
          result.addAll(decoded);
        }
        return result;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> cacheCart(List<dynamic> cartItems) async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table);

      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final item in cartItems) {
        final petId = item['pet_id'] ?? item['id'];
        if (petId == null) continue;

        final productData = jsonEncode({
          'name': item['name'] ?? item['product_name'] ?? '',
          'price': item['price'] ?? 0.0,
          'image': item['image'] ?? item['image_url'] ?? '',
          'description': item['description'] ?? '',
        });

        batch.insert(_table, {
          'pet_id': petId is int ? petId : int.tryParse(petId.toString()) ?? 0,
          'quantity': item['quantity'] ?? 1,
          'product_data': productData,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to cache cart: $e');
    }
  }

  static Future<void> addToCart(
    int petId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final db = await DatabaseService.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final existing = await db.query(
        _table,
        where: 'pet_id = ?',
        whereArgs: [petId],
      );

      if (existing.isNotEmpty) {
        await db.update(
          _table,
          {
            'quantity': (existing.first['quantity'] as int) + 1,
            'updated_at': now,
          },
          where: 'pet_id = ?',
          whereArgs: [petId],
        );
      } else {
        await db.insert(_table, {
          'pet_id': petId,
          'quantity': 1,
          'product_data': jsonEncode(productData),
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      throw Exception('Failed to add to cart cache: $e');
    }
  }

  static Future<void> removeFromCart(int petId) async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table, where: 'pet_id = ?', whereArgs: [petId]);
    } catch (e) {
      throw Exception('Failed to remove from cart cache: $e');
    }
  }

  static Future<void> updateQuantity(int petId, int quantity) async {
    try {
      final db = await DatabaseService.database;
      if (quantity <= 0) {
        await removeFromCart(petId);
      } else {
        await db.update(
          _table,
          {
            'quantity': quantity,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'pet_id = ?',
          whereArgs: [petId],
        );
      }
    } catch (e) {
      throw Exception('Failed to update cart quantity: $e');
    }
  }

  static Future<void> clearCart() async {
    try {
      final db = await DatabaseService.database;
      await db.delete(_table);
    } catch (e) {
      throw Exception('Failed to clear cart cache: $e');
    }
  }
}
