import 'booking.dart';

enum ListingStatus { active, pendingTransfer, sold, cancelled }
enum TransferStep { listed, claimed, providerVerified, completed }

class ResaleListing {
  final String id;
  final Booking booking;
  final String sellerId;
  final String sellerName;
  final double resalePrice;
  final int discountPercentage;
  final String? cancellationReason;
  final ListingStatus status;
  final String? currentBuyerId;
  final String? currentBuyerName;
  final TransferStep transferStep;
  final DateTime createdAt;

  ResaleListing({
    required this.id,
    required this.booking,
    required this.sellerId,
    required this.sellerName,
    required this.resalePrice,
    required this.discountPercentage,
    this.cancellationReason,
    this.status = ListingStatus.active,
    this.currentBuyerId,
    this.currentBuyerName,
    this.transferStep = TransferStep.listed,
    required this.createdAt,
  });

  double get depositLost => booking.depositPaid;
  double get buyerSavings => booking.originalPrice - resalePrice;

  factory ResaleListing.fromJson(Map<String, dynamic> json, Booking booking) {
    return ResaleListing(
      id: json['id'] ?? '',
      booking: booking,
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? 'Alex Johnson',
      resalePrice: (json['resale_price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discount_percentage'] ?? 20,
      cancellationReason: json['cancellation_reason'] ?? 'Schedule conflict',
      status: _parseStatus(json['status']),
      currentBuyerId: json['current_buyer_id'],
      currentBuyerName: json['current_buyer_name'],
      transferStep: _parseStep(json['transfer_step']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static ListingStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'pending_transfer':
        return ListingStatus.pendingTransfer;
      case 'sold':
        return ListingStatus.sold;
      case 'cancelled':
        return ListingStatus.cancelled;
      default:
        return ListingStatus.active;
    }
  }

  static TransferStep _parseStep(String? stepStr) {
    switch (stepStr) {
      case 'claimed':
        return TransferStep.claimed;
      case 'provider_verified':
        return TransferStep.providerVerified;
      case 'completed':
        return TransferStep.completed;
      default:
        return TransferStep.listed;
    }
  }
}
