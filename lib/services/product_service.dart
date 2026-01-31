import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static final String _url = "${ApiService.baseUrl}/pets";

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> productsList = [];

        if (decoded is Map) {
          productsList =
              decoded['data'] ?? decoded['pets'] ?? decoded['products'] ?? [];
        } else if (decoded is List) {
          productsList = decoded;
        }

        return productsList.map((e) => Product.fromJson(e)).toList();
      }

      if (response.statusCode == 401) {
        throw Exception("Unauthorized – please login again");
      }

      throw Exception("Failed to load products: ${response.statusCode}");
    } catch (e) {
      debugPrint("FETCH PRODUCTS ERROR: $e");
      rethrow;
    }
  }
}
