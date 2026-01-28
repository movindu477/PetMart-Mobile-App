import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';

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
      // First check local/cache for immediate UI
      final localFavs = await FavoriteService.getCachedFavorites();
      if (mounted) {
        setState(() {
          _isFavorite = localFavs.contains(widget.product.id);
          _isLoadingFav = false;
        });
      }

      // Then sync with API
      final apiFavs = await FavoriteService.fetchFavorites();
      if (mounted) {
        setState(() {
          _isFavorite = apiFavs.contains(widget.product.id);
        });
      }
    } catch (e) {
      debugPrint("Error checking favorites: $e");
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (!isLoggedIn) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Login Required',
        text: 'Please login to manage favorites.',
        confirmBtnText: 'OK',
      );
      return;
    }

    // Optimistic update
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
      // Revert optimism if needed, but usually fine
    }
  }

  Future<void> _addToCart() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Adding to Cart',
      text: 'Please wait...',
      barrierDismissible: false,
    );

    final isLoggedIn = await ApiService.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.pop(context); // Close loading
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
      // 1. Add item to cart
      // We wrap this to handle "already in cart" or similar if needed.
      // But typically we just call add.
      await CartService.addToCart(
        widget.product.id,
        productData: {
          'product_name': widget.product.productName,
          'price': widget.product.price,
          'image_url': widget.product.fullImageUrl,
          'pet_type': widget.product.petType,
          'accessories_type': widget.product.accessoriesType,
        },
      );

      // 2. If quantity > 1, update it immediately
      if (_quantity > 1) {
        try {
          // This assumes the API allows updating quantity by petId
          await CartService.updateQuantity(widget.product.id, _quantity);
        } catch (e) {
          debugPrint("Failed to update quantity: $e");
          // Not a blocker, we at least added the item.
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Added to Cart',
        text: "${widget.product.productName} (${_quantity}x) added to cart",
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      String errorMsg = 'Failed to add to cart. Please try again.';
      // Try to extract readable message
      if (e.toString().contains("Exception:")) {
        errorMsg = e.toString().replaceAll("Exception:", "").trim();
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: errorMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A creamy/beige background similar to the reference image
    const backgroundColor = Color(0xFFFDFBF7);
    const darkGreen = Color(0xFF4A5D44); // For the Add to Cart button

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
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  // Landscape: Left side - Image
                  Expanded(
                    flex: 1,
                    child: Hero(
                      tag: 'product_${widget.product.id}',
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: widget.product.fullImageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Landscape: Right side - Details
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(color: backgroundColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Content from details section
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
                            // reuse existing detail structure logic or copy here
                            // For simplicity, replicating key parts
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
                                      color: Color(0xFF1E1E1E),
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (var i = 0; i < 4; i++)
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFF4A5D44),
                                        size: 18,
                                      ),
                                    const Icon(
                                      Icons.star_half,
                                      color: Color(0xFF4A5D44),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "(59)",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Premium quality ${widget.product.petType} product. ${widget.product.accessoriesType} designed for comfort and style. Unpretentious early maturing variety.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "${widget.product.price.toStringAsFixed(2)}\$",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "sale",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Actions
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
                                          if (_quantity > 1)
                                            setState(() => _quantity--);
                                        }),
                                        Text(
                                          "$_quantity",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
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
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
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
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.ios_share,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Portrait mode (existing layout)
              return Column(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'product_${widget.product.id}',
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: widget.product.fullImageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: backgroundColor, // Seamless look
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  color: Color(0xFF1E1E1E),
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4A5D44),
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4A5D44),
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4A5D44),
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4A5D44),
                                  size: 18,
                                ),
                                const Icon(
                                  Icons.star_half,
                                  color: Color(0xFF4A5D44),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(59)",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Premium quality ${widget.product.petType} product. ${widget.product.accessoriesType} designed for comfort and style. Unpretentious early maturing variety.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "${widget.product.price.toStringAsFixed(2)}\$",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "sale",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    }),
                                    Text(
                                      "$_quantity",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
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
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
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
                            const SizedBox(width: 8),
                            const Icon(Icons.ios_share, color: Colors.black54),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
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
