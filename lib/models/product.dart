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

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    if (imageUrl.startsWith('/')) {
      return "http://10.0.2.2:8000$imageUrl";
    }

    if (imageUrl.startsWith('storage/') || imageUrl.startsWith('images/')) {
      return "http://10.0.2.2:8000/$imageUrl";
    }

    return "http://10.0.2.2:8000/storage/$imageUrl";
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
}
