import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 200.0 : 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About Us',
                style: theme.textTheme.headlineMedium?.copyWith(
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'images/about.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.primaryContainer,
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeroCard(context, theme, isTablet),
                const SizedBox(height: 24),
                _buildStorySection(context, theme, isTablet),
                const SizedBox(height: 24),
                _buildValuesSection(context, theme, isTablet),
                const SizedBox(height: 24),
                _buildContactSection(context, theme, isTablet),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ThemeData theme, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: isTablet ? 64 : 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to PetMart',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your trusted partner in pet care since 2020',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, ThemeData theme, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
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
                      Icons.history_edu,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Our Story',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'At PetMart, we believe pets are family. Founded in 2020, we started as a small family business with a simple goal: make pet care easier and more enjoyable for everyone.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Over the years, we have grown into a trusted brand loved by pet owners across the country. We provide top-quality products, trusted advice, and exceptional service to ensure your pets live happy, healthy lives.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context, ThemeData theme, bool isTablet) {
    final values = [
      {
        'icon': Icons.favorite,
        'title': 'Passion',
        'description': 'We love pets as much as you do',
      },
      {
        'icon': Icons.verified,
        'title': 'Quality',
        'description': 'Only the best products for your pets',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support',
        'description': 'Expert advice whenever you need it',
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Convenience',
        'description': 'Everything your pet needs in one place',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
            child: Text(
              'Our Values',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: values.length,
            itemBuilder: (context, index) {
              final value = values[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          value['icon'] as IconData,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value['title'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, ThemeData theme, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          padding: EdgeInsets.all(isTablet ? 32 : 24),
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
                      Icons.contact_support,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Get in Touch',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildContactItem(
                context,
                theme,
                Icons.phone_outlined,
                'Phone',
                '+94 77 123 4567',
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildContactItem(
                context,
                theme,
                Icons.email_outlined,
                'Email',
                'info@petmart.com',
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildContactItem(
                context,
                theme,
                Icons.location_on_outlined,
                'Address',
                '123 Pet Street, Colombo, Sri Lanka',
                Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Follow Us',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSocialButton(
                    context,
                    theme,
                    'images/facebook.png',
                    Icons.facebook,
                    () {},
                  ),
                  const SizedBox(width: 12),
                  _buildSocialButton(
                    context,
                    theme,
                    'images/instagram.png',
                    Icons.camera_alt_outlined,
                    () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    ThemeData theme,
    String imagePath,
    IconData fallbackIcon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          imagePath,
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              fallbackIcon,
              color: theme.colorScheme.primary,
              size: 32,
            );
          },
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
