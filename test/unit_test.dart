import 'package:flutter_test/flutter_test.dart';
import 'package:resale_marketplace/providers/marketplace_provider.dart';

void main() {
  group('TC-LIST: MarketplaceProvider Unit Tests', () {
    late MarketplaceProvider marketplaceProvider;

    setUp(() {
      marketplaceProvider = MarketplaceProvider();
    });

    test('TC-LIST-004: Category & Search Filter (in-memory)', () {
      marketplaceProvider.selectCategory('Hotels');
      expect(marketplaceProvider.selectedCategory, equals('Hotels'));

      marketplaceProvider.setSearchQuery('Grand');
      expect(marketplaceProvider.searchQuery, equals('grand'));
    });

    test('TC-LIST-002: Invalid Price Validation (Resale >= Original)', () {
      expect(
        () => marketplaceProvider.createListing(
          sellerId: 'seller-123',
          sellerName: 'Test Seller',
          title: 'Test Listing',
          category: 'Hotels',
          location: 'Goa',
          eventDate: DateTime.now().add(const Duration(days: 10)),
          originalPrice: 1000,
          depositPaid: 500,
          resalePrice: 1200, // Invalid: Higher than original
          providerName: 'Test Resort',
          cancellationReason: 'Plans changed',
        ),
        throwsArgumentError,
      );
    });

    test('TC-LIST-003: Past Event Date Validation', () {
      expect(
        () => marketplaceProvider.createListing(
          sellerId: 'seller-123',
          sellerName: 'Test Seller',
          title: 'Past Event Listing',
          category: 'Hotels',
          location: 'Goa',
          eventDate: DateTime.now().subtract(const Duration(days: 2)),
          originalPrice: 1000,
          depositPaid: 500,
          resalePrice: 700,
          providerName: 'Test Resort',
          cancellationReason: 'Plans changed',
        ),
        throwsArgumentError,
      );
    });

    test('TC-LIST-005: Invalid Category Validation', () {
      expect(
        () => marketplaceProvider.createListing(
          sellerId: 'seller-123',
          sellerName: 'Test Seller',
          title: 'Category Test',
          category: 'All', // Invalid - "All" is a filter only
          location: 'Goa',
          eventDate: DateTime.now().add(const Duration(days: 10)),
          originalPrice: 1000,
          depositPaid: 500,
          resalePrice: 700,
          providerName: 'Test Resort',
          cancellationReason: 'Plans changed',
        ),
        throwsArgumentError,
      );
    });

    test('TC-LIST-006: Deposit > Original Price Validation', () {
      expect(
        () => marketplaceProvider.createListing(
          sellerId: 'seller-123',
          sellerName: 'Test Seller',
          title: 'Deposit Test',
          category: 'Hotels',
          location: 'Goa',
          eventDate: DateTime.now().add(const Duration(days: 10)),
          originalPrice: 1000,
          depositPaid: 1500, // Invalid: deposit > original
          resalePrice: 700,
          providerName: 'Test Resort',
          cancellationReason: 'Plans changed',
        ),
        throwsArgumentError,
      );
    });
  });
}
