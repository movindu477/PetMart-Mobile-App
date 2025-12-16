import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';

import 'homepage.dart';
import 'login.dart';
import 'shop.dart';
import 'cart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  String? _loggedEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedEmail = prefs.getString('loggedEmail');
    });
  }

  Future<void> _handleLogout() async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Logout',
      text: 'Are you sure you want to logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedEmail');
        await prefs.remove('token');

        if (!mounted) return;

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Logged Out',
          text: 'You have been logged out successfully',
          autoCloseDuration: const Duration(seconds: 1),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ShopPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 20),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.email,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _loggedEmail ?? 'Not logged in',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: const Text('My Orders'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite_outline,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          title: const Text('Favorites'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          title: const Text('Settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.error,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
            onDestinationSelected: (index) {
              if (index == _selectedIndex) return;
              _onItemTapped(index);
            },
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

