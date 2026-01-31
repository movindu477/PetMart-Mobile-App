import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

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
      final List<dynamic> data = await CartService.fetchCart();
      _cartItems = data.map((item) => CartItem.fromJson(item)).toList();
      debugPrint(
        "--- CART PROVIDER: Fetched ${_cartItems.length} items from API",
      );
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearLocalCart() async {
    _cartItems = [];
    notifyListeners();
  }

  Future<void> addToCart(int petId, {int quantity = 1}) async {
    try {
      await CartService.addToCart(petId, quantity: quantity);
      await fetchCart();
    } catch (e) {
      debugPrint("Add to cart error: $e");
      rethrow;
    }
  }

  Future<void> removeFromCart(int petId) async {
    try {
      await CartService.removeFromCart(petId);
      _cartItems.removeWhere((item) => item.productId == petId);
      notifyListeners();
    } catch (e) {
      debugPrint("Remove from cart error: $e");
      rethrow;
    }
  }

  Future<void> updateQuantity(int petId, int quantity) async {
    if (quantity < 1) return;
    try {
      // Fallback strategy: Remove the item first, then add it back with the absolute new quantity.
      // This solves the issue where /cart/add is additive and /cart/update is 404.
      debugPrint(
        "--- CART PROVIDER: Syncing quantity for $petId to $quantity (Remove then Add)",
      );

      await CartService.removeFromCart(petId);
      await CartService.addToCart(petId, quantity: quantity);

      await fetchCart();
    } catch (e) {
      debugPrint("Update cart error: $e");
    }
  }
}
