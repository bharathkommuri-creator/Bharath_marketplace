import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  Profile _currentProfile = MockDataService.currentBuyer;
  bool _isLoggedIn = true;

  Profile get currentProfile => _currentProfile;
  UserRole get currentRole => _currentProfile.role;
  bool get isLoggedIn => _isLoggedIn;

  void switchRole(UserRole newRole) {
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

  void login(String email, String password, UserRole role) {
    switchRole(role);
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
