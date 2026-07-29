import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/transfer_provider.dart';
import 'theme/app_theme.dart';
import 'views/feed/marketplace_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://vpcaqnhypswvnjgqvwks.supabase.co',
    anonKey: 'sb_publishable_yEfM--GMDtwnTTmSmQAHoQ_kistod28',
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
      child: MaterialApp(
        title: 'ResaleHub - 3-Party Booking Resale Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MarketplaceFeedScreen(),
      ),
    );
  }
}
