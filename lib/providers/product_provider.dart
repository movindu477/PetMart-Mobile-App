import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({bool refresh = false}) async {
    if (_products.isNotEmpty && !refresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try fetching from offline DB first if not refreshing
      if (!refresh) {
        final localProducts = await DatabaseHelper().getProducts();
        if (localProducts.isNotEmpty) {
          _products = localProducts;
          _isLoading = false;
          notifyListeners();
          // Still fetch in background to update cache
        }
      }

      // 2. Fetch from API
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: await ApiService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> productList = data['data'];
          _products = productList
              .map((json) => Product.fromJson(json))
              .toList();

          // 3. Cache to SQFlite
          await DatabaseHelper().clearProducts();
          for (var product in _products) {
            await DatabaseHelper().insertProduct(product);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching products: $e');
      // If API fails and we haven't loaded local yet, try loading local now
      if (_products.isEmpty) {
        final localProducts = await DatabaseHelper().getProducts();
        _products = localProducts;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
