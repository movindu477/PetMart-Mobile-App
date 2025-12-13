class Product {
  final int id;
  final String petType;
  final String accessoriesType;
  final String productName;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.petType,
    required this.accessoriesType,
    required this.productName,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      petType: json['pet_type'],
      accessoriesType: json['accessories_type'],
      productName: json['product_name'],
      imageUrl: json['image_url'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": productName,
      "price": price,
      "imageUrl": imageUrl,
      "petType": petType,
      "accessoryType": accessoriesType,
    };
  }
}
