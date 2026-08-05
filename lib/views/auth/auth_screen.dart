import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;

  // Login Controllers
  final _loginIdentifierController =
      TextEditingController(text: 'ramesh@resalehub.in');
  final _loginPasswordController = TextEditingController(text: 'password123');

  // Sign Up Controllers
  final _signupNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _showAuthError(String? message) {
    if (message == null || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ResaleHub Login Portal'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkForest,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkForest.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Header (Exact 1:1 match with Web)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '⇄',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ResaleHub',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkForest,
                          ),
                        ),
                        Text(
                          '3-Party Booking Resale Marketplace',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pill Tabs: Log In vs Sign Up (Exact 1:1 match with Web)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isSignUp = false),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isSignUp
                                  ? AppTheme.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '🔑 Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: !_isSignUp
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isSignUp = true),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSignUp
                                  ? AppTheme.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '✨ Sign Up',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _isSignUp
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Views
                if (!_isSignUp)
                  _buildLoginFormView(context)
                else
                  _buildSignupFormView(context),

                const SizedBox(height: 20),

                // Terms Note
                const Text(
                  'By continuing, you agree to ResaleHub\'s Terms of Use and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Log In Form View (Exact Match with Web)
  Widget _buildLoginFormView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number or Email Address:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginIdentifierController,
          decoration: const InputDecoration(
            hintText: '+91 98765 43210 or email',
            prefixIcon:
                Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Password / OTP:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon:
                Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.darkForest],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                final loggedIn = await authProvider.login(
                  _loginIdentifierController.text,
                  _loginPasswordController.text,
                );
                if (!loggedIn && mounted)
                  _showAuthError(authProvider.lastError);
              },
              child: const Text(
                'Log In to Account →',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sign Up Form View (Exact Match with Web)
  Widget _buildSignupFormView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Name:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signupNameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Ramesh Kumar',
            prefixIcon:
                Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mobile Number:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signupPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '+91 98765 43210',
            prefixIcon: Icon(Icons.phone_android_outlined,
                color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Email Address:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signupEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon:
                Icon(Icons.mail_outline, color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Create Password:',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkForest),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signupPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Minimum 6 characters',
            prefixIcon:
                Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.darkForest],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                final signedUp = await authProvider.signUp(
                  email: _signupEmailController.text,
                  password: _signupPasswordController.text,
                  fullName: _signupNameController.text.isEmpty
                      ? (_signupEmailController.text.contains('@')
                          ? _signupEmailController.text.split('@')[0]
                          : 'Ramesh Kumar')
                      : _signupNameController.text,
                  role: UserRole.buyer,
                );
                if (!signedUp && mounted)
                  _showAuthError(authProvider.lastError);
              },
              child: const Text(
                'Create Free Account →',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
