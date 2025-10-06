import 'package:flutter/material.dart';
import 'dart:io';
import 'homepage.dart';

void main() {
  // ✅ Add this for HTTPS certificate handling in development
  HttpOverrides.global = MyHttpOverrides();
  runApp(const PetShopApp());
}

// ✅ HTTP Override for SSL certificate issues in development
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // splash runs for 3 seconds
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start the animation
    _controller.forward();

    // Wait for animation to complete, then navigate
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image with fade effect
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              "images/main1.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.blue[50],
                  child: const Icon(Icons.pets, size: 100, color: Colors.blue),
                );
              },
            ),
          ),

          /// Dark overlay for better text visibility
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          /// Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Animated Logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Image.asset(
                      "images/logo.png",
                      width: 200,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 80,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// App Name with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Petmart",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Tagline with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Your Pet's Favorite Store",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// Loading indicator section
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Column(
                  children: [
                    /// Loading text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Animated loading line
                    SizedBox(
                      height: 4,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _controller.value,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade100,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Percentage indicator
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Text(
                          "${(_controller.value * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}