import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resale_marketplace/providers/auth_provider.dart';
import 'package:resale_marketplace/providers/marketplace_provider.dart';
import 'package:resale_marketplace/providers/transfer_provider.dart';
import 'package:resale_marketplace/views/auth/auth_screen.dart';

void main() {
  testWidgets('TC-AUTH-002: AuthGate shows AuthScreen when logged out',
      (WidgetTester tester) async {
    final authProvider = AuthProvider();
    // Not logged in — should show auth screen

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
          ChangeNotifierProvider(create: (_) => TransferProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump();

    // Auth screen should show login/signup tabs
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
  });
}
