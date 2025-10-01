import 'package:flutter/material.dart';

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

  /// ✅ Section Builder
  Widget buildSection({
    required String image,
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool isFirstSection = false,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isFirstSection && isLandscape) {
      // 🔹 Landscape layout for first section
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                horizontal: 28, vertical: 14),
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
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 🔹 Default Portrait / Other Sections
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
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
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
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
                      ]
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

  /// Pages for Bottom Navigation
  final List<Widget> _pages = [
    // Home Section
    SingleChildScrollView(
      child: Column(
        children: [
          // Sections will be built inside build() below
        ],
      ),
    ),
    const Center(child: Text("Shop Page", style: TextStyle(fontSize: 22))),
    const Center(child: Text("Cart Page", style: TextStyle(fontSize: 22))),
    const Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    // Replace Home page content dynamically
    _pages[0] = SingleChildScrollView(
      child: Column(
        children: [
          buildSection(
            image: "assets/section1.jpg",
            title: "Welcome to PetMart",
            description:
            "Your one-stop shop for all pet essentials! From nutritious food to playful toys, "
                "we bring the best for your furry, feathery, and scaly friends.",
            isFirstSection: true,
          ),
          buildSection(
            image: "assets/section2.jpg",
            title: "About Us",
            description:
            "At PetMart, we believe pets are family. With years of expertise and a passion for animals, "
                "we provide top-quality products and trusted advice to ensure your pets live happy, healthy lives.",
            buttonText: "Learn More",
            onButtonPressed: () {},
          ),
          buildSection(
            image: "assets/section3.jpg",
            title: "Our Shop",
            description:
            "Explore our wide range of pet supplies — premium foods, comfy bedding, grooming kits, "
                "and exciting toys. Everything your pet needs, all under one roof.",
            buttonText: "Go to Shop",
            onButtonPressed: () {},
          ),
          buildSection(
            image: "assets/section4.jpg",
            title: "Contact Us",
            description:
            "Have questions? Need recommendations? Reach out to our friendly team for guidance, "
                "support, or to find the perfect product for your pet.",
            buttonText: "Contact Us",
            onButtonPressed: () {},
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
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
              setState(() {
                _selectedIndex = 2; // jump to Cart tab
              });
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.blue),
          ),
        ],
      ),
      body: _pages[_selectedIndex],

      /// ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
