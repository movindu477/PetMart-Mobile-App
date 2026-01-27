import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';

import 'login.dart';
import 'homepage.dart';
import 'favorites.dart';
// import 'my_orders.dart'; // Placeholder
import '../services/favorite_cache_service.dart';
import '../services/cart_cache_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _loggedEmail;
  String _userName = "Jane Cooper";
  String _phone = "(303) 555-0105"; // Default placeholder
  String _address = "UK, 789 Pine Avenue"; // Default placeholder

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedEmail');
    final token = prefs.getString('token');
    final name = prefs.getString('loggedName');

    if (email == null || token == null) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        });
      }
      return;
    }

    setState(() {
      _loggedEmail = email;
      if (name != null && name.isNotEmpty) {
        _userName = name;
      }
    });

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await ApiService.fetchUserProfile();
    if (response != null && mounted) {
      // Handle potential wrappers if the API returns { "user": ... } or { "data": ... }
      final userData = response['user'] ?? response['data'] ?? response;

      setState(() {
        if (userData['name'] != null) _userName = userData['name'];
        if (userData['email'] != null) _loggedEmail = userData['email'];

        // Try multiple common keys for phone
        _phone =
            userData['phone']?.toString() ??
            userData['phone_number']?.toString() ??
            userData['contact_no']?.toString() ??
            userData['mobile']?.toString() ??
            "Not set";

        // Try multiple common keys for address
        _address =
            userData['address']?.toString() ??
            userData['location']?.toString() ??
            userData['full_address']?.toString() ??
            "Not set";
      });
    }
  }

  Future<void> _handleLogout() async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Logout',
      text: 'Are you sure you want to logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Close dialog

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedEmail');
        await prefs.remove('token');

        try {
          await FavoriteCacheService.clearFavorites();
          await CartCacheService.clearCart();
        } catch (e) {
          debugPrint("Error clearing cache: $e");
        }

        if (!mounted) return;

        // Redirect to unified Login Page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dark Color from design
    final darkColor = const Color(0xFF18181B);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 1. Dark Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              child: Column(
                children: [
                  // App Bar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 40, height: 40),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Profile Image
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name & Email
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _loggedEmail ?? "Loading...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildDetailField("Full Name", _userName, isEditable: true),
                  _buildDetailField(
                    "Nickname",
                    _userName.split(' ').first,
                    isEditable: true,
                  ),
                  _buildDetailField(
                    "Email",
                    _loggedEmail ?? "Not set",
                    icon: Icons.email_outlined,
                  ),
                  _buildDetailField(
                    "Phone",
                    _phone,
                    icon: Icons.phone_outlined,
                  ),
                  _buildDetailField(
                    "Address",
                    _address,
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 32),
                  _buildMenuItem(
                    Icons.logout,
                    "Log out",
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(
    String label,
    String value, {
    bool isEditable = false,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            Icon(Icons.edit, color: Colors.grey[400], size: 20)
          else if (icon != null)
            Icon(icon, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // In case background is grey
        borderRadius: BorderRadius.circular(16),
        // Design usually implies flat or subtle shadow
        // border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.black87,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
