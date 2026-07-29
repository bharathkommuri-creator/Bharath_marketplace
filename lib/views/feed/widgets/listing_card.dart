import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/resale_listing.dart';
import '../../../theme/app_theme.dart';
import '../../detail/booking_detail_screen.dart';

class ListingCard extends StatelessWidget {
  final ResaleListing listing;

  const ListingCard({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailScreen(listing: listing),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Discount Tag & Provider Verification Badge
            Stack(
              children: [
                Image.network(
                  listing.booking.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppTheme.lightMintBg,
                    child: const Center(
                      child: Icon(Icons.hotel, color: AppTheme.primaryGreen, size: 40),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                // Discount Badge (Emerald Mint Green Tag)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Text(
                      '-${listing.discountPercentage}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Verified Provider Badge
                if (listing.booking.isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified_rounded, color: AppTheme.primaryGreen, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Host Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Category Chip
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.booking.category,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.booking.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.booking.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(listing.booking.eventDate)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.darkForest),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppTheme.borderLight),

                  // Pricing & Savings Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(listing.booking.originalPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(listing.resalePrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),

                      // Seller Deposit Lost Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightMintBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Seller Lost \$${listing.depositLost.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkForest,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
