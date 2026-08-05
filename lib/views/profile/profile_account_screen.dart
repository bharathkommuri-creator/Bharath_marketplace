import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileAccountScreen extends StatelessWidget {
  const ProfileAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text(
              'My Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      profile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.fullName ?? 'Demo User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.email ?? 'user@resalehub.com',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightMintBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Active Role: ${auth.currentRole.name.toUpperCase()}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Options
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppTheme.primaryGreen),
              title: const Text('Buyer Protection & Escrow Guarantee'),
              subtitle: const Text('Funds held safely until provider re-issues booking name.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.verified_outlined, color: AppTheme.primaryGreen),
              title: const Text('Service Provider Verification'),
              subtitle: const Text('Hotels, Venues & Photographers official verification badge.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: AppTheme.primaryGreen),
              title: const Text('Help & Support'),
              subtitle: const Text('Frequently Asked Questions & 24/7 Dispute Resolution'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {},
            ),
            const SizedBox(height: 30),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade200),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => auth.logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
