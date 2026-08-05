import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/resale_listing.dart';

const _uuid = Uuid();

/// Allowed image hosts for listing photos (CDN / known safe hosts only).
const _allowedImageHosts = <String>{
  'images.unsplash.com',
  'upload.wikimedia.org',
  'images.pexels.com',
  'cdn.pixabay.com',
  'plus.unsplash.com',
};

/// Page size for feed pagination — keeps initial loads fast at scale.
const _pageSize = 20;

class MarketplaceProvider extends ChangeNotifier {
  List<ResaleListing> _listings = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _lastError;

  List<String> get categories =>
      ['All', 'Hotels', 'Venues', 'Photography', 'Catering', 'Gyms', 'Events'];

  List<ResaleListing> get allListings => _listings;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get lastError => _lastError;

  MarketplaceProvider() {
    loadListings();
  }

  // ---------------------------------------------------------------------------
  // LOAD: Initial feed — first page from Supabase, JOINed with profiles
  // ---------------------------------------------------------------------------

  /// Loads the first page of live listings from Supabase.
  /// Resets pagination state and clears any previous listings.
  Future<void> loadListings() async {
    _isLoading = true;
    _currentPage = 0;
    _hasMore = true;
    _lastError = null;
    notifyListeners();

    try {
      final rows = await Supabase.instance.client
          .from('resale_listings')
          .select('''
            id, title, category, location, event_date, original_price,
            deposit_paid, resale_price, provider_name, is_verified,
            image_url, cancellation_reason, status, created_at, seller_id,
            profiles!resale_listings_seller_id_fkey(full_name)
          ''')
          .eq('status', 'listed')
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1);

      _listings = _parseRows(rows);
      _hasMore = rows.length == _pageSize;
      _currentPage = 1;
    } catch (e) {
      debugPrint('[MarketplaceProvider] loadListings error: $e');
      _lastError = 'Failed to load listings. Please check your connection.';
      _listings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PAGINATION: Load more listings (infinite scroll)
  // ---------------------------------------------------------------------------

  /// Fetches the next page of listings and appends to the existing list.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final start = _currentPage * _pageSize;
      final end = start + _pageSize - 1;

      final rows = await Supabase.instance.client
          .from('resale_listings')
          .select('''
            id, title, category, location, event_date, original_price,
            deposit_paid, resale_price, provider_name, is_verified,
            image_url, cancellation_reason, status, created_at, seller_id,
            profiles!resale_listings_seller_id_fkey(full_name)
          ''')
          .eq('status', 'listed')
          .order('created_at', ascending: false)
          .range(start, end);

      _listings.addAll(_parseRows(rows));
      _hasMore = rows.length == _pageSize;
      _currentPage++;
    } catch (e) {
      debugPrint('[MarketplaceProvider] loadMore error: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // FILTER & SEARCH (client-side on cached page)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CREATE: Publish a new listing to Supabase
  // ---------------------------------------------------------------------------

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

    // RLS independently verifies seller_id = auth.uid() server-side.
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

  /// Backward-compatible alias for createListing.
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<ResaleListing> _parseRows(List<dynamic> rows) {
    final result = <ResaleListing>[];
    for (final row in rows) {
      try {
        final origPrice = (row['original_price'] as num).toDouble();
        final resalePrice = (row['resale_price'] as num).toDouble();
        final discount = origPrice > 0
            ? (((origPrice - resalePrice) / origPrice) * 100).round()
            : 0;

        // Resolve seller name from the JOINed profiles row.
        final profileMap = row['profiles'] as Map<String, dynamic>?;
        final sellerName =
            profileMap?['full_name'] as String? ?? 'Verified Seller';

        final booking = Booking(
          id: 'b-${row['id']}',
          title: row['title'] ?? 'Resale Slot',
          category: row['category'] ?? 'Events',
          providerId: '',
          providerName: row['provider_name'] ?? 'Verified Provider',
          originalBuyerId: row['seller_id'] ?? '',
          originalPrice: origPrice,
          depositPaid:
              (row['deposit_paid'] as num?)?.toDouble() ?? origPrice * 0.5,
          eventDate: DateTime.tryParse(row['event_date'] ?? '') ??
              DateTime.now().add(const Duration(days: 30)),
          location: row['location'] ?? 'Location TBD',
          imageUrl: _resolveImageUrl(row['image_url'] ?? ''),
          isVerified: row['is_verified'] ?? false,
        );

        result.add(
          ResaleListing(
            id: row['id'].toString(),
            booking: booking,
            sellerId: row['seller_id'] ?? '',
            sellerName: sellerName,
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
        debugPrint('[MarketplaceProvider] Row parse error: $parseErr');
      }
    }
    return result;
  }

  void _requireNonBlank(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ArgumentError('$fieldName cannot be empty or blank.');
    }
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) return _defaultImageUrl;

    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null || !uri.hasAbsolutePath || uri.scheme != 'https') {
      return _defaultImageUrl;
    }

    final host = uri.host.replaceFirst('www.', '');
    if (!_allowedImageHosts.contains(host)) return _defaultImageUrl;

    return imageUrl.trim();
  }

  static const _defaultImageUrl =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=80';
}

