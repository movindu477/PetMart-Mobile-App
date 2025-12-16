import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const baseUrl = "http://10.0.2.2/SSPLaravel/public/api";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  static Future<List<dynamic>> fetchCart() async {
    final res = await http.get(
      Uri.parse("$baseUrl/cart"),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<void> addToCart(int petId) async {
    await http.post(
      Uri.parse("$baseUrl/cart"),
      headers: await _headers(),
      body: jsonEncode({"pet_id": petId}),
    );
  }

  static Future<void> removeFromCart(int petId) async {
    await http.delete(
      Uri.parse("$baseUrl/cart/$petId"),
      headers: await _headers(),
    );
  }
}
