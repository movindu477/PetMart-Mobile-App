import 'package:flutter/material.dart';
import 'shop.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityZipController = TextEditingController();

  bool cashOnDelivery = false;
  bool cardPayment = false;

  double get totalAmount {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item["price"] * item["quantity"]),
    );
  }

  void placeOrder() {
    if (fullNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phoneController.text.isEmpty ||
        (!cashOnDelivery && !cardPayment)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and select a payment method',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cartItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
          },
        ),
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Cart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...cartItems.map((item) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item["name"]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item["quantity"].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "Rs ${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Total: Rs $totalAmount",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shipping Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  buildInputField("Full Name", fullNameController),
                  buildInputField("Address", addressController),
                  buildInputField(
                    "Phone Number",
                    phoneController,
                    keyboard: TextInputType.phone,
                  ),
                  buildInputField(
                    "City / Zip Code (Optional)",
                    cityZipController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text("Cash on Delivery"),
              value: cashOnDelivery,
              onChanged: (val) {
                setState(() {
                  cashOnDelivery = val!;
                  if (cashOnDelivery) cardPayment = false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Card"),
              value: cardPayment,
              onChanged: (val) {
                setState(() {
                  cardPayment = val!;
                  if (cardPayment) cashOnDelivery = false;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Place the Order",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

