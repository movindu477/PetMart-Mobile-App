import '../services/api_service.dart';

class Product {
  final int id;
  final String petType;
  final String accessoriesType;
  final double price;
  final String imageUrl;
  final String productName;

  Product({
    required this.id,
    required this.petType,
    required this.accessoriesType,
    required this.price,
    required this.imageUrl,
    required this.productName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      petType:
          json['pet_type']?.toString() ?? json['petType']?.toString() ?? '',
      accessoriesType:
          json['accessories_type']?.toString() ??
          json['accessoriesType']?.toString() ??
          '',
      price: json['price'] is double
          ? json['price']
          : json['price'] is int
          ? json['price'].toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      productName:
          json['product_name']?.toString() ??
          json['productName']?.toString() ??
          '',
    );
  }

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';

    // Normalize backslashes to forward slashes for URLs
    String cleanUrl = imageUrl.replaceAll(r'\', '/');

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    if (cleanUrl.startsWith('/')) {
      return "${ApiService.contentUrl}$cleanUrl";
    }

    if (cleanUrl.startsWith('storage/') || cleanUrl.startsWith('images/')) {
      return "${ApiService.contentUrl}/$cleanUrl";
    }

    return "${ApiService.contentUrl}/storage/$cleanUrl";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petType': petType,
      'accessoriesType': accessoriesType,
      'price': price,
      'imageUrl': imageUrl,
      'productName': productName,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      petType: map['petType'],
      accessoriesType: map['accessoriesType'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      productName: map['productName'],
    );
  }
}
