import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_cache_service.dart';

class CartService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  static Future<void> addToCart(int petId) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/cart"),
            headers: await headers(),
            body: jsonEncode({"pet_id": petId}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Request timeout. Please check your connection.");
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      String errorMessage = "Failed to add to cart";
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage =
            errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      } catch (_) {
        errorMessage = "Server error: ${response.statusCode}";
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Unexpected error: $e");
    }
  }

  static Future<List<dynamic>> fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/cart"),
        headers: await headers(),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> cartItems = body['data'] ?? [];

        await CartCacheService.cacheCart(cartItems);
        return cartItems;
      } else {
        return await CartCacheService.getCachedCart();
      }
    } catch (e) {
      return await CartCacheService.getCachedCart();
    }
  }

  static Future<void> removeFromCart(int petId) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/cart/$petId"),
        headers: await headers(),
      );

      if (res.statusCode == 200) {
        await CartCacheService.removeFromCart(petId);
      } else {
        await CartCacheService.removeFromCart(petId);
        throw Exception("Failed to remove from cart");
      }
    } catch (e) {
      await CartCacheService.removeFromCart(petId);
      rethrow;
    }
  }

  static Future<void> updateQuantity(int petId, int quantity) async {
    await http.put(
      Uri.parse("$baseUrl/cart/$petId"),
      headers: await headers(),
      body: jsonEncode({'quantity': quantity}),
    );
  }

  static Future<List<Map<String, dynamic>>> getCachedCart() async {
    return await CartCacheService.getCachedCart();
  }

  static Future<void> syncLocalCartToApi() async {
    try {
      final localCart = await CartCacheService.getCachedCart();

      for (final item in localCart) {
        final petId = item['pet_id'] is int
            ? item['pet_id'] as int
            : int.tryParse(item['pet_id'].toString()) ?? 0;

        if (petId == 0) continue;

        try {
          // Add item to cart on API
          await addToCart(petId);

          // Update quantity if needed
          final quantity = item['quantity'] is int
              ? item['quantity'] as int
              : int.tryParse(item['quantity'].toString()) ?? 1;

          if (quantity > 1) {
            await updateQuantity(petId, quantity);
          }
        } catch (e) {
          // Continue with next item if one fails
          debugPrint("Failed to sync item $petId: $e");
        }
      }
    } catch (e) {
      debugPrint("Failed to sync local cart to API: $e");
    }
  }
}
