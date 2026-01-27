import 'package:flutter/material.dart';
import 'shop.dart';
import 'about.dart';

import '../widgets/custom_bottom_nav_bar.dart';

// This is the main landing page of the application where users land after the splash screen.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // We initialize the scroll controller here to keep track of scrolling behavior.
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // We want the app bar to sit on top of the content for a seamless look.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "PetMart",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // The top hero section with the main welcome message.
            _buildHeroSection(),
            const SizedBox(height: 24),

            // This is the 'Discover' section showing off our services.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 480,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFF8FBFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      // We position the background image slightly off-screen for a dynamic look.
                      Positioned(
                        right: -100,
                        bottom: 0,
                        top: 40,
                        child: Image.asset(
                          "images/back2.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Discover",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Your Perfect",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Pet Match",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Learn more about our services and how we can help you find the perfect companion.",
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF1E1E1E).withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 24,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: const Color(
                              0xFF1565C0,
                            ).withOpacity(0.4),
                          ),
                          child: const Text(
                            "About Us",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // This is the 'Shop' section encouraging users to browse products.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 480,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFF8FBFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      // Image placed on the left side for variety.
                      Positioned(
                        left: -60,
                        bottom: 0,
                        top: 80,
                        child: Image.asset(
                          "images/back3.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Text content aligned to the right.
                      Positioned(
                        top: 40,
                        right: 24,
                        left: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Everything",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Your Pet Needs",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Browse our wide range of premium pet products, from food to accessories.",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF1E1E1E).withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 24,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: const Color(
                              0xFF1565C0,
                            ).withOpacity(0.4),
                          ),
                          child: const Text(
                            "Shop Us",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTestimonials(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  // This internal widget builds the large hero image at the top.
  Widget _buildHeroSection() {
    return Container(
      height: 700,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/back1.jpg",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1565C0)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  const Color(0xFF1565C0).withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Make Your Pet\nHappy Today",
                  style: TextStyle(
                    fontSize: 36,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Premium food, toys, and accessories delivered to your doorstep.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavBar() {
    return CustomBottomNavBar(selectedIndex: _selectedIndex);
  }

  // Simple list of customer reviews to build trust.
  Widget _buildTestimonials() {
    final reviews = [
      {
        "name": "Sarah M.",
        "comment": "Great service! Delivered fast.",
        "rating": 5,
      },
      {"name": "John D.", "comment": "Easy to use app. Love it!", "rating": 5},
      {"name": "Emily R.", "comment": "My dog loves the toys!", "rating": 4},
      {"name": "Michael B.", "comment": "Premium quality food.", "rating": 5},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Happy Customers",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF3F9FF),
                          radius: 16,
                          child: Text(
                            (review['name'] as String)[0],
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: i < (review['rating'] as int)
                                      ? const Color(0xFFFFC107)
                                      : Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      review['comment'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
