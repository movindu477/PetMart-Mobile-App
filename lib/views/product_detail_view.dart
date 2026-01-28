import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/favorite_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final localFavs = await FavoriteService.getCachedFavorites();
      if (mounted) {
        setState(() {
          _isFavorite = localFavs.contains(widget.product.id);
          _isLoadingFav = false;
        });
      }

      // Async sync
      FavoriteService.fetchFavorites().then((apiFavs) {
        if (mounted) {
          setState(() {
            _isFavorite = apiFavs.contains(widget.product.id);
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Login Required',
        confirmBtnText: 'OK',
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await FavoriteService.addFavorite(widget.product.id);
      } else {
        await FavoriteService.removeFavorite(widget.product.id);
      }
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }

  Future<void> _addToCart() async {
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

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Adding to Cart',
      text: 'Please wait...',
      barrierDismissible: false,
    );

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Add product
      await cartProvider.addToCart(widget.product.id);

      // If higher quantity needed, we can call updateQuantity
      // However, addToCart logic in provider currently is adding 1 item.
      // A better API would be addToCart(id, quantity).
      // Since I implemented updateQuantity separately, I can call it if needed.
      if (_quantity > 1) {
        await cartProvider.updateQuantity(widget.product.id, _quantity);
      }

      if (!mounted) return;
      Navigator.pop(context);

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Added to Cart',
        text: "${widget.product.productName} added to cart",
        autoCloseDuration: const Duration(seconds: 1),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
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
    const backgroundColor = Color(0xFFFDFBF7);
    const darkGreen = Color(0xFF4A5D44);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "best seller",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: 'product_${widget.product.id}',
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.product.fullImageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: backgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(true),
                      const SizedBox(width: 8),
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(false),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.productName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Stars ...
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Premium quality ${widget.product.petType}.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Text(
                        "\$${widget.product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              _buildQtyBtn(Icons.remove, () {
                                if (_quantity > 1) setState(() => _quantity--);
                              }),
                              Text(
                                "$_quantity",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              _buildQtyBtn(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _addToCart,
                                  behavior: HitTestBehavior.opaque,
                                  child: const Center(
                                    child: Text(
                                      "Add to cart",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          child: _isLoadingFav
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorite
                                      ? Colors.red
                                      : Colors.black54,
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

  Widget _buildDot(bool isActive) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.black26,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
