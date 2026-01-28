import 'dart:convert';
import 'package:http/http.dart' as http;

import 'favorite_cache_service.dart';
import 'api_service.dart';

class FavoriteService {
  static final String baseUrl = ApiService.baseUrl;

  static Future<Set<int>> fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/favorites"),
        headers: await ApiService.authHeaders(),
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
        headers: await ApiService.authHeaders(),
        body: jsonEncode({"pet_id": petId}),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 409) {
        // 409 = Already exists
        await FavoriteCacheService.addFavorite(petId);
      } else {
        // even if api fails, we might want to keep it locally?
        // But for now let's just log and throw the actual server error
        String msg = "Failed to add favorite (${response.statusCode})";
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body['error'] ?? msg;
        } catch (_) {}

        throw Exception(msg);
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
        headers: await ApiService.authHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        // 404 = Already gone
        await FavoriteCacheService.removeFavorite(petId);
      } else {
        String msg = "Failed to remove favorite (${response.statusCode})";
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body['error'] ?? msg;
        } catch (_) {}
        throw Exception(msg);
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
