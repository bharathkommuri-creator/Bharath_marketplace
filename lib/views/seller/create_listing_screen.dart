import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../theme/app_theme.dart';
import '../feed/marketplace_feed_screen.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _providerController = TextEditingController();
  final _locationController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _depositPaidController = TextEditingController();
  final _resalePriceController = TextEditingController();
  final _reasonController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Hotels';
  DateTime _eventDate = DateTime.now().add(const Duration(days: 14));
  int _calculatedDiscount = 0;

  void _recalculateDiscount() {
    final orig = double.tryParse(_originalPriceController.text) ?? 0;
    final resell = double.tryParse(_resalePriceController.text) ?? 0;

    if (orig > 0 && resell > 0 && orig > resell) {
      setState(() {
        _calculatedDiscount = (((orig - resell) / orig) * 100).round();
      });
    } else {
      setState(() {
        _calculatedDiscount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketplace = Provider.of<MarketplaceProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Go to Home',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.lightMintBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),

          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceFeedScreen()),
              );
            }
          },
        ),
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceFeedScreen()),
              );
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'ResaleHub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkForest,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightMintBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'List your non-refundable booking. The service provider will verify your reservation before transfer.',
                        style: TextStyle(fontSize: 12, color: AppTheme.darkForest, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              const Text('Booking Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryGreen),
                ),
                items: ['Hotels', 'Venues', 'Photography', 'Catering', 'Gyms', 'Events']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              // Title
              const Text('Listing Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 2 Nights Ocean View Deluxe Suite',
                  prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryGreen),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Host / Provider Name & Location
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service Provider / Host', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _providerController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Hilton Hotel',
                            prefixIcon: Icon(Icons.business_rounded, color: AppTheme.primaryGreen),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Provider required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Miami, FL',
                            prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Location required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Picker
              const Text('Event / Reservation Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _eventDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _eventDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryGreen, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEE, MMM dd, yyyy').format(_eventDate),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pricing Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Original Price (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _originalPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '1000'),
                          onChanged: (_) => _recalculateDiscount(),
                           validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deposit Paid (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _depositPaidController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '500'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resale Price (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _resalePriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '600'),
                          onChanged: (_) => _recalculateDiscount(),
                          // V-07 FIX: Client-side guard — resale must be < original.
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final resell = double.tryParse(v);
                            if (resell == null || resell <= 0) return 'Must be > 0';
                            final orig = double.tryParse(_originalPriceController.text) ?? 0;
                            if (orig > 0 && resell >= orig) {
                              return 'Must be less than original (\$$orig)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Calculated Discount Tag Preview
              if (_calculatedDiscount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightMintBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_rounded, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Calculated Savings for Buyer: -$_calculatedDiscount% OFF',
                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Reason
              const Text('Reason for Reselling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Flight schedule change prevents travel.',
                  prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),

              // Image URL
              const Text('Photo Image URL (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image_outlined, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.publish_rounded),
                  label: const Text('Publish Resale Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // V-06/V-07/V-08: addListing() validates all inputs and
                        // throws ArgumentError on any violation.
                        marketplace.addListing(
                          title: _titleController.text.trim(),
                          category: _selectedCategory,
                          providerName: _providerController.text.trim(),
                          location: _locationController.text.trim(),
                          originalPrice: double.parse(_originalPriceController.text.trim()),
                          depositPaid: double.parse(_depositPaidController.text.trim()),
                          resalePrice: double.parse(_resalePriceController.text.trim()),
                          eventDate: _eventDate,
                          cancellationReason: _reasonController.text.trim(),
                          imageUrl: _imageUrlController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Listing posted! Provider notified for verification.'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                        Navigator.pop(context);
                      } on ArgumentError catch (e) {
                        // Show server-side validation error to the user.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Validation error: ${e.message}'),
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
