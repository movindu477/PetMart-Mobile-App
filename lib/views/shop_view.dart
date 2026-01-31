import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'product_detail_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/product_grid_skeleton.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter States
  String _selectedPetType = 'All'; // All, Dog, Cat
  String _selectedAccessoryType = 'All'; // All, Toy, Food
  RangeValues _priceRange = const RangeValues(0, 10000);
  // final double _maxPrice = 10000.0; // Dynamic max would be better but this is fine for now

  final List<String> _petOptions = ['All', 'Dog', 'Cat'];
  final List<String> _accessoryOptions = ['All', 'Toy', 'Food'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      // Also optional: fetch cart to know count
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  List<Product> _filterProducts(List<Product> allProducts) {
    if (allProducts.isEmpty) return [];

    return allProducts.where((product) {
      final matchesPet =
          _selectedPetType == 'All' ||
          product.petType.toLowerCase().contains(
            _selectedPetType.toLowerCase(),
          );

      final matchesAccessory =
          _selectedAccessoryType == 'All' ||
          product.accessoriesType.toLowerCase().contains(
            _selectedAccessoryType.toLowerCase(),
          );

      final matchesPrice =
          product.price >= _priceRange.start &&
          product.price <= _priceRange.end;

      return matchesPet && matchesAccessory && matchesPrice;
    }).toList();
  }

  Future<void> _addToCart(Product product) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Login Required',
        text: 'Please login to add items to cart.',
        confirmBtnText: 'OK',
      );
      return;
    }

    try {
      await Provider.of<CartProvider>(
        context,
        listen: false,
      ).addToCart(product.id);

      if (!mounted) return;

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Added to Cart',
        text: '${product.productName} added successfully',
        autoCloseDuration: const Duration(seconds: 1),
      );
    } catch (e) {
      if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Failed to add to cart.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // We consume ProductProvider to react to changes
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    final filteredProducts = _filterProducts(products);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      endDrawer: _buildFilterDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header / Search Bar area could go here
            _buildHeroSection(),
            _buildFilterButton(),

            Expanded(
              child: productProvider.isLoading
                  ? const ProductGridSkeleton()
                  : productProvider.errorMessage != null && products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text("Error: ${productProvider.errorMessage}"),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<ProductProvider>(
                                context,
                                listen: false,
                              ).fetchProducts(refresh: true);
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : _buildProductsGrid(filteredProducts),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No products found", style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPetType = 'All';
                  _selectedAccessoryType = 'All';
                  _priceRange = const RangeValues(0, 10000);
                });
              },
              child: const Text("Clear Filters"),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70, // Taller cards
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], index);
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    final pastelColor = _getPastelColor(index);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.fullImageUrl,
                        fit: BoxFit.contain,
                        height: 100,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                            height: 100,
                            width: 100,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Rs.${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPastelColor(int index) {
    final colors = [
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFFFEBEE), // Light Red
      const Color(0xFFE0F2F1), // Light Teal
    ];
    return colors[index % colors.length];
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Found ${_filterProducts(Provider.of<ProductProvider>(context, listen: false).products).length} Items",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 18),
                  SizedBox(width: 4),
                  Text("Filters"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Pattern/Image
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'images/back3.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Decorative Circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      "PREMIUM COLLECTION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Shop Quality",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Treat your pet with the best\npremium products they deserve.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Filters",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Pet Type",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 10,
              children: _petOptions.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedPetType == type,
                  onSelected: (val) => setState(() => _selectedPetType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 10,
              children: _accessoryOptions.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedAccessoryType == type,
                  onSelected: (val) =>
                      setState(() => _selectedAccessoryType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Price Range",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 10000,
              divisions: 20,
              labels: RangeLabels(
                _priceRange.start.round().toString(),
                _priceRange.end.round().toString(),
              ),
              onChanged: (val) => setState(() => _priceRange = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Apply Filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
