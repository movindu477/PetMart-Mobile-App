import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../providers/cart_provider.dart';
import '../services/stripe_service.dart';
import '../services/api_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({super.key, required this.cartItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    // Check if details are filled
    if (fullNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      _showError('Please fill in all details.');
      return;
    }

    // Process the stripe card payment
    String? paymentIntentId;
    try {
      paymentIntentId = await StripeService.confirmPaymentWithCardField(
        totalAmount,
      );
      if (paymentIntentId == null) {
        return;
      }
    } catch (e) {
      _showError('Stripe Error: $e');
      return;
    }

    if (!mounted) return;

    try {
      final success = await OrderService.checkout(
        fullName: fullNameController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        phone: phoneController.text.trim(),
        paymentMethod: 'card',
        paymentIntentId: paymentIntentId,
      );

      if (success) {
        _clearCartAndCache();

        if (!mounted) return;

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success!',
          text:
              'Your order of \$${totalAmount.toStringAsFixed(2)} has been placed.',
          autoCloseDuration: const Duration(seconds: 2),
        );

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _showError('Failed to place order. Please try again.');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    String cleanMsg = message.replaceAll('Exception:', '').trim();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: cleanMsg,
    );
  }

  Future<void> _clearCartAndCache() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlack = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order overview
              _buildSectionTitle("Order Summary"),
              const SizedBox(height: 12),
              _buildSummarySection(),
              const SizedBox(height: 24),

              // Card details section
              _buildSectionTitle("Payment Method"),
              const SizedBox(height: 12),
              _buildLabel('Card Information'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: CardField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              _buildSecurityBadge(),
              const SizedBox(height: 32),

              _buildLabel('Account Holder Name'),
              const SizedBox(height: 8),
              TextField(
                controller: fullNameController,
                onChanged: (val) => setState(() {}),
                decoration: _inputDecoration(hint: 'Enter your name'),
              ),
              const SizedBox(height: 24),

              // Shipping info
              _buildSectionTitle("Shipping Details"),
              const SizedBox(height: 12),
              _buildLabel('Address'),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: _inputDecoration(hint: '123 Main St'),
              ),
              const SizedBox(height: 16),
              _buildLabel('City'),
              const SizedBox(height: 8),
              TextField(
                controller: cityController,
                decoration: _inputDecoration(hint: 'Enter city'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(hint: '+1 234 567 890'),
              ),

              const SizedBox(height: 40),

              // Pay button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Pay \$${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          ...widget.cartItems.map((item) {
            final double price = item["price"] is double
                ? item["price"]
                : double.tryParse(item["price"].toString()) ?? 0.0;
            final int quantity = item["quantity"] is int
                ? item["quantity"]
                : int.tryParse(item["quantity"].toString()) ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item["image_url"] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Icon(Icons.pets, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["product_name"] ?? "Product",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Quantity: $quantity",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\$${(price * quantity).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "\$${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.green[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Your payment is secure and encrypted by Stripe.",
              style: TextStyle(color: Colors.green[800], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E1E1E),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      counterText: '',
      suffixIcon: suffixIcon,
    );
  }
}
