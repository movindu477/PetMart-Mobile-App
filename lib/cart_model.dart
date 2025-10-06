// cart_model.dart
class CartItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String petType;
  final String accessoryType;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.petType,
    required this.accessoryType,
    this.quantity = 1,
  });

  // Convert to map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'petType': petType,
      'accessoryType': accessoryType,
      'quantity': quantity,
    };
  }

  // Create from map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      petType: map['petType'] ?? '',
      accessoryType: map['accessoryType'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  // Calculate total price for this item
  double get totalPrice => price * quantity;
}