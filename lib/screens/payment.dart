import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Order Fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityZipController = TextEditingController();

  // Card Fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // State
  bool _saveCard = true;
  bool _isCardPayment = true; // Toggle for Cash fallback

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
    phoneController.dispose();
    cityZipController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    // Basic Validation
    if (fullNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      _showError('Please fill in all shipping details.');
      return;
    }

    if (_isCardPayment) {
      if (_cardNumberController.text.length < 16 ||
          _expiryDateController.text.isEmpty ||
          _cvvController.text.length < 3) {
        _showError('Please check your card details.');
        return;
      }
    }

    if (!mounted) return;

    // Show loading or just proceed
    // (Ideally show a loader, but QuickAlert might handle blocking interaction? Not really, let's just await)

    try {
      await OrderService.placeOrder(
        fullName: fullNameController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        cityZip: cityZipController.text.trim().isNotEmpty
            ? cityZipController.text.trim()
            : null,
        paymentMethod: _isCardPayment ? 'card' : 'cash',
        cartItems: widget.cartItems,
        totalAmount: totalAmount,
      );

      // Clear logic
      _clearCartAndCache();

      if (!mounted) return;

      // Show success
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
      // Clear from API
      for (final item in widget.cartItems) {
        final petId = item['pet_id'] is int
            ? item['pet_id'] as int
            : int.tryParse(item['pet_id'].toString()) ?? 0;
        if (petId > 0) {
          // Fire and forget or await
          await CartService.removeFromCart(petId);
        }
      }
      // Clear Local
      await CartCacheService.clearCart();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Design Colors
    const Color primaryBlue = Color(0xFF5D5FEF); // Purple/Blue tone from image
    const Color cardDarkBlue = Color(0xFF0A2647);
    const Color cardLightBlue = Color(0xFF144272);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Card',
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
              const SizedBox(height: 12),

              if (_isCardPayment) ...[
                // 2. Visual Credit Card
                _buildCreditCard(cardDarkBlue, cardLightBlue),
                const SizedBox(height: 32),

                // 3. Card Form
                _buildLabel('Card Number'),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (val) => setState(() {}),
                  decoration: _inputDecoration(
                    hint: '1234 5678 9000 0000',
                    suffixIcon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.grey[400],
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Account Holder Name'),
              const SizedBox(height: 8),
              TextField(
                controller: fullNameController,
                onChanged: (val) => setState(() {}),
                decoration: _inputDecoration(hint: 'Wahib Khan Lohani'),
              ),
              const SizedBox(height: 16),

              if (_isCardPayment) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Expiry Date'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.datetime,
                            onChanged: (val) => setState(() {}),
                            maxLength: 5,
                            decoration: _inputDecoration(
                              hint: '12/28',
                              suffixIcon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CVV'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            decoration: _inputDecoration(hint: '224'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _saveCard = !_saveCard),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _saveCard ? primaryBlue : Colors.transparent,
                          border: Border.all(
                            color: _saveCard ? primaryBlue : Colors.grey[400]!,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Save Card Information',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // 4. Shipping Details (Collapsible or just below)
              Text(
                "Shipping Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Address'),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: _inputDecoration(hint: '123 Main St, City'),
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

              // 5. Pay Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Save & Pay \$${totalAmount.toStringAsFixed(2)}",
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

  Widget _buildCreditCard(Color startColor, Color endColor) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Debit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text(
                    "ESCObank",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.grid_3x3,
                  color: Colors.black26,
                  size: 20,
                ), // Simulated chip
              ),
              const Spacer(),
              const Icon(Icons.wifi, color: Colors.white, size: 28),
            ],
          ),
          Text(
            _cardNumberController.text.isEmpty
                ? "1234 5678 9000 0000"
                : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Card Holder",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullNameController.text.isEmpty
                        ? "Wahib Khan Lohani"
                        : fullNameController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Expiry Date",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryDateController.text.isEmpty
                        ? "12/28"
                        : _expiryDateController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Mastercard Logo Simulation
              SizedBox(
                width: 40,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red.withOpacity(0.8),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.orange.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        borderSide: const BorderSide(color: Color(0xFF5D5FEF), width: 1.5),
      ),
      counterText: '',
      suffixIcon: suffixIcon,
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
