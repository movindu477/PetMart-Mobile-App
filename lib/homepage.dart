import 'package:flutter/material.dart';
import 'shop.dart'; // ✅ Import ShopPage
import 'login.dart'; // ✅ Import LoginPage
import 'cart.dart'; // ✅ Import CartPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ✅ Section Builder (for Home page)
  Widget buildSection({
    required String image,
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // Landscape → Row layout
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(image, fit: BoxFit.cover, height: 280),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 18, height: 1.6),
                      ),
                      if (buttonText != null && onButtonPressed != null) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Portrait → Fullscreen background
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.4)),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 60,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.6,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      if (buttonText != null && onButtonPressed != null) ...[
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// ✅ Pages for BottomNavigationBar
  List<Widget> get _pages => [
    // Home Page
    SingleChildScrollView(
      child: Column(
        children: [
          buildSection(
            image: "images/section1.jpg",
            title: "Welcome to PetMart",
            description:
                "Your one-stop shop for all pet essentials! From nutritious food to playful toys, we bring the best for your furry, feathery, and scaly friends.",
          ),
          buildSection(
            image: "images/section2.jpg",
            title: "About Us",
            description:
                "At PetMart, we believe pets are family. With years of expertise and a passion for animals, we provide top-quality products and trusted advice to ensure your pets live happy, healthy lives.",
          ),
          buildSection(
            image: "images/section3.jpg",
            title: "Our Shop",
            description:
                "Explore our wide range of pet supplies — premium foods, comfy bedding, grooming kits, and exciting toys. Everything your pet needs, all under one roof.",
          ),
          buildSection(
            image: "images/section4.jpg",
            title: "Contact Us",
            description:
                "Have questions? Need recommendations? Reach out to our friendly team for guidance, support, or to find the perfect product for your pet.",
          ),
        ],
      ),
    ),

    // Placeholder Shop (opens separately)
    const SizedBox(),

    // Placeholder Cart (opens separately)
    const SizedBox(),

    // Placeholder Profile (opens separately)
    const SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          "PetMart",
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // ✅ Navigate directly to CartPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.blue),
          ),
        ],
      ),
      body: _pages[_selectedIndex],

      /// ✅ Fixed Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // ✅ Navigate to ShopPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
          } else if (index == 2) {
            // ✅ Navigate to CartPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          } else if (index == 3) {
            // ✅ Navigate to LoginPage (Profile)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            // ✅ Stay in Home tab
            setState(() {
              _selectedIndex = index;
            });
          }
        },
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
