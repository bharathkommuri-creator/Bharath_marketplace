import '../models/profile.dart';
import '../models/booking.dart';
import '../models/resale_listing.dart';
import '../models/transfer_chat.dart';

class MockDataService {
  static final Profile currentBuyer = Profile(
    id: 'buyer-001',
    email: 'buyer@example.com',
    fullName: 'Sarah Jenkins',
    role: UserRole.buyer,
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
  );

  static final Profile currentSeller = Profile(
    id: 'seller-001',
    email: 'seller@example.com',
    fullName: 'David Miller',
    role: UserRole.seller,
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
  );

  static final Profile currentProvider = Profile(
    id: 'provider-001',
    email: 'events@grandhyatt.com',
    fullName: 'Grand Hyatt Hotel & Resort',
    role: UserRole.serviceProvider,
    businessName: 'Grand Hyatt Hospitality',
    avatarUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=150',
  );

  static List<ResaleListing> getInitialListings() {
    final now = DateTime.now();

    final b1 = Booking(
      id: 'b-101',
      title: 'Luxury Oceanfront Suite - 3 Nights',
      category: 'Hotels',
      providerId: 'provider-001',
      providerName: 'Grand Hyatt Maldives',
      originalBuyerId: 'seller-001',
      originalPrice: 1800.0,
      depositPaid: 900.0,
      eventDate: now.add(const Duration(days: 12)),
      location: 'South Male Atoll, Maldives',
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    final b2 = Booking(
      id: 'b-102',
      title: 'Botanical Garden Wedding & Party Venue',
      category: 'Venues',
      providerId: 'provider-002',
      providerName: 'Oakridge Estate & Gardens',
      originalBuyerId: 'seller-002',
      originalPrice: 4500.0,
      depositPaid: 2000.0,
      eventDate: now.add(const Duration(days: 25)),
      location: 'Napa Valley, California',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    final b3 = Booking(
      id: 'b-103',
      title: 'Full-Day Premium Wedding & Portrait Photography',
      category: 'Photography',
      providerId: 'provider-003',
      providerName: 'Lumina Studio Studios',
      originalBuyerId: 'seller-003',
      originalPrice: 2200.0,
      depositPaid: 800.0,
      eventDate: now.add(const Duration(days: 18)),
      location: 'Manhattan, New York',
      imageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    final b4 = Booking(
      id: 'b-104',
      title: 'Gourmet 5-Course Banquet Catering (Up to 80 Guests)',
      category: 'Catering',
      providerId: 'provider-004',
      providerName: 'Artisan Culinary Group',
      originalBuyerId: 'seller-004',
      originalPrice: 3200.0,
      depositPaid: 1500.0,
      eventDate: now.add(const Duration(days: 9)),
      location: 'Downtown Chicago, IL',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    final b5 = Booking(
      id: 'b-105',
      title: 'Annual VIP All-Access Gym Pass (Transferable)',
      category: 'Gyms',
      providerId: 'provider-005',
      providerName: 'Equinox Fitness Club',
      originalBuyerId: 'seller-005',
      originalPrice: 1500.0,
      depositPaid: 1500.0,
      eventDate: now.add(const Duration(days: 60)),
      location: 'San Francisco, CA',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    final b6 = Booking(
      id: 'b-106',
      title: 'Front-Row VIP Conference & Tech Gala Pass',
      category: 'Events',
      providerId: 'provider-006',
      providerName: 'TechSummit Global',
      originalBuyerId: 'seller-006',
      originalPrice: 1200.0,
      depositPaid: 1200.0,
      eventDate: now.add(const Duration(days: 5)),
      location: 'Austin Convention Center, TX',
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80',
      isVerified: true,
    );

    return [
      ResaleListing(
        id: 'l-001',
        booking: b1,
        sellerId: 'seller-001',
        sellerName: 'David Miller',
        resalePrice: 1050.0,
        discountPercentage: 42,
        cancellationReason: 'Emergency business trip reschedule.',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      ResaleListing(
        id: 'l-002',
        booking: b2,
        sellerId: 'seller-002',
        sellerName: 'Emily Watson',
        resalePrice: 2700.0,
        discountPercentage: 40,
        cancellationReason: 'Wedding date shifted to next year.',
        status: ListingStatus.pendingTransfer,
        currentBuyerId: 'buyer-001',
        currentBuyerName: 'Sarah Jenkins',
        transferStep: TransferStep.claimed,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      ResaleListing(
        id: 'l-003',
        booking: b3,
        sellerId: 'seller-003',
        sellerName: 'Michael Chen',
        resalePrice: 1320.0,
        discountPercentage: 40,
        cancellationReason: 'Event scale reduced, no photo crew needed.',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ResaleListing(
        id: 'l-004',
        booking: b4,
        sellerId: 'seller-004',
        sellerName: 'Jessica Taylor',
        resalePrice: 1920.0,
        discountPercentage: 40,
        cancellationReason: 'Corporate sponsor budget reallocated.',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ResaleListing(
        id: 'l-005',
        booking: b5,
        sellerId: 'seller-005',
        sellerName: 'Brian Cox',
        resalePrice: 750.0,
        discountPercentage: 50,
        cancellationReason: 'Relocated to another city.',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      ResaleListing(
        id: 'l-006',
        booking: b6,
        sellerId: 'seller-006',
        sellerName: 'Rachel Green',
        resalePrice: 660.0,
        discountPercentage: 45,
        cancellationReason: 'Flight cancellation prevented travel.',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  static List<TransferChatMessage> getInitialChatMessages(String listingId) {
    final now = DateTime.now();
    return [
      TransferChatMessage(
        id: 'm-1',
        listingId: listingId,
        senderId: 'seller-001',
        senderName: 'David Miller',
        senderRole: UserRole.seller,
        message: 'Hello! I listed my luxury resort booking. Original deposit paid was \$900.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      TransferChatMessage(
        id: 'm-2',
        listingId: listingId,
        senderId: 'provider-001',
        senderName: 'Grand Hyatt Maldives',
        senderRole: UserRole.serviceProvider,
        message: 'Official Host Verification: Booking #b-101 is valid and ready for guest name transfer upon agreement.',
        actionType: 'provider_approve',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      TransferChatMessage(
        id: 'm-3',
        listingId: listingId,
        senderId: 'buyer-001',
        senderName: 'Sarah Jenkins',
        senderRole: UserRole.buyer,
        message: 'Hi! I am interested in claiming this slot. Will the resort accept guest name update immediately?',
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}
