import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data (you can replace with dynamic list later)
    final cartItems = [
      {"name": "Dog Food", "price": 1200, "quantity": 2},
      {"name": "Cat Toy", "price": 500, "quantity": 1},
      {"name": "Bird Cage", "price": 3500, "quantity": 1},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Table title
                  const Text(
                    "Your Cart Items",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Table (Responsive)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: isLandscape
                          ? Axis.vertical
                          : Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.blue.shade100,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Product Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Price",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Quantity",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: cartItems
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(Text(item["name"].toString())),
                                  DataCell(
                                    Text("Rs. ${item["price"].toString()}"),
                                  ),
                                  DataCell(Text(item["quantity"].toString())),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Place Order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Handle order placement
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order placed successfully!"),
                          ),
                        );
                      },
                      child: const Text(
                        "Place Order",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
