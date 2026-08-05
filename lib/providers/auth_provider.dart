import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _currentProfile;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _lastError;

  Profile? get currentProfile => _currentProfile;
  UserRole get currentRole => _currentProfile?.role ?? UserRole.buyer;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  AuthProvider() {
    _initSupabaseSession();
  }

  /// Restores active Supabase Auth session on app launch
  Future<void> _initSupabaseSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final profile = await _fetchProfileFromSupabase(session.user.id);

        if (profile != null) {
          _currentProfile = profile;
          _isLoggedIn = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] Supabase session init notice: $e');
    }
  }

  /// Production Supabase Signup
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? businessName,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    if (role != UserRole.buyer) {
      _setFailure('New accounts must be registered as buyers.');
      return false;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          // Account roles are assigned server-side. Never trust role metadata
          // supplied by a client during public registration.
          'role': UserRole.buyer.dbValue,
          if (businessName != null) 'business_name': businessName.trim(),
        },
      );

      if (response.user == null) {
        throw const AuthException('Account creation did not return a user.');
      }

      // With email confirmation enabled Supabase creates a user but no session.
      // The app must not grant authenticated access until confirmation is done.
      if (response.session == null) {
        _setFailure(
            'Check your email and confirm your account before signing in.');
        return false;
      }

      final profile = await _fetchProfileFromSupabase(response.user!.id);
      if (profile == null) {
        throw const AuthException(
            'Your account was created, but its profile is not ready. Please sign in again shortly.');
      }

      _currentProfile = profile;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setFailure(e.message);
    } catch (e) {
      debugPrint('[AuthProvider] Supabase signUp exception: $e');
      _setFailure('Unable to create your account. Please try again.');
    }
    return false;
  }

  /// Production Supabase login. Roles always come from the profile record.
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      if (cleanEmail.isEmpty || password.isEmpty) {
        throw const AuthException(
            'Enter both your email address and password.');
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('Sign in did not return a user.');
      }

      final profile = await _fetchProfileFromSupabase(response.user!.id);
      if (profile == null) {
        throw const AuthException('Your account profile could not be loaded.');
      }

      _currentProfile = profile;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setFailure(e.message);
    } catch (e) {
      debugPrint('[AuthProvider] Supabase signIn error: $e');
      _setFailure('Unable to sign in. Please try again.');
    }
    return false;
  }

  /// Production Supabase Logout
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthProvider] Supabase signOut notice: $e');
    }
    _currentProfile = null;
    _isLoggedIn = false;
    _lastError = null;
    notifyListeners();
  }

  /// Demo-only sign-in. Production builds cannot enter a local session.
  bool signInAsDemo(UserRole role) {
    if (!kDebugMode) {
      _setFailure('Demo accounts are unavailable in production.');
      return false;
    }
    switchRole(role);
    _isLoggedIn = true;
    _lastError = null;
    notifyListeners();
    return true;
  }

  /// Demo Role Persona Switcher
  bool switchRole(UserRole newRole) {
    if (!kDebugMode) {
      return false;
    }
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
    return true;
  }

  void _setFailure(String message) {
    _isLoading = false;
    _lastError = message;
    notifyListeners();
  }

  /// Fetches profile row from PostgreSQL `profiles` table
  Future<Profile?> _fetchProfileFromSupabase(String userId) async {
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email, role')
          .eq('id', userId)
          .maybeSingle();

      if (row != null) {
        UserRole role = UserRole.buyer;
        final roleStr = row['role'] as String?;
        if (roleStr == 'seller') role = UserRole.seller;
        if (roleStr == 'service_provider') role = UserRole.serviceProvider;

        return Profile(
          id: row['id'] as String,
          fullName: row['full_name'] as String,
          email: row['email'] as String,
          role: role,
        );
      }
    } catch (e) {
      debugPrint('[AuthProvider] _fetchProfileFromSupabase error: $e');
    }
    return null;
  }
}
