import 'package:flutter/material.dart';
import 'homepage.dart';
import 'login.dart';
import 'cart.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 1;

  // ✅ Local product list with actual images from assets
  final List<Map<String, dynamic>> _products = [
    // Dog Food Products
    {
      "name": "Premium Dog Food",
      "description": "Healthy dry food for adult dogs",
      "price": 25.99,
      "imageUrl": "images/dog_food1.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Dog Nutrition Mix",
      "description": "Complete balanced diet for dogs",
      "price": 32.50,
      "imageUrl": "images/dog_food2.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Puppy Growth Food",
      "description": "Specially formulated for puppies",
      "price": 18.75,
      "imageUrl": "images/dog_food3.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Dog Dental Care",
      "description": "Dental health food for dogs",
      "price": 22.99,
      "imageUrl": "images/dog_food4.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Senior Dog Formula",
      "description": "Special care for older dogs",
      "price": 28.45,
      "imageUrl": "images/dog_food5.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Active Dog Blend",
      "description": "High energy food for active dogs",
      "price": 26.80,
      "imageUrl": "images/dog_food6.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Grain Free Dog Food",
      "description": "Natural grain-free formula",
      "price": 35.25,
      "imageUrl": "images/dog_food7.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Weight Management",
      "description": "Light formula for weight control",
      "price": 24.99,
      "imageUrl": "images/dog_food8.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },
    {
      "name": "Hypoallergenic Food",
      "description": "For dogs with sensitive stomachs",
      "price": 38.50,
      "imageUrl": "images/dog_food9.jpg",
      "petType": "Dog",
      "accessoryType": "Food",
    },

    // Cat Food Products
    {
      "name": "Gourmet Cat Food",
      "description": "Premium wet food for cats",
      "price": 15.99,
      "imageUrl": "images/caffood3.jpg",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Indoor Cat Formula",
      "description": "Specially for indoor cats",
      "price": 19.25,
      "imageUrl": "images/caffood4.webp",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Kitten Growth Food",
      "description": "Complete nutrition for kittens",
      "price": 16.75,
      "imageUrl": "images/caffood5.webp",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Hairball Control",
      "description": "Reduces hairballs naturally",
      "price": 21.50,
      "imageUrl": "images/caffood6.webp",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Senior Cat Care",
      "description": "Special formula for older cats",
      "price": 23.99,
      "imageUrl": "images/caffood7.webp",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Weight Control Cat",
      "description": "Helps maintain healthy weight",
      "price": 18.45,
      "imageUrl": "images/caffood8.png",
      "petType": "Cat",
      "accessoryType": "Food",
    },
    {
      "name": "Natural Cat Food",
      "description": "Organic and natural ingredients",
      "price": 27.80,
      "imageUrl": "images/caffood9.webp",
      "petType": "Cat",
      "accessoryType": "Food",
    },

    // Dog Toy Products
    {
      "name": "Chew Bone Toy",
      "description": "Durable chew toy for dogs",
      "price": 12.99,
      "imageUrl": "images/dog_toy1.jpg",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Interactive Ball",
      "description": "Bouncing ball for fun playtime",
      "price": 8.50,
      "imageUrl": "images/dog_toy2.webp",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Rope Tug Toy",
      "description": "Great for tug-of-war games",
      "price": 9.75,
      "imageUrl": "images/dog_toy3.webp",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Floating Frisbee",
      "description": "Perfect for water and land play",
      "price": 14.25,
      "imageUrl": "images/dog_toy4.webp",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Squeaky Plush Toy",
      "description": "Soft plush with squeaker",
      "price": 11.99,
      "imageUrl": "images/dog_toy5.jpg",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Treat Puzzle Toy",
      "description": "Mental stimulation toy",
      "price": 16.50,
      "imageUrl": "images/dog_toy6.jpg",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Rubber Chew Toy",
      "description": "Long-lasting rubber material",
      "price": 13.25,
      "imageUrl": "images/dog_toy7.jpg",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Fetch Stick",
      "description": "Easy to throw and fetch",
      "price": 7.99,
      "imageUrl": "images/dog_toy8.webp",
      "petType": "Dog",
      "accessoryType": "Toys",
    },
    {
      "name": "Training Discs",
      "description": "For agility and training",
      "price": 19.75,
      "imageUrl": "images/dog_toy9.jpg",
      "petType": "Dog",
      "accessoryType": "Toys",
    },

    // Cat Toy Products
    {
      "name": "Feather Wand Toy",
      "description": "Interactive feather play",
      "price": 6.99,
      "imageUrl": "images/cattoy1.webp",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Catnip Mouse",
      "description": "Plush mouse with catnip",
      "price": 4.50,
      "imageUrl": "images/cattoy2.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Laser Pointer",
      "description": "Endless chasing fun",
      "price": 8.25,
      "imageUrl": "images/cattoy3.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Ball Track Toy",
      "description": "Circular ball track game",
      "price": 15.99,
      "imageUrl": "images/cattoy4.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Crinkle Ball",
      "description": "Makes fun crinkle sounds",
      "price": 3.75,
      "imageUrl": "images/cattoy5.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Interactive Tunnel",
      "description": "Collapsible play tunnel",
      "price": 22.50,
      "imageUrl": "images/cattoy6.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Scratching Post",
      "description": "Sisal rope scratching post",
      "price": 28.99,
      "imageUrl": "images/cattoy7.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Electronic Mouse",
      "description": "Moves randomly for chase",
      "price": 18.75,
      "imageUrl": "images/cattoy8.webp",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
    {
      "name": "Cat Tree House",
      "description": "Multi-level cat activity center",
      "price": 45.99,
      "imageUrl": "images/cattoy9.jpg",
      "petType": "Cat",
      "accessoryType": "Toys",
    },
  ];

  // ✅ Local cart item list (works with CartPage too)
  final List<Map<String, dynamic>> _cartItems = [];

  String? _selectedPetType;
  String? _selectedAccessoryType;

  // ✅ Add product to cart
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cartItems.add({...product, "quantity": 1});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['name']} added to cart ✅"),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            _onItemTapped(2); // Go to cart
          },
        ),
      ),
    );
  }

  // ✅ Filter products based on selected dropdowns
  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchPet =
          _selectedPetType == null ||
          _selectedPetType!.isEmpty ||
          product['petType'] == _selectedPetType;
      final matchAccessory =
          _selectedAccessoryType == null ||
          _selectedAccessoryType!.isEmpty ||
          product['accessoryType'] == _selectedAccessoryType;
      return matchPet && matchAccessory;
    }).toList();
  }

  // ✅ Handle bottom navigation
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
    }
  }

  // ✅ Top banner section
  Widget _buildSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/shop.jpg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  "Find everything your pet needs – food, toys, accessories, and more.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dropdown filter section
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPetType,
              decoration: const InputDecoration(
                labelText: "Pet Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text("All Pets")),
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
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedAccessoryType,
              decoration: const InputDecoration(
                labelText: "Accessory Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text("All Accessories")),
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Toys", child: Text("Toys")),
                DropdownMenuItem(
                  value: "Accessories",
                  child: Text("Accessories"),
                ),
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

  // ✅ Grid of products
  Widget _buildProductGrid(bool isLandscape) {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No products found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Try changing your filters",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
                    product["imageUrl"],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      product["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product["description"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${product["price"].toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _addToCart(product);
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Petmart",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSection(context),
              _buildFilters(),
              _buildProductGrid(isLandscape),
            ],
          ),
        ),
      ),
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
