import 'package:flutter/material.dart';
import 'homepage.dart';
import 'login.dart';
import 'cart.dart'; // ✅ import your cart page

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 1;

  // ✅ Sample Product List with Types
  final List<Map<String, String>> _allProducts = List.generate(9, (index) {
    return {
      "image": "images/dog_food${index + 1}.jpg",
      "name": "Dog Food ${index + 1}",
      "desc": "Healthy and tasty meal for dogs.",
      "petType": index % 2 == 0 ? "Dog" : "Cat",
      "accessoryType": index % 3 == 0 ? "Toys" : "Food",
    };
  });

  String? _selectedPetType;
  String? _selectedAccessoryType;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1: // Shop
        break;
      case 2: // Cart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
      case 3: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
    }
  }

  /// ✅ Section (Top Banner)
  Widget _buildSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/shop.jpg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Welcome to Petmart",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Find everything your pet needs – food, toys, accessories, and more. "
                    "We bring love and care for your furry friends.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Filtered Product Grid
  Widget _buildProductGrid(bool isLandscape) {
    final filteredProducts = _allProducts.where((product) {
      final petTypeMatch =
          _selectedPetType == null || product["petType"] == _selectedPetType;
      final accessoryMatch =
          _selectedAccessoryType == null ||
          product["accessoryType"] == _selectedAccessoryType;
      return petTypeMatch && accessoryMatch;
    }).toList();

    final crossAxisCount = isLandscape ? 4 : 2;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    product["image"]!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      product["name"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product["desc"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product["name"]} added to cart"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size.fromHeight(35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Filter Dropdowns
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Pet Type Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPetType,
              decoration: const InputDecoration(
                labelText: "Pet Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(value: "Dog", child: Text("Dog")),
                DropdownMenuItem(value: "Cat", child: Text("Cat")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPetType = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),

          // Accessory Type Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedAccessoryType,
              decoration: const InputDecoration(
                labelText: "Accessory Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Toys", child: Text("Toys")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAccessoryType = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Petmart",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Section
              _buildSection(context),

              // Filters
              _buildFilters(),

              // Product Grid
              _buildProductGrid(isLandscape),
            ],
          ),
        ),
      ),

      // ✅ Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
