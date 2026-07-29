import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../feed/marketplace_feed_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserRole _selectedUserRole = UserRole.buyer;
  
  // User Login controllers
  final _userEmailController = TextEditingController(text: 'buyer@resale.com');
  final _userPasswordController = TextEditingController(text: 'password123');

  // Provider Login controllers
  final _providerEmailController = TextEditingController(text: 'provider@grandhyatt.com');
  final _providerPasswordController = TextEditingController(text: 'provider123');
  final _businessNameController = TextEditingController(text: 'Grand Hyatt Hotels');

  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _providerEmailController.dispose();
    _providerPasswordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Account Login'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.lightMintBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.swap_horizontal_circle_rounded,
                        color: AppTheme.primaryGreen,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ResaleHub Portal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkForest,
                          ),
                        ),
                        Text(
                          'Sign in to access 3-Party Resale Services',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Top Login Type Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightMintBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textDark,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person_rounded, size: 18),
                        text: 'User Login',
                      ),
                      Tab(
                        icon: Icon(Icons.business_center_rounded, size: 18),
                        text: 'Service Provider Login',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: USER LOGIN (BUYER / SELLER)
                      _buildUserLoginForm(context),

                      // TAB 2: SERVICE PROVIDER LOGIN
                      _buildProviderLoginForm(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isSignUp ? 'Create General User Account' : 'Sign in as User',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Buy discounted slots or resell your cancelled bookings.',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),

        // User Sub-Role Selection (Buyer vs Seller)
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('New Buyer'),
                  ],
                ),
                selected: _selectedUserRole == UserRole.buyer,
                selectedColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(
                  color: _selectedUserRole == UserRole.buyer ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedUserRole = UserRole.buyer);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('Original Seller'),
                  ],
                ),
                selected: _selectedUserRole == UserRole.seller,
                selectedColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(
                  color: _selectedUserRole == UserRole.seller ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedUserRole = UserRole.seller);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _userEmailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
          ),
        ),
        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.login(
                _userEmailController.text,
                _userPasswordController.text,
                _selectedUserRole,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceFeedScreen()),
              );
            },
            child: Text(
              _isSignUp ? 'Sign Up User Account' : 'Login as ${_selectedUserRole == UserRole.buyer ? "Buyer" : "Seller"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Center(
          child: TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : "Need an account? Sign Up",
              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isSignUp ? 'Register Business Provider' : 'Sign in as Service Provider',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'For Hotels, Venues, Photographers & Caterers to manage transfers.',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),

        if (_isSignUp) ...[
          TextField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business / Hotel Name',
              prefixIcon: Icon(Icons.domain_rounded, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 12),
        ],

        TextField(
          controller: _providerEmailController,
          decoration: const InputDecoration(
            labelText: 'Business Email',
            prefixIcon: Icon(Icons.business_outlined, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _providerPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
          ),
        ),
        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkForest,
            ),
            icon: const Icon(Icons.verified_user_rounded, size: 18),
            label: Text(
              _isSignUp ? 'Register Provider Account' : 'Login as Service Provider',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.login(
                _providerEmailController.text,
                _providerPasswordController.text,
                UserRole.serviceProvider,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceFeedScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        Center(
          child: TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? 'Already registered? Provider Sign In' : "New Vendor? Register Business",
              style: const TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
