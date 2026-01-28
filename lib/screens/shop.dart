import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'homepage.dart';
import 'cart.dart';
import 'product_detail.dart';
import 'profile.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Products and favorites state
  List<Product> _products = [];
  Set<int> _favoriteIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Filter States
  String _selectedPetType = 'All'; // All, Dog, Cat
  String _selectedAccessoryType = 'All'; // All, Toy, Food
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000.0;
  bool _filtersVisible = true;

  // Predefined options
  final List<String> _petOptions = ['All', 'Dog', 'Cat'];
  final List<String> _accessoryOptions = ['All', 'Toy', 'Food'];

  List<Product> get _filteredProducts {
    return _products.where((product) {
      // Filter logic
      final matchesPet =
          _selectedPetType == 'All' ||
          product.petType.toLowerCase().contains(
            _selectedPetType.toLowerCase(),
          );

      final matchesAccessory =
          _selectedAccessoryType == 'All' ||
          product.accessoriesType.toLowerCase().contains(
            _selectedAccessoryType.toLowerCase(),
          );

      final matchesPrice =
          product.price >= _priceRange.start &&
          product.price <= _priceRange.end;

      return matchesPet && matchesAccessory && matchesPrice;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Load initial data for the shop
    _loadLocalFavorites();
    _loadAllData();
  }

  // Load favorites from cache for offline support
  Future<void> _loadLocalFavorites() async {
    try {
      final localFavs = await FavoriteService.getCachedFavorites();
      setState(() {
        _favoriteIds = localFavs;
      });
    } catch (e) {
      debugPrint("LOCAL FAVORITES LOAD ERROR: $e");
    }
  }

  // Fetch fresh data from API
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ProductService.fetchProducts();

      setState(() {
        _products = products;

        // Calculate max price from products for dynamic range
        if (products.isNotEmpty) {
          double max = 0;
          for (var p in products) {
            if (p.price > max) max = p.price;
          }
          // Add a little buffer
          _maxPrice = (max > 0) ? max : 10000.0;
          _priceRange = RangeValues(0, _maxPrice);
        }

        _isLoading = false;
      });

      try {
        final favorites = await FavoriteService.fetchFavorites();
        setState(() {
          _favoriteIds = favorites;
        });
      } catch (e) {
        debugPrint("FAVORITES LOAD ERROR: $e");
      }
    } catch (e) {
      debugPrint("SHOP LOAD ERROR: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Adds or removes an item from favorites.
  Future<void> _toggleFavorite(int petId) async {
    final isFav = _favoriteIds.contains(petId);

    // Optimistically update the UI
    setState(() {
      isFav ? _favoriteIds.remove(petId) : _favoriteIds.add(petId);
    });

    if (isFav) {
      // Optimistic update handled by setState above
    } else {
      // Optimistic update handled by status above
    }

    // Sync with backend
    try {
      if (isFav) {
        await FavoriteService.removeFavorite(petId);
      } else {
        await FavoriteService.addFavorite(petId);
      }
    } catch (e) {
      debugPrint("Offline mode – saved locally");
    }
  }

  // Adds the selected product to the shopping cart.
  Future<void> _addToCart(Product product) async {
    if (!mounted) return;

    final isLoggedIn = await ApiService.isLoggedIn();
    if (!isLoggedIn) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Login Required',
        text: 'Please login to add items to cart.',
        confirmBtnText: 'OK',
      );
      return;
    }

    try {
      await CartService.addToCart(
        product.id,
        productData: {
          'product_name': product.productName,
          'price': product.price,
          'image_url': product.fullImageUrl,
          'pet_type': product.petType,
          'accessories_type': product.accessoriesType,
        },
      );

      if (!mounted) return;

      // Show success message immediately
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Added to Cart',
        text: '${product.productName} added successfully',
      );

      if (!mounted) return;

      // Navigate to cart page after user dismisses success message
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    } catch (e) {
      debugPrint("Add to cart error: $e");

      if (!mounted) return;

      // Show error message
      String errorText = 'Failed to add item to cart. Please try again.';
      if (e.toString().contains('Failed to add to cart')) {
        final parts = e.toString().split(':');
        if (parts.length > 1) {
          errorText = parts.last.trim();
        }
      }

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: errorText,
      );
    }
  }

  // Hero/Banner Section
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        height: 160, // Slightly reduced height to fit better
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3), // Orange color from image
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Left Content
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 20,
                bottom: 20,
                right: 140,
              ), // Added right padding to avoid overlap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Exclusive deals for your furry friends. Limited time offer!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right Image
            Positioned(
              right: 10,
              bottom: 0,
              top: 10,
              width: 130, // Limit width
              child: Image.asset(
                'images/shop.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.pets, size: 60, color: Colors.white24),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter Drawer Widget
  Widget _buildFilterDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 60, 0, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            topRight: Radius.circular(10), // slight curve
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Type Chips
                    const Text(
                      "Pet Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: _petOptions.map((String type) {
                        final isSelected = _selectedPetType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedPetType = type;
                            });
                          },
                          selectedColor: const Color(0xFF2196F3),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Accessories Type Chips
                    const Text(
                      "Category",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: _accessoryOptions.map((String type) {
                        final isSelected = _selectedAccessoryType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedAccessoryType = type;
                            });
                          },
                          selectedColor: const Color(0xFF2196F3),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Price Range Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Price Range",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Rs.${_priceRange.start.round()} - Rs.${_priceRange.end.round()}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: _maxPrice,
                      divisions: 100,
                      activeColor: const Color(0xFF2196F3),
                      inactiveColor: Colors.grey[200],
                      labels: RangeLabels(
                        _priceRange.start.round().toString(),
                        _priceRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Filter Button
  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.tune_rounded, size: 20, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    "Filter",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Show active filters summary optionally
          if (_selectedPetType != 'All' || _selectedAccessoryType != 'All') ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: const Text(
                "!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper to get pastel colors based on index/id
  Color _getPastelColor(int index) {
    final colors = [
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFFFEBEE), // Light Red
      const Color(0xFFE0F2F1), // Light Teal
    ];
    return colors[index % colors.length];
  }

  // Renders a single product card with modern UI
  Widget _buildProductCard(Product product, int index) {
    final theme = Theme.of(context);
    final bool isFav = _favoriteIds.contains(product.id);
    final pastelColor = _getPastelColor(index);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.fullImageUrl,
                        fit: BoxFit.contain,
                        height: 120,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported,
                          color: Colors.black.withOpacity(0.2),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Space for bottom controls
              ],
            ),

            // Price Pill (Bottom Left)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Rs.${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Cart Button (Bottom Right)
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid view to display multiple products
  Widget _buildProductsGrid() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text("Error loading products", style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text("No results found", style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Try adjusting filters", style: theme.textTheme.bodyMedium),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPetType = 'All';
                  _selectedAccessoryType = 'All';
                  _priceRange = RangeValues(0, _maxPrice);
                });
              },
              child: const Text("Clear Filters"),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        if (index >= _filteredProducts.length) {
          return const SizedBox.shrink();
        }
        return _buildProductCard(_filteredProducts[index], index);
      },
    );
  }

  // Navigation handler helper
  void _onItemTapped(int index) {
    // Note: We don't need to update checking logic here extensively
    // because pushing a new route replaces the current one.

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      drawer: _buildFilterDrawer(),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Shop",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _onItemTapped(2),
            tooltip: "Cart",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(
            child: _buildFilterButton(),
          ), // Modern Filter Button
          if (!_isLoading &&
              _errorMessage ==
                  null) // Show header even if empty to show filter status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Products",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_filteredProducts.length} items", // Dynamic count
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading || _errorMessage != null || _filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildProductsGrid(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900
                      ? 4
                      : MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
                  childAspectRatio: 0.75, // Aspect ratio
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= _filteredProducts.length) {
                    return const SizedBox.shrink();
                  }
                  return _buildProductCard(_filteredProducts[index], index);
                }, childCount: _filteredProducts.length),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}
