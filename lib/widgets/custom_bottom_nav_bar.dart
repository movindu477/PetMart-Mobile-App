import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/shop_view.dart';
import '../views/cart_view.dart';
import '../views/profile_view.dart';

// This widget renders the floating bottom navigation bar seen across the app.
// It uses a pill-shaped design for a modern look.
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, "Home"),
            _buildNavItem(
              context,
              1,
              Icons.store_mall_directory_outlined,
              "Shop",
            ),
            _buildNavItem(context, 2, Icons.shopping_bag_outlined, "Cart"),
            _buildNavItem(context, 3, Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  // Creates a single navigation item with animation handling.
  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
          return;
        }
        if (selectedIndex == index) return;

        // Navigate with a smooth custom transition
        switch (index) {
          case 0:
            Navigator.pushReplacement(context, _createRoute(const HomePage()));
            break;
          case 1:
            Navigator.pushReplacement(context, _createRoute(const ShopPage()));
            break;
          case 2:
            Navigator.pushReplacement(context, _createRoute(const CartPage()));
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              _createRoute(const ProfilePage()),
            );
            break;
        }
      },
      child: isSelected
          ? Hero(tag: 'nav-pill', child: _buildTabItem(isSelected, icon, label))
          : _buildTabItem(isSelected, icon, label),
    );
  }

  Widget _buildTabItem(bool isSelected, IconData icon, String label) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubicEmphasized,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.white.withOpacity(0.65),
        size: 26,
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);

        var scaleTween = Tween(
          begin: 0.98,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));
        var scaleAnimation = animation.drive(scaleTween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}
