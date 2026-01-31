import 'package:flutter/material.dart';
import 'shop_view.dart';
import 'about_view.dart';
// import 'main_screen.dart'; // Import MainScreen for GlobalKey access

import '../widgets/custom_bottom_nav_bar.dart';

import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/location_map_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final int _selectedIndex = 0; // Handled by MainScreen
  late ScrollController _scrollController;
  String _currentCity = "Locating...";
  Position? _currentPosition;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Track scrolling to toggle app bar transparency
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initLocation();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.determinePosition();
      final city = await LocationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentCity = city;
        _currentPosition = position;
      });

      // Update backend with latest location
      LocationService.sendLocationToBackend(
        position.latitude,
        position.longitude,
        city,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentCity = "Unknown";
      });

      // Handle permission denial gracefully
      if (e.toString().contains('denied')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable location permissions in settings for live GPS tracking.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      debugPrint("Location error: $e");
    }
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
      // Extend body behind app bar for transparent effect
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
        elevation: _isScrolled ? 2 : 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
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

            // Map Section
            if (_currentPosition != null)
              LocationMapSection(
                latitude: _currentPosition!.latitude,
                longitude: _currentPosition!.longitude,
                city: _currentCity,
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(height: 12),
                      Text(
                        "Determining your location...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // This is the 'Discover' section showing off our services.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                    ? 350
                    : 480,
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
            _buildTestimonials(),
            const SizedBox(height: 32),

            // This is the 'Shop' section encouraging users to browse products.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                    ? 350
                    : 480,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShopPage(),
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
            _buildWhyChooseUs(),
            const SizedBox(height: 100),
          ],
        ), // Column
      ), // SingleChildScrollView
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    ); // Scaffold
  }

  // This internal widget builds the large hero image at the top.
  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.landscape
          ? 400
          : 700,
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
                  const Color(0xFF1E1E1E).withOpacity(0.7),
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

  // Simple list of customer reviews to build trust.
  Widget _buildTestimonials() {
    final reviews = [
      {
        "name": "Sarah Jenkins",
        "comment":
            "Absolutely amazing service! My order arrived in just 2 days.",
        "rating": 5,
        "color": 0xFFE3F2FD, // Light Blue
        "textColor": 0xFF1565C0,
      },
      {
        "name": "John Doe",
        "comment": "The app is so easy to use. I found everything I needed.",
        "rating": 5,
        "color": 0xFFF3E5F5, // Light Purple
        "textColor": 0xFF7B1FA2,
      },
      {
        "name": "Emily Rogers",
        "comment": "My golden retriever loves the new toys. Highly recommend!",
        "rating": 4,
        "color": 0xFFE8F5E9, // Light Green
        "textColor": 0xFF2E7D32,
      },
      {
        "name": "Michael Brown",
        "comment": "Premium quality food. My cat is very picky but loves this.",
        "rating": 5,
        "color": 0xFFFFEBEE, // Light Red
        "textColor": 0xFFC62828,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF1565C0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Happy Customers",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Quote Icon
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: 40,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(review['color'] as int),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (review['name'] as String)[0],
                                  style: TextStyle(
                                    color: Color(review['textColor'] as int),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: i < (review['rating'] as int)
                                            ? const Color(0xFFFFB300)
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            review['comment'] as String,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  // A new section emphasizing the store's key benefits
  Widget _buildWhyChooseUs() {
    final features = [
      {
        "icon": Icons.pets_rounded,
        "title": "Healthy & Trusted Pets",
        "color": 0xFFFFE0B2,
        "iconColor": 0xFFF57C00,
      },
      {
        "icon": Icons.verified_rounded,
        "title": "Quality Accessories",
        "color": 0xFFE1BEE7,
        "iconColor": 0xFF8E24AA,
      },
      {
        "icon": Icons.security_rounded,
        "title": "Secure Payments",
        "color": 0xFFC8E6C9,
        "iconColor": 0xFF388E3C,
      },
      {
        "icon": Icons.touch_app_rounded,
        "title": "Easy Ordering",
        "color": 0xFFB3E5FC,
        "iconColor": 0xFF0288D1,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Why Choose Us",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.landscape
                  ? 4
                  : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3, // Adjusted for more vertical space
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final item = features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(item['color'] as int).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Color(item['iconColor'] as int),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E1E1E),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
