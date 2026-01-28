import '../services/api_service.dart';

class CartItem {
  final int? id; // Local SQFlite ID
  final int productId;
  final String productName;
  final double price;
  final String imageUrl;
  int quantity;
  final String petType;
  final String accessoriesType;

  CartItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    required this.petType,
    required this.accessoriesType,
  });

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';

    // Normalize backslashes
    String cleanUrl = imageUrl.replaceAll(r'\', '/');

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    if (cleanUrl.startsWith('/')) {
      return "${ApiService.contentUrl}$cleanUrl";
    }

    // Handle potential double slash issues or missing storage prefix
    if (cleanUrl.startsWith('storage/') || cleanUrl.startsWith('images/')) {
      return "${ApiService.contentUrl}/$cleanUrl";
    }

    return "${ApiService.contentUrl}/storage/$cleanUrl";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId, // Maps to 'pet_id' from API usually
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'petType': petType,
      'accessoriesType': accessoriesType,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
      petType: map['petType'],
      accessoriesType: map['accessoriesType'],
    );
  }

  // Factory from API response might differ, we can add that later if needed
}
