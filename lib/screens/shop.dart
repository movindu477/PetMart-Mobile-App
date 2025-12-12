import 'package:flutter/material.dart';
import 'homepage.dart';
import 'login.dart';
import 'cart.dart';
import '../models/cart_data.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedIndex = 1;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _products = [
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

  String? _selectedPetType;
  String? _selectedAccessoryType;
  late RangeValues _priceRange;
  bool _showFilters = false;

  double get _maxPrice {
    return _products.map((p) => p['price'] as double).reduce((a, b) => a > b ? a : b);
  }

  double get _sliderMax {
    return (_maxPrice * 1.2).ceilToDouble();
  }

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(0, _sliderMax);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = globalCartItems.indexWhere(
        (item) => item['name'] == product['name'],
      );

      if (existingIndex != -1) {
        globalCartItems[existingIndex]['quantity']++;
      } else {
        globalCartItems.add({
          "name": product["name"],
          "description": product["description"],
          "price": product["price"],
          "quantity": 1,
          "image": product["imageUrl"],
        });
      }
    });

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
                "${product['name']} added to cart",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () => _onItemTapped(2),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchPet =
          _selectedPetType == null ||
          _selectedPetType!.isEmpty ||
          product['petType'] == _selectedPetType;

      final matchAcc =
          _selectedAccessoryType == null ||
          _selectedAccessoryType!.isEmpty ||
          product['accessoryType'] == _selectedAccessoryType;

      final matchPrice = (product['price'] as double) >= _priceRange.start &&
          (product['price'] as double) <= _priceRange.end;

      return matchPet && matchAcc && matchPrice;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedPetType = null;
      _selectedAccessoryType = null;
      _priceRange = RangeValues(0, _sliderMax);
    });
  }

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

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;

    return Container(
      height: isTablet ? screenHeight * 0.28 : screenHeight * 0.24,
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: 12,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              "images/mainback3.avif",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.store,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome to PetMart",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Find everything your pet needs – food, toys, accessories, and more.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double width) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.asset(
                        product["imageUrl"],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          product["name"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Flexible(
                        child: Text(
                          product["description"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "\$${product["price"].toStringAsFixed(2)}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              fontSize: 15,
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _addToCart(product),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    if (!_showFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: 12,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                    tooltip: "Close filters",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            "Pet Type",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: "Dog",
                  icon: Icons.pets,
                  isSelected: _selectedPetType == "Dog",
                  onTap: () {
                    setState(() {
                      _selectedPetType = _selectedPetType == "Dog" ? null : "Dog";
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  label: "Cat",
                  icon: Icons.pets,
                  isSelected: _selectedPetType == "Cat",
                  onTap: () {
                    setState(() {
                      _selectedPetType = _selectedPetType == "Cat" ? null : "Cat";
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            "Accessories Type",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: "Food",
                  icon: Icons.restaurant,
                  isSelected: _selectedAccessoryType == "Food",
                  onTap: () {
                    setState(() {
                      _selectedAccessoryType = _selectedAccessoryType == "Food" ? null : "Food";
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  label: "Toys",
                  icon: Icons.toys,
                  isSelected: _selectedAccessoryType == "Toys",
                  onTap: () {
                    setState(() {
                      _selectedAccessoryType = _selectedAccessoryType == "Toys" ? null : "Toys";
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            "Price Range",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: _sliderMax,
            divisions: _sliderMax.toInt(),
                labels: RangeLabels(
                  "\$${_priceRange.start.toStringAsFixed(0)}",
                  "\$${_priceRange.end.toStringAsFixed(0)}",
                ),
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Min: \$${_priceRange.start.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Max: \$${_priceRange.end.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final theme = Theme.of(context);
    final products = _filteredProducts;
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (products.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 80),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                "No products found",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Try changing your filters",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    int crossAxisCount = 2;
    double childAspectRatio = 0.70;
    double spacing = 12;

    if (width >= 1200) {
      crossAxisCount = 5;
      childAspectRatio = 0.70;
      spacing = 16;
    } else if (width >= 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.70;
      spacing = 16;
    } else if (width >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.70;
      spacing = 14;
    } else if (isLandscape) {
      crossAxisCount = 3;
      childAspectRatio = 0.70;
      spacing = 12;
    } else {
      childAspectRatio = 0.70;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing * 0.8,
        vertical: spacing * 0.5,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, width / crossAxisCount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: isTablet ? 100 : 80,
              floating: true,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 1,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "PetMart",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: isTablet ? 28 : 22,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Stack(
                    children: [
                      Icon(
                        _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                        color: _showFilters ? Theme.of(context).colorScheme.primary : null,
                      ),
                      if (_selectedPetType != null ||
                          _selectedAccessoryType != null ||
                          _priceRange.start > 0 ||
                          _priceRange.end < _sliderMax)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: "Filters",
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => _onItemTapped(2),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: "Shopping Cart",
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroSection(),
                  _buildFilterSection(),
                  _buildProductGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 72,
            indicatorColor: const Color(0xFF2196F3),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 300),
            surfaceTintColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                selectedIcon: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.store_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                selectedIcon: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: "Shop",
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                selectedIcon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: "Cart",
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.grey[600],
                  size: 24,
                ),
                selectedIcon: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
