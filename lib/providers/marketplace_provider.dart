import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // V-09: cryptographically safe IDs
import '../models/booking.dart';
import '../models/resale_listing.dart';
import '../services/mock_data_service.dart';

const _uuid = Uuid();

const _allowedImageHosts = <String>{
  'images.unsplash.com',
  'upload.wikimedia.org',
  'images.pexels.com',
  'cdn.pixabay.com',
  'plus.unsplash.com',
};

class MarketplaceProvider extends ChangeNotifier {
  List<ResaleListing> _listings = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<String> get categories =>
      ['All', 'Hotels', 'Venues', 'Photography', 'Catering', 'Gyms', 'Events'];

  List<ResaleListing> get allListings => _listings;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  MarketplaceProvider() {
    loadListings();
  }

  /// Production Supabase database loader with fallback
  Future<void> loadListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await Supabase.instance.client
          .from('resale_listings')
          .select('*')
          .order('created_at', ascending: false);

      if (rows.isNotEmpty) {
        final List<ResaleListing> dbListings = [];
        for (final row in rows) {
          try {
            final origPrice = (row['original_price'] as num).toDouble();
            final resalePrice = (row['resale_price'] as num).toDouble();
            final discount = origPrice > 0
                ? (((origPrice - resalePrice) / origPrice) * 100).round()
                : 0;

            final booking = Booking(
              id: 'b-${row['id']}',
              title: row['title'] ?? 'Resale Slot',
              category: row['category'] ?? 'Events',
              providerId: row['provider_id'] ?? 'provider-001',
              providerName: row['provider_name'] ?? 'Verified Provider',
              originalBuyerId: row['seller_id'] ?? 'seller-001',
              originalPrice: origPrice,
              depositPaid:
                  (row['deposit_paid'] as num?)?.toDouble() ?? origPrice * 0.5,
              eventDate: DateTime.tryParse(row['event_date'] ?? '') ??
                  DateTime.now().add(const Duration(days: 30)),
              location: row['location'] ?? 'Seattle, WA',
              imageUrl: _resolveImageUrl(row['image_url'] ?? ''),
              isVerified: row['is_verified'] ?? false,
            );

            dbListings.add(
              ResaleListing(
                id: row['id'].toString(),
                booking: booking,
                sellerId: row['seller_id'] ?? 'seller-001',
                sellerName: 'Listing Seller',
                resalePrice: resalePrice,
                discountPercentage: discount > 0 ? discount : 0,
                cancellationReason:
                    row['cancellation_reason'] ?? 'Schedule conflict',
                status: ListingStatus.active,
                createdAt: DateTime.tryParse(row['created_at'] ?? '') ??
                    DateTime.now(),
              ),
            );
          } catch (parseErr) {
            debugPrint('[MarketplaceProvider] DB row parse notice: $parseErr');
          }
        }

        if (dbListings.isNotEmpty) {
          _listings = dbListings;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint(
          '[MarketplaceProvider] Supabase fetch notice (using fallback seed data): $e');
    }

    _listings = MockDataService.getInitialListings();
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<ResaleListing> get filteredListings {
    return _listings.where((listing) {
      final matchesCategory = _selectedCategory == 'All' ||
          listing.booking.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          listing.booking.title.toLowerCase().contains(_searchQuery) ||
          listing.booking.location.toLowerCase().contains(_searchQuery) ||
          listing.booking.providerName.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ResaleListing> get highSavingsDeals {
    return _listings.where((l) => l.discountPercentage >= 35).toList();
  }

  /// Production Listing Creation (Persists to Supabase DB)
  Future<ResaleListing> createListing({
    required String sellerId,
    required String sellerName,
    required String title,
    required String category,
    required String location,
    required DateTime eventDate,
    required double originalPrice,
    required double depositPaid,
    required double resalePrice,
    required String providerName,
    required String cancellationReason,
    String imageUrl = '',
  }) async {
    _requireNonBlank(sellerId, 'Seller ID');
    _requireNonBlank(sellerName, 'Seller name');
    _requireNonBlank(title, 'Title');
    _requireNonBlank(category, 'Category');
    _requireNonBlank(location, 'Location');
    _requireNonBlank(providerName, 'Provider Name');
    _requireNonBlank(cancellationReason, 'Cancellation Reason');

    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than 0.');
    }
    if (depositPaid < 0 || depositPaid > originalPrice) {
      throw ArgumentError(
          'Deposit paid must be between 0 and the original price.');
    }
    if (resalePrice <= 0) {
      throw ArgumentError('Resale price must be greater than 0.');
    }
    if (resalePrice >= originalPrice) {
      throw ArgumentError(
          'Resale price must be lower than original price to provide discount.');
    }
    if (!eventDate.isAfter(DateTime.now())) {
      throw ArgumentError('Event date must be in the future.');
    }
    if (!categories.contains(category) || category == 'All') {
      throw ArgumentError('Choose a valid listing category.');
    }

    final resolvedImageUrl = _resolveImageUrl(imageUrl);
    final listingId = _uuid.v4();
    final discount =
        (((originalPrice - resalePrice) / originalPrice) * 100).round();

    // Persist to Supabase. RLS independently verifies that sellerId is the
    // authenticated user, so a caller cannot create a listing for another user.
    try {
      await Supabase.instance.client.from('resale_listings').insert({
        'id': listingId,
        'seller_id': sellerId,
        'title': title.trim(),
        'category': category,
        'location': location.trim(),
        'event_date': eventDate.toIso8601String(),
        'original_price': originalPrice,
        'deposit_paid': depositPaid,
        'resale_price': resalePrice,
        'provider_name': providerName.trim(),
        'image_url': resolvedImageUrl,
        'cancellation_reason': cancellationReason.trim(),
        'status': 'listed',
      });
    } catch (dbErr) {
      debugPrint('[MarketplaceProvider] DB listing insert error: $dbErr');
      throw StateError('Unable to publish the listing. Please try again.');
    }

    final newBooking = Booking(
      id: 'b-$listingId',
      title: title.trim(),
      category: category,
      providerId: '',
      providerName: providerName.trim(),
      originalBuyerId: sellerId,
      originalPrice: originalPrice,
      depositPaid: depositPaid,
      eventDate: eventDate,
      location: location.trim(),
      imageUrl: resolvedImageUrl,
      isVerified: false,
    );

    final newListing = ResaleListing(
      id: listingId,
      booking: newBooking,
      sellerId: sellerId,
      sellerName: sellerName.trim(),
      resalePrice: resalePrice,
      discountPercentage: discount > 0 ? discount : 0,
      cancellationReason: cancellationReason.trim(),
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    _listings.insert(0, newListing);
    notifyListeners();
    return newListing;
  }

  /// Alias for backward compatibility
  Future<ResaleListing> addListing({
    required String sellerId,
    required String sellerName,
    required String title,
    required String category,
    required String location,
    required DateTime eventDate,
    required double originalPrice,
    required double resalePrice,
    required String providerName,
    required String cancellationReason,
    required double depositPaid,
    String imageUrl = '',
  }) =>
      createListing(
        sellerId: sellerId,
        sellerName: sellerName,
        title: title,
        category: category,
        location: location,
        eventDate: eventDate,
        originalPrice: originalPrice,
        depositPaid: depositPaid,
        resalePrice: resalePrice,
        providerName: providerName,
        cancellationReason: cancellationReason,
        imageUrl: imageUrl,
      );

  void _requireNonBlank(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$fieldName cannot be empty or blank.');
    }
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return _defaultImageUrl;
    }

    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null || !uri.hasAbsolutePath || uri.scheme != 'https') {
      return _defaultImageUrl;
    }

    final host = uri.host.replaceFirst('www.', '');
    if (!_allowedImageHosts.contains(host)) {
      return _defaultImageUrl;
    }

    return imageUrl.trim();
  }

  static const _defaultImageUrl =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=80';
}
