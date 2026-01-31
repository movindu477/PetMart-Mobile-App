import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CartService {
  static final String _baseUrl = ApiService.baseUrl;

  static Future<void> addToCart(int petId, {int quantity = 1}) async {
    try {
      final headers = await ApiService.getHeaders();
      final body = jsonEncode({"pet_id": petId, "quantity": quantity});
      debugPrint(
        "--- CART SERVICE: Adding to cart. URL: $_baseUrl/cart/add, Body: $body",
      );

      final response = await http.post(
        Uri.parse("$_baseUrl/cart/add"),
        headers: headers,
        body: body,
      );

      debugPrint(
        "--- CART SERVICE: Add to cart Status: ${response.statusCode}, Body: ${response.body}",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to add to cart: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ADD TO CART ERROR: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/cart"),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        debugPrint("FETCH CART SUCCESS (Status 200): ${response.body}");
        if (response.body.isEmpty) return [];

        final dynamic body = jsonDecode(response.body);

        // Try to find the list in common Laravel wrapper keys
        if (body is List) return body;
        if (body is Map) {
          if (body['data'] is List) return body['data'];
          if (body['items'] is List) return body['items'];
          if (body['cart'] is List) return body['cart'];

          // Check inside data wrapper
          final dynamic data = body['data'];
          if (data is Map) {
            if (data['items'] is List) return data['items'];
            if (data['cart'] is List) return data['cart'];
          }
        }
        return [];
      } else {
        debugPrint(
          "FETCH CART FAILED: ${response.statusCode} - ${response.body}",
        );
      }
      return [];
    } catch (e) {
      debugPrint("FETCH CART ERROR: $e");
      return [];
    }
  }

  static Future<void> removeFromCart(int petId) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/cart/remove"),
        headers: await ApiService.getHeaders(),
        body: jsonEncode({"pet_id": petId}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to remove from cart");
      }
    } catch (e) {
      debugPrint("REMOVE FROM CART ERROR: $e");
      rethrow;
    }
  }
}
