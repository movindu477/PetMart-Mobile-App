import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

import 'homepage.dart';
import 'profile.dart'; // Redirect to Profile after register if needed, or Home
import '../services/favorite_service.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  final bool isRegister;
  const LoginPage({super.key, this.isRegister = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Toggle State
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = !widget.isRegister;
    _checkLoginStatus();
  }

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Register specific controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static final String baseUrl = ApiService.baseUrl;

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedEmail');
    if (email != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> _saveLogin(String email, String token, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedEmail', email);
    await prefs.setString('token', token);
    if (name.isNotEmpty) await prefs.setString('loggedName', name);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin) {
      // Registration Validation
      if (_passwordController.text != _confirmPasswordController.text) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Passwords do not match',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Processing',
      text: _isLogin ? 'Logging in...' : 'Creating account...',
      barrierDismissible: false,
    );

    try {
      final endpoint = _isLogin ? "/login" : "/register";
      final body = _isLogin
          ? {
              "email": _emailController.text.trim(),
              "password": _passwordController.text.trim(),
            }
          : {
              "name": _nameController.text.trim(),
              "email": _emailController.text.trim(),
              "password": _passwordController.text.trim(),
              "password_confirmation": _confirmPasswordController.text.trim(),
            };

      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['token'];

        if (token != null) {
          String name = "";
          if (!_isLogin) {
            name = _nameController.text.trim();
          } else if (data['user'] != null && data['user']['name'] != null) {
            name = data['user']['name'];
          } else if (data['name'] != null) {
            name = data['name'];
          }
          await _saveLogin(_emailController.text.trim(), token, name);

          if (_isLogin) {
            // Fetch data on login
            try {
              await FavoriteService.fetchFavorites();
              await CartService.fetchCart();
              await CartService.syncLocalCartToApi();
            } catch (e) {
              debugPrint("Sync error: $e");
            }
          }
        } else if (_isLogin) {
          // Login success but no token? rare
        }

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: _isLogin
              ? 'Login successful!'
              : 'Account created successfully!',
          autoCloseDuration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // Navigate
        if (_isLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          // For register, maybe go to Profile or Home? User said "profile" in register.dart
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfilePage(),
            ), // changed from HomePage to match register flow? Or check. Let's use HomePage for consistency or Profile. Register.dart used ProfilePage.
          );
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Failed',
          text: data['message'] ?? data['error'] ?? "Operation failed",
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Server connection failed. Try again.',
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    return Scaffold(
      backgroundColor: Colors.black, // Dark background behind image
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          },
        ),
        actions: const [], // Ensure no stray icons appear
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final imageHeight = isLandscape
              ? constraints.maxHeight * 0.35
              : constraints.maxHeight * 0.45;
          final contentTop = isLandscape
              ? constraints.maxHeight * 0.30
              : constraints.maxHeight * 0.35;

          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                // 1. Background Image
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        "images/login.jpg",
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.blueGrey.shade900),
                      ),
                      // Dark overlay gradient for text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      // Header Text
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 60,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _isLogin ? "Welcome Back" : "Create Account",
                                key: ValueKey(_isLogin),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Sign in to enjoy the best managing experience",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. White Container Bottom Sheet
                Positioned(
                  top: contentTop,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Toggle Switch
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isLogin = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _isLogin
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          boxShadow: _isLogin
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _isLogin
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isLogin = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: !_isLogin
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          boxShadow: !_isLogin
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Register",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: !_isLogin
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Fields with Animation
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: Visibility(
                                visible: !_isLogin,
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      label: "Full Name",
                                      icon: Icons.person_outline_rounded,
                                      controller: _nameController,
                                      validator: (v) =>
                                          v!.isEmpty ? "Enter your name" : null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),

                            _buildTextField(
                              label: "E-mail ID",
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v!.contains("@") ? null : "Enter valid email",
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              label: "Password",
                              icon: Icons.lock_outline_rounded,
                              controller: _passwordController,
                              isPassword: true,
                              isObscure: _obscurePassword,
                              onVisibilityToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (v) =>
                                  v!.length < 6 ? "Minimum 6 chars" : null,
                            ),

                            // Confirm Password Animation
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  if (!_isLogin) ...[
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      label: "Confirm Password",
                                      icon: Icons.lock_outline_rounded,
                                      controller: _confirmPasswordController,
                                      isPassword: true,
                                      isObscure: _obscureConfirmPassword,
                                      onVisibilityToggle: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                      validator: (v) => v!.isEmpty
                                          ? "Confirm password"
                                          : null,
                                    ),
                                  ] else ...[
                                    // Forgot Password?
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "Forget Password?",
                                          style: TextStyle(
                                            color: Color(0xFF1565C0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Checkbox (Remember me) - Animated
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              child: _isLogin
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: false,
                                            onChanged: (v) {},
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Remember me",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 24),

                            // Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF1565C0,
                                  ), // Blue
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 8,
                                  shadowColor: const Color(
                                    0xFF1565C0,
                                  ).withOpacity(0.4),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Text(
                                          _isLogin ? "Login" : "Register",
                                          key: ValueKey(_isLogin),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isObscure,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[500],
                  size: 22,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
