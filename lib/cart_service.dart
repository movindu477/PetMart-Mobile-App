// cart_service.dart
import 'cart_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.from(_cartItems);

  void addToCart(CartItem item) {
    final existingIndex = _cartItems.indexWhere((cartItem) =>
    cartItem.name == item.name &&
        cartItem.petType == item.petType &&
        item.accessoryType == item.accessoryType);

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(item);
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
  }

  double get totalPrice {
    return _cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  int get totalItems => _cartItems.length;

  int get cartItemCount => _cartItems.length;
}