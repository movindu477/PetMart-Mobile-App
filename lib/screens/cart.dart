import 'package:flutter/material.dart';
import 'shop.dart';
import 'payment.dart';
import '../services/cart_service.dart';
import '../services/cart_cache_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

// This page manages the user's shopping cart, allowing them to view, update, or remove items.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // We keep track of the selected tab for the bottom nav bar
  final int _selectedIndex = 2;

  // List to hold the items currently in the cart
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String? errorMessage;

  // Since we might get image URLs from different sources, this helper ensures they are valid
  String _getImageUrl(String imageUrl) {
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

  @override
  void initState() {
    super.initState();
    // Load existing cart items when the page opens
    _loadCart();
  }

  // Fetches the latest cart items from our backend service using the CartService.
  Future<void> _loadCart() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await CartService.fetchCart();

      setState(() {
        cartItems = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Calculates the total price of all items in the cart dynamically
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      final price = double.parse(item['price'].toString());
      final qty = int.parse(item['quantity'].toString());
      return sum + (price * qty);
    });
  }

  // Updates quantity of an item. If quantity becomes 0, we ask to remove it.
  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(index);
      return;
    }

    // Show a loading spinner on the specific item being updated
    if (mounted && index < cartItems.length) {
      setState(() {
        cartItems[index]['isUpdating'] = true;
      });
    }

    try {
      final item = cartItems[index];

      final petIdValue = item['pet_id'];
      final petId = petIdValue is int
          ? petIdValue
          : int.tryParse(petIdValue.toString()) ?? 0;

      if (petId == 0) {
        throw Exception('Invalid pet ID');
      }

      // Optimistically update the UI for better UX
      if (mounted && index < cartItems.length) {
        setState(() {
          cartItems[index]['quantity'] = newQuantity;
        });
      }

      // Attempt to sync with the backend
      try {
        await CartService.updateQuantity(petId, newQuantity);
      } catch (apiError) {
        debugPrint("API update failed, updating SQLite only: $apiError");
      }

      // Also update our local cache logic
      await CartCacheService.updateQuantity(petId, newQuantity);

      // Refresh to ensure everything is in sync
      await _loadCart();
    } catch (e) {
      // If something fails, revert and show an error
      await _loadCart();

      if (!mounted) return;

      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('Exception: ')) {
        errorMessage = errorStr.split('Exception: ').last.trim();
      } else if (errorStr.contains(':')) {
        errorMessage = errorStr.split(':').skip(1).join(':').trim();
      } else {
        errorMessage = errorStr;
      }

      if (errorMessage.isEmpty ||
          errorMessage.toLowerCase() == "failed to update quantity") {
        errorMessage = "Unable to update quantity. Please try again.";
      }

      if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
        errorMessage =
            "Request timed out. Please check your connection and try again.";
      } else if (errorStr.contains('Network') || errorStr.contains('network')) {
        errorMessage = "Network error. Please check your connection.";
      } else if (errorStr.contains('Server error')) {
        errorMessage = "Server error. Please try again later.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted && index < cartItems.length) {
        setState(() {
          cartItems[index]['isUpdating'] = false;
        });
      }
    }
  }

  // Allows users to remove an item they no longer want to buy
  Future<void> _removeItem(int index) async {
    try {
      final petIdValue = cartItems[index]['pet_id'];
      final petId = petIdValue is int
          ? petIdValue
          : int.tryParse(petIdValue.toString()) ?? 0;

      if (petId == 0) {
        throw Exception('Invalid pet ID');
      }

      await CartService.removeFromCart(petId);
      await _loadCart();

      if (!mounted) return;

      // Give feedback that removal was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Item removed from cart",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      await _loadCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to remove item: ${e.toString().split(':').last.trim()}",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Removes everything from the cart - start fresh!
  Future<void> _clearCart() async {
    try {
      for (final item in cartItems) {
        final petIdValue = item['pet_id'];
        final petId = petIdValue is int
            ? petIdValue
            : int.tryParse(petIdValue.toString()) ?? 0;
        await CartService.removeFromCart(petId);
      }
      await _loadCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Cart cleared",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      await _loadCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to clear cart: ${e.toString().split(':').last.trim()}",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper widget to build each individual card item in the list
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final price = double.parse(item['price'].toString());
    final qty = int.parse(item['quantity'].toString());
    final itemTotal = price * qty;
    final isUpdating = item['isUpdating'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image thumbnail
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    item['image_url'] != null &&
                        item['image_url'].toString().isNotEmpty
                    ? Image.network(
                        _getImageUrl(item['image_url'].toString()),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 36,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 36,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['product_name'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${price.toStringAsFixed(0)}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rs. ${itemTotal.toStringAsFixed(0)}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity controls (plus/minus)
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: isUpdating
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.remove, size: 18),
                              onPressed: isUpdating
                                  ? null
                                  : () => _updateQuantity(index, qty - 1),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              iconSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: isUpdating
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.primary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      qty.toString(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),

                            IconButton(
                              icon: isUpdating
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.add, size: 18),
                              onPressed: isUpdating
                                  ? null
                                  : () => _updateQuantity(index, qty + 1),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              iconSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Delete button
                      IconButton(
                        icon: isUpdating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.error,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
                        onPressed: isUpdating ? null : () => _removeItem(index),
                        tooltip: "Remove item",
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer
                              .withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
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
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Your Cart",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            }
          },
          tooltip: "Back",
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: _clearCart,
              tooltip: "Clear cart",
            ),
        ],
      ),
      body: SafeArea(
        // Handling the various states: Loading, Error, or Success
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
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
                        "Error loading cart",
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadCart,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Cart summary header
                  if (cartItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Items",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${cartItems.length} ${cartItems.length == 1 ? 'Item' : 'Items'}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Total Amount",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs. ${totalPrice.toStringAsFixed(0)}",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: cartItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Your cart is empty",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Add items to your cart to get started",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ShopPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.store),
                                    label: const Text("Browse Products"),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              return _buildCartItem(cartItems[index], index);
                            },
                          ),
                  ),

                  if (cartItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: FilledButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentPage(cartItems: cartItems),
                              ),
                            );

                            if (result == true) {
                              _loadCart();
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                "Proceed to Checkout",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Rs. ${totalPrice.toStringAsFixed(0)}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}
