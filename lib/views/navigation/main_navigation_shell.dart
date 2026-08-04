import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../chats/chats_list_screen.dart';
import '../feed/marketplace_feed_screen.dart';
import '../my_ads/my_ads_screen.dart';
import '../profile/profile_account_screen.dart';
import '../seller/create_listing_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MarketplaceFeedScreen(),
    ChatsListScreen(),
    MyAdsScreen(),
    ProfileAccountScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to extend cleanly behind floating pill nav
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Floating Modern Capsule Dock Navigation Bar (Matches Web 100%)
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppTheme.borderLight.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkForest.withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tab 0: Explore
                _buildCapsuleNavItem(
                  index: 0,
                  activeIcon: Icons.explore_rounded,
                  inactiveIcon: Icons.explore_outlined,
                  label: 'Explore',
                ),

                // Tab 1: Chats
                _buildCapsuleNavItem(
                  index: 1,
                  activeIcon: Icons.chat_bubble_rounded,
                  inactiveIcon: Icons.chat_bubble_outline_rounded,
                  label: 'Chats',
                ),

                // Center Action Capsule: "+ Post Free Ad"
                _buildPostAdCapsule(context),

                // Tab 2: My Ads
                _buildCapsuleNavItem(
                  index: 2,
                  activeIcon: Icons.confirmation_number_rounded,
                  inactiveIcon: Icons.confirmation_number_outlined,
                  label: 'My Ads',
                ),

                // Tab 3: Account
                _buildCapsuleNavItem(
                  index: 3,
                  activeIcon: Icons.person_rounded,
                  inactiveIcon: Icons.person_outline_rounded,
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Center Action Capsule Button: "+ Post Free Ad"
  Widget _buildPostAdCapsule(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.darkForest, AppTheme.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Post Free Ad',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Individual Capsule Navigation Tab Item
  Widget _buildCapsuleNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppTheme.darkForest : AppTheme.textMuted,
                size: 19,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.darkForest : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
