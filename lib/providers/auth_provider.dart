import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  // V-02 FIX: Start as NOT logged in. Profile is nullable until authenticated.
  Profile? _currentProfile;
  bool _isLoggedIn = false;

  Profile? get currentProfile => _currentProfile;

  // Safe getter — callers must handle null (e.g. check isLoggedIn first).
  UserRole get currentRole => _currentProfile?.role ?? UserRole.buyer;
  bool get isLoggedIn => _isLoggedIn;

  /// V-03 FIX: Role is resolved from the server-side profile record,
  /// NOT from whatever role the client passes in.
  ///
  /// In production this would: call Supabase signInWithPassword(), then
  /// fetch the `profiles` table row to get the server-authoritative role.
  ///
  /// Here (mock): we look up the pre-seeded profile by email and use its
  /// stored role — the UI-selected role is ignored entirely.
  void login(String email, String password, UserRole ignoredClientRole) {
    // V-03: Resolve profile by email from the "server" (mock DB lookup).
    // The role embedded in the profile record is authoritative.
    final resolvedProfile = _resolveProfileByEmail(email.trim().toLowerCase());

    if (resolvedProfile == null) {
      // In production: throw an auth exception / show error dialog.
      debugPrint('[AuthProvider] Login failed: no profile found for $email');
      return;
    }

    // V-03: Password check (mock). Real impl: Supabase handles this server-side.
    if (!_validatePassword(email, password)) {
      debugPrint('[AuthProvider] Login failed: incorrect password for $email');
      return;
    }

    _currentProfile = resolvedProfile;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentProfile = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// V-03 FIX: switchRole() is now restricted to DEMO/development use only.
  /// In production this endpoint must be protected by server-side authorization.
  /// A buyer must NEVER be able to switch to serviceProvider role unilaterally.
  void switchRole(UserRole newRole) {
    // Guard: only allow in demo mode. In production, remove this entirely.
    assert(() {
      debugPrint('[AuthProvider] WARNING: switchRole() is for DEMO only. '
          'Real apps must validate role changes server-side.');
      return true;
    }());

    switch (newRole) {
      case UserRole.serviceProvider:
        _currentProfile = MockDataService.currentProvider;
        break;
      case UserRole.seller:
        _currentProfile = MockDataService.currentSeller;
        break;
      case UserRole.buyer:
        _currentProfile = MockDataService.currentBuyer;
        break;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers (mock "server-side" lookups)
  // ---------------------------------------------------------------------------

  /// V-03: Simulates a server-side profile lookup by email.
  /// In production: replaced by a Supabase `profiles` table query.
  Profile? _resolveProfileByEmail(String email) {

    // Mock lookup table keyed by email
    final profileMap = {
      MockDataService.currentBuyer.email.toLowerCase(): MockDataService.currentBuyer,
      MockDataService.currentSeller.email.toLowerCase(): MockDataService.currentSeller,
      MockDataService.currentProvider.email.toLowerCase(): MockDataService.currentProvider,
    };

    return profileMap[email];
  }

  /// V-04 (partial) / V-03: Mock password validation.
  /// In production: Supabase.auth.signInWithPassword() handles this securely.
  bool _validatePassword(String email, String password) {
    // In a real app this is NEVER done client-side.
    // Kept minimal here since real auth is delegated to Supabase.
    return password.isNotEmpty && password.length >= 6;
  }
}
