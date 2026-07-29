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

class _AuthScreenState extends State<AuthScreen> {
  UserRole _selectedRole = UserRole.buyer;
  final _emailController = TextEditingController(text: 'demo@resale.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32.0),
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
                // Logo & Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightMintBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.swap_horizontal_circle_rounded,
                        color: AppTheme.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ResaleHub',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkForest,
                          ),
                        ),
                        Text(
                          '3-Party Booking Marketplace',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  _isSignUp ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Resell non-refundable hotel, venue, or photography bookings at a discount.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // 3-Party Role Selection Chips
                const Text(
                  'Select Your Platform Role:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRoleChip(UserRole.buyer, 'Buyer', Icons.shopping_bag_outlined),
                    const SizedBox(width: 8),
                    _buildRoleChip(UserRole.seller, 'Seller', Icons.sell_outlined),
                    const SizedBox(width: 8),
                    _buildRoleChip(UserRole.serviceProvider, 'Provider', Icons.business_outlined),
                  ],
                ),
                const SizedBox(height: 20),

                // Form Fields
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      authProvider.login(
                        _emailController.text,
                        _passwordController.text,
                        _selectedRole,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MarketplaceFeedScreen()),
                      );
                    },
                    child: Text(
                      _isSignUp ? 'Sign Up as ${_selectedRole.nameString}' : 'Login as ${_selectedRole.nameString}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(
                      _isSignUp ? 'Already have an account? Log In' : "Don't have an account? Sign Up",
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.lightMintBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.borderLight,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppTheme.darkForest,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
