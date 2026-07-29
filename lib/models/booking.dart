class Booking {
  final String id;
  final String title;
  final String category; // Hotels, Venues, Photography, Catering, Gyms, Events
  final String providerId;
  final String providerName;
  final String originalBuyerId;
  final double originalPrice;
  final double depositPaid;
  final DateTime eventDate;
  final String location;
  final String imageUrl;
  final bool isVerified;

  Booking({
    required this.id,
    required this.title,
    required this.category,
    required this.providerId,
    required this.providerName,
    required this.originalBuyerId,
    required this.originalPrice,
    required this.depositPaid,
    required this.eventDate,
    required this.location,
    required this.imageUrl,
    this.isVerified = true,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Hotels',
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'] ?? 'Verified Host',
      originalBuyerId: json['original_buyer_id'] ?? '',
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      depositPaid: (json['deposit_paid'] as num?)?.toDouble() ?? 0.0,
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now().add(const Duration(days: 14)),
      location: json['location'] ?? 'Location N/A',
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=80',
      isVerified: json['verification_status'] == 'verified' || json['is_verified'] == true,
    );
  }
}
