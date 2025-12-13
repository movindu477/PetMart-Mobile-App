import 'package:flutter/material.dart';
import 'homepage.dart';
import 'login.dart';
import 'cart.dart';
import '../models/cart_data.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 1;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  String? _selectedPetType;
  String? _selectedAccessoryType;
  late RangeValues _priceRange;
  bool _showFilters = false;

  double get _maxPrice {
    if (_products.isEmpty) return 0;
    return _products
        .map((p) => p['price'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  double get _sliderMax => (_maxPrice * 1.2).ceilToDouble();

  @override
  void initState() {
    super.initState();
    _priceRange = const RangeValues(0, 5000);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final apiProducts = await ProductService.fetchProducts();
      setState(() {
        _products = apiProducts.map((p) => p.toMap()).toList();
        _priceRange = RangeValues(0, _sliderMax);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex =
      globalCartItems.indexWhere((item) => item['name'] == product['name']);

      if (existingIndex != -1) {
        globalCartItems[existingIndex]['quantity']++;
      } else {
        globalCartItems.add({
          "name": product["name"],
          "price": product["price"],
          "quantity": 1,
          "image": product["imageUrl"],
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['name']} added to cart"),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => _onItemTapped(2),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchPet =
          _selectedPetType == null || product['petType'] == _selectedPetType;
      final matchAcc = _selectedAccessoryType == null ||
          product['accessoryType'] == _selectedAccessoryType;
      final matchPrice = (product['price'] as double) >= _priceRange.start &&
          (product['price'] as double) <= _priceRange.end;
      return matchPet && matchAcc && matchPrice;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedPetType = null;
      _selectedAccessoryType = null;
      _priceRange = RangeValues(0, _sliderMax);
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CartPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
        break;
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              "http://10.0.2.2/SSPLaravel/public/${product['imageUrl']}",
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2));
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 40);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                Text("\$${product['price']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: Text("No products found")),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _buildProductCard(products[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text("PetMart"),
              pinned: true,
              actions: [
                IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => _onItemTapped(2))
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildProductGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
