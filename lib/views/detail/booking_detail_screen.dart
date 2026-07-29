import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../models/resale_listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/tri_party_chat.dart';
import 'widgets/tri_party_status_stepper.dart';

class BookingDetailScreen extends StatelessWidget {
  final ResaleListing listing;

  const BookingDetailScreen({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final authProvider = Provider.of<AuthProvider>(context);
    final transferProvider = Provider.of<TransferProvider>(context);
    final currentStep = transferProvider.getStep(listing);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Booking Resale Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Overlays
            Stack(
              children: [
                Image.network(
                  listing.booking.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: AppTheme.lightMintBg,
                    child: const Center(child: Icon(Icons.hotel, size: 60, color: AppTheme.primaryGreen)),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${listing.discountPercentage}% DISCOUNT',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                if (listing.booking.isVerified)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified, color: AppTheme.primaryGreen, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Provider Verified',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.darkForest),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.lightMintBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.booking.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.booking.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        listing.booking.location,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pricing & Savings Breakdown Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Original Booking Price:', style: TextStyle(color: AppTheme.textMuted)),
                            Text(currency.format(listing.booking.originalPrice),
                                style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppTheme.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Seller Deposit Lost:', style: TextStyle(color: AppTheme.badgeRed, fontWeight: FontWeight.w600)),
                            Text('-${currency.format(listing.depositLost)}',
                                style: const TextStyle(color: AppTheme.badgeRed, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24, color: AppTheme.borderLight),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Resale Asking Price:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                Text('You save ${currency.format(listing.buyerSavings)}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text(
                              currency.format(listing.resalePrice),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Booking Metadata Info Grid
                  Row(
                    children: [
                      _buildInfoTile(
                        Icons.calendar_month_rounded,
                        'Event Date',
                        DateFormat('EEE, MMM dd, yyyy').format(listing.booking.eventDate),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoTile(
                        Icons.business_rounded,
                        'Host / Provider',
                        listing.booking.providerName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3-Party Transfer Stepper
                  TriPartyStatusStepper(currentStep: currentStep),
                  const SizedBox(height: 24),

                  // Integrated 3-Party Chat Stream
                  TriPartyChat(listing: listing),
                  const SizedBox(height: 24),

                  // Dynamic 3-Party Action Button
                  _buildActionButton(context, authProvider, transferProvider, currentStep),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.lightMintBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    AuthProvider authProvider,
    TransferProvider transferProvider,
    TransferStep step,
  ) {
    final role = authProvider.currentRole;

    if (step == TransferStep.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightMintBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '✓ Transfer Complete - Booking Successfully Reassigned',
            style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    }

    if (role == UserRole.buyer && step == TransferStep.listed) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_cart_checkout_rounded),
          label: const Text('Buy / Claim Slot Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            transferProvider.claimSlot(listing.id, authProvider.currentProfile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Slot claimed! Funds held in 3-party escrow until Provider approves.'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
          },
        ),
      );
    }

    if (role == UserRole.serviceProvider && step == TransferStep.claimed) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Verify Guest Transfer & Approve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            transferProvider.providerApprove(listing.id, authProvider.currentProfile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Service Provider approved reservation transfer!'),
                backgroundColor: Color(0xFF2563EB),
              ),
            );
          },
        ),
      );
    }

    if (role == UserRole.seller && step == TransferStep.providerVerified) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Release Slot & Receive Payout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            transferProvider.completeTransfer(listing.id, authProvider.currentProfile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payout released! Transaction complete.'),
                backgroundColor: Color(0xFFD97706),
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightMintBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Waiting for ${_getRequiredRoleName(step)} action...',
          style: const TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getRequiredRoleName(TransferStep step) {
    switch (step) {
      case TransferStep.listed:
        return 'New Buyer claim';
      case TransferStep.claimed:
        return 'Service Provider approval';
      case TransferStep.providerVerified:
        return 'Seller release';
      case TransferStep.completed:
        return 'Completed';
    }
  }
}
