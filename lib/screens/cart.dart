import 'package:flutter/material.dart';
import 'homepage.dart';
import 'shop.dart';
import 'profile.dart';
import '../models/cart_data.dart';
import 'payment.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> get cartItems => globalCartItems;

  String _getImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    if (imageUrl.startsWith('/')) {
      return "http://10.0.2.2:8000$imageUrl";
    }
    
    if (imageUrl.startsWith('storage/') || imageUrl.startsWith('images/')) {
      return "http://10.0.2.2:8000/$imageUrl";
    }
    
    return "http://10.0.2.2:8000/storage/$imageUrl";
  }

  @override
  void initState() {
    super.initState();
  }

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
    } else {
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
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
                "Item removed from cart",
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
      ),
    );
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
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
                "Cart cleared",
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
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final itemTotal = item['price'] * item['quantity'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item['image'] != null && item['image'].toString().isNotEmpty
                      ? Image.network(
                          _getImageUrl(item['image'].toString()),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            );
                          },
                        )
                      : Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['name'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['description'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () => _updateQuantity(
                                  index,
                                  item['quantity'] - 1,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                iconSize: 18,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  item['quantity'].toString(),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => _updateQuantity(
                                  index,
                                  item['quantity'] + 1,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                iconSize: 18,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "\$${itemTotal.toStringAsFixed(2)}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                onPressed: () => _removeItem(index),
                tooltip: "Remove item",
              ),
            ],
          ),
        ),
      ),
    );
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShopPage()),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          "Shopping Cart",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            }
          },
          tooltip: "Back",
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
              tooltip: "Clear cart",
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (cartItems.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cartItems.length} ${cartItems.length == 1 ? 'Item' : 'Items'}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total: \$${totalPrice.toStringAsFixed(2)}",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.shopping_cart_checkout,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 100,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Your cart is empty",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add items to your cart to get started",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.store),
                              label: const Text("Continue Shopping"),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index], index);
                      },
                    ),
            ),
            if (cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(cartItems: cartItems),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: Text(
                      "Place Order - \$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
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
