import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'homepage.dart';
import 'cart.dart';
import 'product_detail.dart';
import 'profile.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 1;

  List<Product> _products = [];
  Set<int> _favoriteIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ProductService.fetchProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });

      try {
        final favorites = await FavoriteService.fetchFavorites();
        setState(() {
          _favoriteIds = favorites
              .where((f) => f is Map && f.containsKey('pet_id'))
              .map<int>((f) {
                final petId = f['pet_id'];
                if (petId is int) return petId;
                if (petId is String) return int.tryParse(petId) ?? -1;
                return -1;
              })
              .where((id) => id != -1)
              .toSet();
        });
      } catch (e) {
        debugPrint("FAVORITES LOAD ERROR: $e");
        setState(() {
          _favoriteIds = <int>{};
        });
      }
    } catch (e) {
      debugPrint("SHOP LOAD ERROR: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite(int petId) async {
    try {
      if (_favoriteIds.contains(petId)) {
        await FavoriteService.removeFavorite(petId);
        setState(() => _favoriteIds.remove(petId));
      } else {
        await FavoriteService.addFavorite(petId);
        setState(() => _favoriteIds.add(petId));
      }
    } catch (e) {
      debugPrint("Favorite error: $e");
    }
  }

  Future<void> _addToCart(Product product) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Adding to cart',
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    Navigator.pop(context);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Added',
      text: '${product.productName} added to cart',
      autoCloseDuration: const Duration(seconds: 1),
    );
  }

  Widget _buildProductCard(Product product) {
    final bool isFav = _favoriteIds.contains(product.id);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.fullImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.broken_image, size: 40)),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                      ),
                      onPressed: () => _toggleFavorite(product.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${product.price}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => _addToCart(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                "Error loading products",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "No products available",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Check back later for new products",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const SizedBox.shrink();
        }
        return _buildProductCard(_products[index]);
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PetMart Shop"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _onItemTapped(2),
          ),
        ],
      ),
      body: _buildGrid(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.store), label: "Shop"),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
