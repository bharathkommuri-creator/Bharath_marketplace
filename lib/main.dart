import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/transfer_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_screen.dart';
import 'views/navigation/main_navigation_shell.dart';

// V-01 FIX: Supabase credentials loaded from .env, NOT hardcoded in source.
// V-02 FIX: App's home is determined by actual auth state — auth screen shown first.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // V-01: Load secrets from .env file (excluded from git via .gitignore)
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    // V-01 FIX: publishableKey replaces the deprecated anonKey parameter.
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ResaleMarketplaceApp());
}

class ResaleMarketplaceApp extends StatelessWidget {
  const ResaleMarketplaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
      ],
      // V-02 FIX: AuthGate decides whether to show auth screen or the feed.
      // The home is no longer hardcoded to MarketplaceFeedScreen.
      child: MaterialApp(
        title: 'ResaleHub - 3-Party Booking Resale Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// V-02 FIX: AuthGate enforces authentication on app startup.
/// Listens to [AuthProvider.isLoggedIn] and routes accordingly.
/// Users can ONLY reach [MainNavigationShell] after successful login.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      return const MainNavigationShell();
    }
    return const AuthScreen();
  }
}

