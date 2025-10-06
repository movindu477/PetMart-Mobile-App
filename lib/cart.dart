import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // ✅ Simple in-page cart list (instead of using cart_model or cart_service)
  List<Map<String, dynamic>> cartItems = [
    {
      "name": "Dog Food 1",
      "description": "Healthy meal for dogs",
      "price": 15.00,
      "quantity": 1,
      "image": "images/dog_food1.jpg",
    },
    {
      "name": "Cat Toy",
      "description": "Fun toy for cats",
      "price": 8.50,
      "quantity": 2,
      "image": "images/dog_food2.jpg",
    },
  ];

  // ✅ Calculate total price
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  // ✅ Update quantity
  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
      });
    }
  }

  // ✅ Remove item
  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item removed from cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ Clear entire cart
  void _clearCart() {
    setState(() {
      cartItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cart cleared"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ Build single cart item widget
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${item['price'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () =>
                          _updateQuantity(index, item['quantity'] - 1),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item['quantity'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () =>
                          _updateQuantity(index, item['quantity'] + 1),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                Text(
                  "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Delete
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        backgroundColor: Colors.blue,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Cart Summary
            if (cartItems.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items: ${cartItems.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total: \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Cart Items
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Your cart is empty",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index], index);
                      },
                    ),
            ),

            // ✅ Place Order
            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Order placed for ${cartItems.length} items! Total: \$${totalPrice.toStringAsFixed(2)}",
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    setState(() {
                      cartItems.clear();
                    });
                  },
                  child: const Text(
                    "Place Order",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
