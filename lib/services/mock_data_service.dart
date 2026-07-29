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

    final List<Map<String, dynamic>> itemsData = [
      {
        'id': 'b-101', 'title': 'Luxury Oceanfront Suite - 3 Nights', 'cat': 'Hotels',
        'provider': 'Grand Hyatt Maldives', 'origPrice': 1800.0, 'deposit': 900.0, 'resalePrice': 1050.0, 'disc': 42,
        'location': 'South Male Atoll, Maldives', 'img': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&auto=format&fit=crop&q=80',
        'days': 12, 'reason': 'Emergency business trip reschedule.', 'seller': 'David Miller'
      },
      {
        'id': 'b-102', 'title': 'Botanical Garden Wedding Venue', 'cat': 'Venues',
        'provider': 'Oakridge Estate & Gardens', 'origPrice': 4500.0, 'deposit': 2000.0, 'resalePrice': 2700.0, 'disc': 40,
        'location': 'Napa Valley, California', 'img': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&auto=format&fit=crop&q=80',
        'days': 25, 'reason': 'Wedding date shifted to next year.', 'seller': 'Emily Watson'
      },
      {
        'id': 'b-103', 'title': 'Full-Day Premium Photography', 'cat': 'Photography',
        'provider': 'Lumina Studios', 'origPrice': 2200.0, 'deposit': 800.0, 'resalePrice': 1320.0, 'disc': 40,
        'location': 'Manhattan, New York', 'img': 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&auto=format&fit=crop&q=80',
        'days': 18, 'reason': 'Event scale reduced, no photo crew needed.', 'seller': 'Michael Chen'
      },
      {
        'id': 'b-104', 'title': 'Gourmet 5-Course Banquet Catering', 'cat': 'Catering',
        'provider': 'Artisan Culinary Group', 'origPrice': 3200.0, 'deposit': 1500.0, 'resalePrice': 1920.0, 'disc': 40,
        'location': 'Downtown Chicago, IL', 'img': 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800&auto=format&fit=crop&q=80',
        'days': 9, 'reason': 'Corporate sponsor budget reallocated.', 'seller': 'Jessica Taylor'
      },
      {
        'id': 'b-105', 'title': 'Annual VIP Gym Pass (Transferable)', 'cat': 'Gyms',
        'provider': 'Equinox Fitness Club', 'origPrice': 1500.0, 'deposit': 1500.0, 'resalePrice': 750.0, 'disc': 50,
        'location': 'San Francisco, CA', 'img': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
        'days': 60, 'reason': 'Relocated to another city.', 'seller': 'Brian Cox'
      },
      {
        'id': 'b-106', 'title': 'Front-Row VIP Tech Gala Pass', 'cat': 'Events',
        'provider': 'TechSummit Global', 'origPrice': 1200.0, 'deposit': 1200.0, 'resalePrice': 660.0, 'disc': 45,
        'location': 'Austin Convention Center, TX', 'img': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80',
        'days': 5, 'reason': 'Flight cancellation prevented travel.', 'seller': 'Rachel Green'
      },
      {
        'id': 'b-107', 'title': 'Swiss Alps Chalet - 4 Nights', 'cat': 'Hotels',
        'provider': 'Alpine Crest Lodge', 'origPrice': 2400.0, 'deposit': 1200.0, 'resalePrice': 1440.0, 'disc': 40,
        'location': 'Zermatt, Switzerland', 'img': 'https://images.unsplash.com/photo-1502784444187-359ac186c5bb?w=800&auto=format&fit=crop&q=80',
        'days': 30, 'reason': 'Change in vacation plans.', 'seller': 'Alex Thorne'
      },
      {
        'id': 'b-108', 'title': 'Modern Glass Ballroom Venue', 'cat': 'Venues',
        'provider': 'Skyline Glasshouse', 'origPrice': 5000.0, 'deposit': 2500.0, 'resalePrice': 3000.0, 'disc': 40,
        'location': 'Seattle, Washington', 'img': 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&auto=format&fit=crop&q=80',
        'days': 40, 'reason': 'Postponed anniversary gala.', 'seller': 'Olivia Martinez'
      },
      {
        'id': 'b-109', 'title': 'Cinematic Drone & Video Package', 'cat': 'Photography',
        'provider': 'AeroVision Media', 'origPrice': 1600.0, 'deposit': 600.0, 'resalePrice': 960.0, 'disc': 40,
        'location': 'Los Angeles, CA', 'img': 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&auto=format&fit=crop&q=80',
        'days': 15, 'reason': 'Switched to indoor acoustic gig.', 'seller': 'Daniel Kim'
      },
      {
        'id': 'b-110', 'title': 'Live Sushi Bar & Buffet Station', 'cat': 'Catering',
        'provider': 'OmaKase Executive Catering', 'origPrice': 2800.0, 'deposit': 1000.0, 'resalePrice': 1680.0, 'disc': 40,
        'location': 'Miami Beach, Florida', 'img': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&auto=format&fit=crop&q=80',
        'days': 14, 'reason': 'Guest count decreased.', 'seller': 'Sophia Loren'
      },
      {
        'id': 'b-111', 'title': 'CrossFit Unlimited 6-Month Pass', 'cat': 'Gyms',
        'provider': 'IronVault Fitness', 'origPrice': 900.0, 'deposit': 900.0, 'resalePrice': 450.0, 'disc': 50,
        'location': 'Denver, Colorado', 'img': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80',
        'days': 50, 'reason': 'Job transfer out of state.', 'seller': 'Chris Evans'
      },
      {
        'id': 'b-112', 'title': 'Formula 1 Paddock Club Pass', 'cat': 'Events',
        'provider': 'Grand Prix International', 'origPrice': 3500.0, 'deposit': 3500.0, 'resalePrice': 1950.0, 'disc': 44,
        'location': 'Las Vegas Strip Circuit', 'img': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&auto=format&fit=crop&q=80',
        'days': 8, 'reason': 'Family emergency.', 'seller': 'Marcus Vance'
      },
      {
        'id': 'b-113', 'title': 'Boutique Heritage Villa Stay', 'cat': 'Hotels',
        'provider': 'Villa Rosa Florence', 'origPrice': 1400.0, 'deposit': 700.0, 'resalePrice': 770.0, 'disc': 45,
        'location': 'Tuscany, Italy', 'img': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&auto=format&fit=crop&q=80',
        'days': 22, 'reason': 'Passport renewal delay.', 'seller': 'Elena Rostova'
      },
      {
        'id': 'b-114', 'title': 'Rooftop Lounge Event Reservation', 'cat': 'Venues',
        'provider': 'Skybar 360 Towers', 'origPrice': 2100.0, 'deposit': 1000.0, 'resalePrice': 1155.0, 'disc': 45,
        'location': 'Toronto, Canada', 'img': 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&auto=format&fit=crop&q=80',
        'days': 16, 'reason': 'Corporate party rescheduled.', 'seller': 'Liam Smith'
      },
      {
        'id': 'b-115', 'title': 'Fashion & Commercial Studio Shoot', 'cat': 'Photography',
        'provider': 'Vogue Vision Labs', 'origPrice': 1800.0, 'deposit': 900.0, 'resalePrice': 990.0, 'disc': 45,
        'location': 'SoHo, New York', 'img': 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&auto=format&fit=crop&q=80',
        'days': 11, 'reason': 'Brand campaign postponed.', 'seller': 'Chloe Bennet'
      },
      {
        'id': 'b-116', 'title': 'Artisanal Cocktail & Tapas Bar', 'cat': 'Catering',
        'provider': 'Mixology Masters', 'origPrice': 1900.0, 'deposit': 800.0, 'resalePrice': 1045.0, 'disc': 45,
        'location': 'Brooklyn, NY', 'img': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&auto=format&fit=crop&q=80',
        'days': 20, 'reason': 'Venue change with in-house bar.', 'seller': 'Ethan Hunt'
      },
      {
        'id': 'b-117', 'title': 'Pilates & Wellness Club Membership', 'cat': 'Gyms',
        'provider': 'Core Balance Studio', 'origPrice': 800.0, 'deposit': 800.0, 'resalePrice': 440.0, 'disc': 45,
        'location': 'Austin, Texas', 'img': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80',
        'days': 45, 'reason': 'Medical hiatus.', 'seller': 'Hannah Abbott'
      },
      {
        'id': 'b-118', 'title': 'EDM Music Festival Weekend VIP', 'cat': 'Events',
        'provider': 'Electric Horizon Fest', 'origPrice': 950.0, 'deposit': 950.0, 'resalePrice': 475.0, 'disc': 50,
        'location': 'Orlando, Florida', 'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop&q=80',
        'days': 7, 'reason': 'Schedule conflict with exams.', 'seller': 'Noah Miller'
      },
    ];

    return itemsData.map((data) {
      final booking = Booking(
        id: data['id'],
        title: data['title'],
        category: data['cat'],
        providerId: 'provider-${data['id']}',
        providerName: data['provider'],
        originalBuyerId: 'seller-${data['id']}',
        originalPrice: data['origPrice'],
        depositPaid: data['deposit'],
        eventDate: now.add(Duration(days: data['days'])),
        location: data['location'],
        imageUrl: data['img'],
        isVerified: true,
      );

      return ResaleListing(
        id: 'l-${data['id']}',
        booking: booking,
        sellerId: 'seller-${data['id']}',
        sellerName: data['seller'],
        resalePrice: data['resalePrice'],
        discountPercentage: data['disc'],
        cancellationReason: data['reason'],
        status: data['id'] == 'b-102' ? ListingStatus.pendingTransfer : ListingStatus.active,
        createdAt: now.subtract(Duration(hours: data['days'] * 2)),
      );
    }).toList();
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
