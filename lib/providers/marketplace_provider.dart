import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // V-09: cryptographically safe IDs
import '../models/booking.dart';
import '../models/resale_listing.dart';
import '../services/mock_data_service.dart';

// V-09 FIX: Single shared UUID generator instance.
const _uuid = Uuid();

// V-08 FIX: Allowlist of trusted image URL domains.
// Only images from these hosts are accepted; all others are rejected.
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

  List<String> get categories => ['All', 'Hotels', 'Venues', 'Photography', 'Catering', 'Gyms', 'Events'];

  List<ResaleListing> get allListings => _listings;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  MarketplaceProvider() {
    loadListings();
  }

  void loadListings() {
    _isLoading = true;
    notifyListeners();
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
      final matchesCategory = _selectedCategory == 'All' || listing.booking.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          listing.booking.title.toLowerCase().contains(_searchQuery) ||
          listing.booking.location.toLowerCase().contains(_searchQuery) ||
          listing.booking.providerName.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ResaleListing> getListingsByCategory(String category) {
    return _listings.where((listing) => listing.booking.category == category).toList();
  }

  List<ResaleListing> get highSavingsDeals {
    return _listings.where((listing) => listing.discountPercentage >= 40).toList();
  }

  // ---------------------------------------------------------------------------
  // V-06 FIX: addListing() now validates ALL inputs before creating any object.
  // V-07 FIX: resalePrice must be strictly less than originalPrice.
  // V-08 FIX: imageUrl is validated against an allowlist of trusted domains.
  // V-09 FIX: IDs use UUID v4 instead of millisecondsSinceEpoch.
  // ---------------------------------------------------------------------------

  /// Validates and adds a new resale listing to the marketplace.
  ///
  /// Throws [ArgumentError] if any field fails validation.
  /// Returns the created [ResaleListing] on success.
  ResaleListing addListing({
    required String title,
    required String category,
    required String providerName,
    required String location,
    required double originalPrice,
    required double depositPaid,
    required double resalePrice,
    required DateTime eventDate,
    required String cancellationReason,
    required String imageUrl,
  }) {
    // V-06: Validate required text fields are non-empty.
    _requireNonBlank(title, 'Title');
    _requireNonBlank(providerName, 'Provider name');
    _requireNonBlank(location, 'Location');
    _requireNonBlank(cancellationReason, 'Cancellation reason');

    // V-06: Validate category is one of the allowed values.
    if (!categories.contains(category)) {
      throw ArgumentError('Invalid category "$category". Must be one of: ${categories.join(', ')}');
    }

    // V-06: Validate prices are positive numbers.
    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than zero. Got: $originalPrice');
    }
    if (depositPaid < 0) {
      throw ArgumentError('Deposit paid cannot be negative. Got: $depositPaid');
    }
    if (depositPaid > originalPrice) {
      throw ArgumentError('Deposit paid (\$$depositPaid) cannot exceed the original price (\$$originalPrice).');
    }

    // V-07 FIX: Resale price must be strictly less than original price.
    if (resalePrice <= 0) {
      throw ArgumentError('Resale price must be greater than zero. Got: $resalePrice');
    }
    if (resalePrice >= originalPrice) {
      throw ArgumentError(
        'Resale price (\$$resalePrice) must be less than the original price (\$$originalPrice). '
        'Listing at or above original price is not allowed.',
      );
    }

    // V-06: Validate event date is in the future.
    if (!eventDate.isAfter(DateTime.now())) {
      throw ArgumentError('Event date must be in the future. Got: $eventDate');
    }

    // V-08 FIX: Validate image URL against allowlist — or use default.
    final resolvedImageUrl = _resolveImageUrl(imageUrl);

    // V-09 FIX: Use UUID v4 for unpredictable IDs.
    final bookingId = 'b-${_uuid.v4()}';
    final listingId = 'l-${_uuid.v4()}';

    final discount = (((originalPrice - resalePrice) / originalPrice) * 100).round();

    final newBooking = Booking(
      id: bookingId,
      title: title.trim(),
      category: category,
      providerId: 'provider-001',
      providerName: providerName.trim(),
      originalBuyerId: 'seller-001',
      originalPrice: originalPrice,
      depositPaid: depositPaid,
      eventDate: eventDate,
      location: location.trim(),
      imageUrl: resolvedImageUrl,
      isVerified: true,
    );

    final newListing = ResaleListing(
      id: listingId,
      booking: newBooking,
      sellerId: 'seller-001',
      sellerName: 'David Miller',
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

  // ---------------------------------------------------------------------------
  // Private validation helpers
  // ---------------------------------------------------------------------------

  /// V-06: Throws [ArgumentError] if [value] is null, empty, or whitespace-only.
  void _requireNonBlank(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$fieldName cannot be empty or blank.');
    }
  }

  /// V-08: Returns [imageUrl] if it is from an allowed domain,
  /// or the safe Unsplash fallback if the URL is empty or untrusted.
  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return _defaultImageUrl;
    }

    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null || !uri.hasAbsolutePath || uri.scheme != 'https') {
      debugPrint('[MarketplaceProvider] Rejected image URL (not HTTPS or invalid): $imageUrl');
      return _defaultImageUrl;
    }

    // Strip "www." prefix for consistent matching.
    final host = uri.host.replaceFirst('www.', '');
    if (!_allowedImageHosts.contains(host)) {
      debugPrint('[MarketplaceProvider] Rejected image URL from untrusted host "$host": $imageUrl');
      return _defaultImageUrl;
    }

    return imageUrl.trim();
  }

  static const _defaultImageUrl =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=80';
}
