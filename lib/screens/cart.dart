import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shop.dart';

import '../services/payment_service.dart';
import '../services/cart_service.dart';
import '../services/cart_cache_service.dart';
import '../services/api_service.dart'; // For base URL if needed

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String? errorMessage;

  final double deliveryFee = 0.00;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Fetch latest cart data
  Future<void> _loadCart() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await CartService.fetchCart();
      // data should be List<dynamic>

      if (mounted) {
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load cart: $e";
        });
      }
    }
  }

  // Validate and format image URL
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;

    // Use ApiService consts if available
    if (imageUrl.startsWith('/')) {
      return "${ApiService.contentUrl}$imageUrl";
    }
    return "${ApiService.contentUrl}/$imageUrl";
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final qty = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * qty);
    });
  }

  double get totalCost => subtotal + deliveryFee;

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return; // Minimum 1

    final item = cartItems[index];
    final petId = int.tryParse(item['pet_id'].toString()) ?? 0;
    if (petId == 0) return;

    // Optimistic Update
    setState(() {
      cartItems[index]['quantity'] = newQuantity;
    });

    try {
      await CartService.updateQuantity(petId, newQuantity);
      // Optional: Update cache
      await CartCacheService.updateQuantity(petId, newQuantity);
    } catch (e) {
      // Revert on failure (or just reload)
      _loadCart();
    }
  }

  Future<void> _removeItem(int index) async {
    final item = cartItems[index];
    final petId = int.tryParse(item['pet_id'].toString()) ?? 0;
    if (petId == 0) return;

    // Optimistic Removal
    final removedItem = cartItems[index];
    setState(() {
      cartItems.removeAt(index);
    });

    try {
      await CartService.removeFromCart(petId);
      // Success, no action needed
    } catch (e) {
      // Revert if failed
      setState(() {
        cartItems.insert(index, removedItem);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to remove item")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFDFBF7); // Cream background
    const accentColor = Color.fromARGB(255, 0, 0, 0); // Orange/Coral

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShopPage()),
              );
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 3, // Give list more space
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartCard(cartItems[index], index);
                          },
                        ),
                      ),
                      Container(
                        width: 350, // Fixed width for summary in landscape
                        color: Colors.white,
                        height: double.infinity, // Full height
                        // Add scroll view for summary if needed on small heights
                        child: SingleChildScrollView(
                          child: _buildBottomSection(accentColor),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartCard(cartItems[index], index);
                          },
                        ),
                      ),
                      _buildBottomSection(accentColor),
                    ],
                  );
                }
              },
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ShopPage()),
            ),
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Go to Shop",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(Map<String, dynamic> item, int index) {
    final name = item['product_name'] ?? 'Unknown Item';
    final price = double.tryParse(item['price'].toString()) ?? 0.0;
    final qty = int.tryParse(item['quantity'].toString()) ?? 1;
    final imageUrl = _getImageUrl(item['image_url']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            // padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outline),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  "500gm", // Placeholder for weight/size if available or hardcoded
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    // Stepper
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _updateQuantity(index, qty - 1),
                            child: const Icon(Icons.remove, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "$qty",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _updateQuantity(index, qty + 1),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Promo Code removed

          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal", style: TextStyle(color: Colors.grey)),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Delivery fee removed
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Cost",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "\$${totalCost.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: accentColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                if (cartItems.isNotEmpty) {
                  // Show loading
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.loading,
                    title: 'Initiating Payment',
                    text: 'Connecting to Stripe...',
                  );

                  try {
                    await PaymentService.startPayment();

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      // Show info that browser is opening
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.info,
                        title: 'Payment Started',
                        text:
                            'Please complete the payment in the browser. You can verify the order status in the app later.',
                        confirmBtnText: 'Okay',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Payment Error',
                        text: e.toString().replaceAll('Exception:', '').trim(),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Checkout Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
