import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_cache_service.dart';

class FavoriteService {
  static const String baseUrl = "http://10.0.2.2/SSPLaravel/public/api";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<Set<int>> fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/favorites"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded['data'] ?? decoded;

        final favoriteIds = list
            .map<int>((e) {
              if (e is Map && e.containsKey('pet_id')) {
                final petId = e['pet_id'];
                return petId is int
                    ? petId
                    : int.tryParse(petId.toString()) ?? -1;
              }
              return e is int ? e : int.tryParse(e.toString()) ?? -1;
            })
            .where((id) => id != -1)
            .toSet();

        await FavoriteCacheService.cacheFavorites(favoriteIds);
        return favoriteIds;
      } else {
        return await FavoriteCacheService.getCachedFavorites();
      }
    } catch (e) {
      return await FavoriteCacheService.getCachedFavorites();
    }
  }

  static Future<void> addFavorite(int petId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/favorites"),
        headers: await _headers(),
        body: jsonEncode({"pet_id": petId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await FavoriteCacheService.addFavorite(petId);
      } else {
        await FavoriteCacheService.addFavorite(petId);
        throw Exception("Failed to add favorite");
      }
    } catch (e) {
      await FavoriteCacheService.addFavorite(petId);
      rethrow;
    }
  }

  static Future<void> removeFavorite(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/favorites/$petId"),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        await FavoriteCacheService.removeFavorite(petId);
      } else {
        await FavoriteCacheService.removeFavorite(petId);
        throw Exception("Failed to remove favorite");
      }
    } catch (e) {
      await FavoriteCacheService.removeFavorite(petId);
      rethrow;
    }
  }

  static Future<Set<int>> getCachedFavorites() async {
    return await FavoriteCacheService.getCachedFavorites();
  }
}
