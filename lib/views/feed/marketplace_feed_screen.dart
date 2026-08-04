import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/category_selector.dart';

import 'widgets/how_it_works_banner.dart';
import 'widgets/listing_card.dart';

class MarketplaceFeedScreen extends StatefulWidget {
  const MarketplaceFeedScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceFeedScreen> createState() => _MarketplaceFeedScreenState();
}

class _MarketplaceFeedScreenState extends State<MarketplaceFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final marketplace = Provider.of<MarketplaceProvider>(context);
    final filteredListings = marketplace.filteredListings;
    final highSavingsListings = marketplace.highSavingsDeals;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _searchController.clear();
              marketplace.setSearchQuery('');
              marketplace.selectCategory('All');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightMintBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),

                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ResaleHub',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkForest),
                    ),
                    Text(
                      'Role: ${authProvider.currentRole.nameString}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        actions: [
          // V-02 FIX: Replace 'Login Portal' with 'Logout' since auth is now enforced.
          // AuthGate in main.dart will route back to AuthScreen on logout.
          InkWell(
            onTap: () {
              authProvider.logout();
              // No Navigator needed — AuthGate re-renders AuthScreen automatically.
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Role Toggle Dropdown for quick testing
          PopupMenuButton<UserRole>(
            tooltip: 'Switch 3-Party Perspective',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.lightMintBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_outline, size: 16, color: AppTheme.primaryGreen),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryGreen),
                ],
              ),
            ),
            onSelected: (role) {
              authProvider.switchRole(role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Switched view to: ${role.nameString}'),
                  backgroundColor: AppTheme.primaryGreen,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: UserRole.buyer,
                child: Text('View as New Buyer'),
              ),
              const PopupMenuItem(
                value: UserRole.seller,
                child: Text('View as Original Seller'),
              ),
              const PopupMenuItem(
                value: UserRole.serviceProvider,
                child: Text('View as Service Provider'),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero & Search Header
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.cardWhite,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover Resold Booking Slots',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Save 30% - 60% on non-refundable hotels, venues, photography & catering.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => marketplace.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search hotels, venues, location, or provider...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                marketplace.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3-Party How it works banner
          const SliverToBoxAdapter(
            child: HowItWorksBanner(),
          ),

          // High Savings Horizontal Highlight Section (Encouraging browsing)
          if (highSavingsListings.isNotEmpty && marketplace.selectedCategory == 'All') ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.bolt_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Flash Deals: High Savings (>40% Off)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 265,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: highSavingsListings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 260,
                      child: ListingCard(listing: highSavingsListings[index]),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // Category Pill Filter Bar
          const SliverToBoxAdapter(
            child: CategorySelector(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Feed Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Recent Resale Listings (${filteredListings.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),

          // Responsive Grid View of Listings
          filteredListings.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'No bookings found matching your search.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisExtent: 265,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),

                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ListingCard(listing: filteredListings[index]),
                      childCount: filteredListings.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

