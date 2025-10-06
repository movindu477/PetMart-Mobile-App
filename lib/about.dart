import 'package:flutter/material.dart';

// Import your other pages
import 'shop.dart';
import 'cart.dart';
import 'login.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //About Image
            Image.asset(
              'images/about.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            //About Our Story Section
            const Text(
              'About Our Story',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to PetMart! We are passionate about providing the best products and services for your beloved pets. From premium food to fun toys, we ensure your pets live a happy and healthy life.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),

            //Our Story Section
            const Text(
              'Our Story',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Founded in 2020, PetMart started as a small family business with a simple goal: make pet care easier and more enjoyable for everyone. Over the years, we have grown into a trusted brand loved by pet owners across the country.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),

            //Contact Us Section
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('📞 +94 77 123 4567', style: TextStyle(fontSize: 16)),
            const Text('✉️ info@petmart.com', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            //Social Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                  },
                  child: Image.asset(
                    'images/facebook.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    //Instagram link
                  },
                  child: Image.asset(
                    'images/instagram.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      //Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            //  Navigate to ShopPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
          } else if (index == 2) {
            // Navigate to CartPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          } else if (index == 3) {
            // Navigate to LoginPage (Profile)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            // Stay in Home tab
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
