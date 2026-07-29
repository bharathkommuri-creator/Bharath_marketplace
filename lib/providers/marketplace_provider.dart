import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/resale_listing.dart';
import '../services/mock_data_service.dart';

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

  void addListing({
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
    final discount = (((originalPrice - resalePrice) / originalPrice) * 100).round();
    final newBooking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      providerId: 'provider-001',
      providerName: providerName,
      originalBuyerId: 'seller-001',
      originalPrice: originalPrice,
      depositPaid: depositPaid,
      eventDate: eventDate,
      location: location,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      isVerified: true,
    );

    final newListing = ResaleListing(
      id: 'l-${DateTime.now().millisecondsSinceEpoch}',
      booking: newBooking,
      sellerId: 'seller-001',
      sellerName: 'David Miller',
      resalePrice: resalePrice,
      discountPercentage: discount > 0 ? discount : 0,
      cancellationReason: cancellationReason,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    _listings.insert(0, newListing);
    notifyListeners();
  }
}
