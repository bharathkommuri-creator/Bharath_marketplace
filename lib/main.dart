import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/transfer_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_screen.dart';
import 'views/navigation/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load secrets from .env file (excluded from git via .gitignore)
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.2;  // 20% of transactions for performance
      options.profilesSampleRate = 0.1;
      options.environment = sentryDsn.isEmpty ? 'development' : 'production';
    },
    appRunner: () => runApp(const ResaleMarketplaceApp()),
  );
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

