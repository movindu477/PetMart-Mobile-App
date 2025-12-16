import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<List<dynamic>> fetchFavorites() async {
    final response = await http.get(
      Uri.parse("$baseUrl/favorites"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load favorites");
    }
  }

  static Future<void> addFavorite(int petId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/favorites"),
      headers: await _headers(),
      body: jsonEncode({"pet_id": petId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add favorite");
    }
  }

  static Future<void> removeFavorite(int petId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/favorites/$petId"),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove favorite");
    }
  }
}
