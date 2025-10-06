import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const PetShopApp());
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // splash runs for 3 seconds
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to HomePage when loading is done
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset("images/main1.jpg", fit: BoxFit.cover),

          /// Overlay content
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              /// Logo at top center
              Center(
                child: Image.asset("images/logo.png", width: 200, height: 200),
              ),
              const Spacer(),

              /// Animated loading line
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  height: 5,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _controller.value,
                        backgroundColor: Colors.white54,
                        color: Colors.blue,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(10),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
