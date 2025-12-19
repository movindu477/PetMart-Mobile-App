import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../services/order_service.dart';
import '../services/cart_cache_service.dart';
import '../services/cart_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({super.key, required this.cartItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityZipController = TextEditingController();

  String? _selectedPaymentMethod;

  double get totalAmount {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = item["price"] is double
          ? item["price"] as double
          : double.tryParse(item["price"].toString()) ?? 0.0;
      final quantity = item["quantity"] is int
          ? item["quantity"] as int
          : int.tryParse(item["quantity"].toString()) ?? 1;
      return sum + (price * quantity);
    });
  }

  Future<void> placeOrder() async {
    // Validate form
    if (fullNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please fill all required fields and select a payment method',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    try {
      // Place order on API with all details
      await OrderService.placeOrder(
        fullName: fullNameController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        cityZip: cityZipController.text.trim().isNotEmpty
            ? cityZipController.text.trim()
            : null,
        paymentMethod: _selectedPaymentMethod!,
        cartItems: widget.cartItems,
        totalAmount: totalAmount,
      );

      // Clear cart from API
      try {
        for (final item in widget.cartItems) {
          final petId = item['pet_id'] is int
              ? item['pet_id'] as int
              : int.tryParse(item['pet_id'].toString()) ?? 0;
          if (petId > 0) {
            await CartService.removeFromCart(petId);
          }
        }
      } catch (e) {
        debugPrint("Failed to clear cart from API: $e");
      }

      // Clear cart cache
      await CartCacheService.clearCart();

      if (!mounted) return;

      // Show success message
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Order Placed!',
        text: 'Your order has been placed successfully',
        autoCloseDuration: const Duration(seconds: 2),
      );

      if (!mounted) return;

      // Navigate back to cart with refresh flag
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Extract error message
      String errorMessage = "Failed to place order. Please try again.";
      final errorStr = e.toString();

      if (errorStr.contains('Exception: ')) {
        errorMessage = errorStr.split('Exception: ').last.trim();
      } else if (errorStr.contains(':')) {
        errorMessage = errorStr.split(':').skip(1).join(':').trim();
      }

      // Check for specific error types
      if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
        errorMessage =
            "Request timed out. Please check your connection and try again.";
      } else if (errorStr.contains('Network') || errorStr.contains('network')) {
        errorMessage = "Network error. Please check your connection.";
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Order Failed',
        text: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartItems = widget.cartItems;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: "Back",
        ),
        title: Text(
          'Payment',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Order Summary",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...cartItems.map((item) {
                        final price = item["price"] is double
                            ? item["price"] as double
                            : double.tryParse(item["price"].toString()) ?? 0.0;
                        final quantity = item["quantity"] is int
                            ? item["quantity"] as int
                            : int.tryParse(item["quantity"].toString()) ?? 1;
                        final itemTotal = price * quantity;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["product_name"] ??
                                          item["name"] ??
                                          "Product",
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      "Qty: ${item["quantity"]}",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "\$${itemTotal.toStringAsFixed(2)}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "\$${totalAmount.toStringAsFixed(2)}",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Shipping Details",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildInputField("Full Name", fullNameController, theme),
                      buildInputField("Address", addressController, theme),
                      buildInputField(
                        "Phone Number",
                        phoneController,
                        theme,
                        keyboard: TextInputType.phone,
                      ),
                      buildInputField(
                        "City / Zip Code (Optional)",
                        cityZipController,
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Payment Method",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<String>(
                        title: const Text("Cash on Delivery"),
                        value: "cash",
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text("Card Payment"),
                        value: "card",
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: placeOrder,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    "Place Order - \$${totalAmount.toStringAsFixed(2)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    cityZipController.dispose();
    super.dispose();
  }

  Widget buildInputField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
