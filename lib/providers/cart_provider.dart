import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  double get totalAmount {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final headers = await ApiService.authHeaders();
      // Check if online
      if (headers.containsKey('Authorization')) {
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/cart'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final List<dynamic> list = data['data'];

            _cartItems = list.map((item) {
              return CartItem(
                productId: item['pet_id'],
                productName: item['product_name'],
                price: (item['price'] is int)
                    ? (item['price'] as int).toDouble()
                    : (item['price'] is String)
                    ? double.parse(item['price'])
                    : item['price'],
                imageUrl: item['image_url'],
                quantity: (item['quantity'] is int)
                    ? item['quantity']
                    : int.parse(item['quantity'].toString()),
                petType: item['pet_type'] ?? '',
                accessoriesType: item['accessories_type'] ?? '',
              );
            }).toList();

            // Cache to SQFlite
            await DatabaseHelper().clearCart();
            for (var item in _cartItems) {
              await DatabaseHelper().insertCartItem(item);
            }
          }
        }
      } else {
        // Load from local DB if no token
        _cartItems = await DatabaseHelper().getCartItems();
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      _cartItems = await DatabaseHelper().getCartItems();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cart'),
        headers: await ApiService.authHeaders(),
        body: jsonEncode({'pet_id': productId}),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      }
    } catch (e) {
      debugPrint("Add to cart error: $e");
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/cart/$productId'),
        headers: await ApiService.authHeaders(),
      );

      if (response.statusCode == 200) {
        _cartItems.removeWhere((item) => item.productId == productId);
        notifyListeners();
        // Also remove from local DB
        // But fetchCart handles full sync usually.
        // For direct DB manipulation:
        // await DatabaseHelper().deleteCartItem(productId); // Needs logic to find ID by productId

        await fetchCart(); // Reliable sync
      }
    } catch (e) {
      debugPrint("Remove from cart error: $e");
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity < 1) return;

    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/cart/$productId'),
        headers: await ApiService.authHeaders(),
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        // Optimistic local update
        final index = _cartItems.indexWhere(
          (item) => item.productId == productId,
        );
        if (index != -1) {
          _cartItems[index].quantity = quantity;
          notifyListeners();
        }
        await fetchCart(); // Ensure sync
      }
    } catch (e) {
      debugPrint("Update cart error: $e");
    }
  }
}
