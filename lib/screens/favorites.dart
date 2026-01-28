import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_detail.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

import 'package:quickalert/quickalert.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _products = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadAllData();
  }

  Future<void> _loadCachedData() async {
    try {
      final localFavs = await FavoriteService.getCachedFavorites();
      setState(() {
        _favoriteIds = localFavs;
      });
      if (localFavs.isNotEmpty)
        _loadFavoriteProducts(); // Only load if we have cached favs
    } catch (e) {
      debugPrint("LOCAL FAVORITES LOAD ERROR: $e");
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favorites = await FavoriteService.fetchFavorites();
      setState(() {
        _favoriteIds = favorites;
      });

      await _loadFavoriteProducts();
    } catch (e) {
      debugPrint("FAVORITES LOAD ERROR: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      final allProducts = await ProductService.fetchProducts();
      final favoriteProducts = allProducts
          .where((product) => _favoriteIds.contains(product.id))
          .toList();

      setState(() {
        _products = favoriteProducts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("PRODUCTS LOAD ERROR: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite(int petId) async {
    final isFav = _favoriteIds.contains(petId);

    setState(() {
      isFav ? _favoriteIds.remove(petId) : _favoriteIds.add(petId);
      if (isFav) {
        _products.removeWhere((p) => p.id == petId);
      }
    });

    // LocalFavoriteService calls removed - handled by FavoriteService internally now

    try {
      if (isFav) {
        await FavoriteService.removeFavorite(petId);
      } else {
        await FavoriteService.addFavorite(petId);
      }
    } catch (e) {
      debugPrint("Offline mode – saved locally");
    }
  }

  Future<void> _addToCart(Product product) async {
    if (!mounted) return;

    final isLoggedIn = await ApiService.isLoggedIn();
    if (!isLoggedIn) {
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
      await CartService.addToCart(
        product.id,
        productData: {
          'product_name': product.productName,
          'price': product.price,
          'image_url': product.fullImageUrl,
          'pet_type': product.petType,
          'accessories_type': product.accessoriesType,
        },
      );

      if (!mounted) return;

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Added to Cart',
        text: '${product.productName} added successfully',
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoritesPage()),
      );
    } catch (e) {
      debugPrint("Add to cart error: $e");

      if (!mounted) return;

      String errorText = 'Failed to add item to cart. Please try again.';
      if (e.toString().contains('Failed to add to cart')) {
        final parts = e.toString().split(':');
        if (parts.length > 1) {
          errorText = parts.last.trim();
        }
      }

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: errorText,
      );
    }
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);
    final bool isFav = _favoriteIds.contains(product.id);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
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
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(product.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Rs. ${product.price.toStringAsFixed(0)}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () => _addToCart(product),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          tooltip: "Back",
        ),
        title: Text(
          "Favorites",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading favorites",
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium,
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
              )
            : _products.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No favorites yet",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Add items to your favorites to see them here",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : OrientationBuilder(
                builder: (context, orientation) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: orientation == Orientation.landscape
                          ? 4
                          : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      if (index >= _products.length) {
                        return const SizedBox.shrink();
                      }
                      return _buildProductCard(_products[index]);
                    },
                  );
                },
              ),
      ),
    );
  }
}
