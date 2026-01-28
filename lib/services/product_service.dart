import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static final String _url = "${ApiService.baseUrl}/products";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> productsList;

        if (decoded is Map) {
          if (decoded.containsKey('data')) {
            productsList = decoded['data'] as List<dynamic>;
          } else if (decoded.containsKey('products')) {
            productsList = decoded['products'] as List<dynamic>;
          } else if (decoded.containsKey('pets')) {
            productsList = decoded['pets'] as List<dynamic>;
          } else {
            throw Exception(
              "Unexpected response format: missing data/products/pets key",
            );
          }
        } else if (decoded is List) {
          productsList = decoded;
        } else {
          throw Exception("Unexpected response format: ${decoded.runtimeType}");
        }

        if (productsList.isEmpty) {
          return [];
        }

        return productsList.map((e) {
          try {
            return Product.fromJson(e as Map<String, dynamic>);
          } catch (e) {
            debugPrint("Error parsing product: $e");
            rethrow;
          }
        }).toList();
      }

      if (response.statusCode == 401) {
        throw Exception("Unauthorized – please login again");
      }

      throw Exception(
        "Failed to load products (${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      debugPrint("PRODUCT SERVICE ERROR: $e");
      rethrow;
    }
  }
}
