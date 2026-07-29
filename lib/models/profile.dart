enum UserRole { serviceProvider, seller, buyer }

extension UserRoleExtension on UserRole {
  String get nameString {
    switch (this) {
      case UserRole.serviceProvider:
        return 'Service Provider';
      case UserRole.seller:
        return 'Original Buyer (Seller)';
      case UserRole.buyer:
        return 'New Buyer';
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.serviceProvider:
        return 'service_provider';
      case UserRole.seller:
        return 'seller';
      case UserRole.buyer:
        return 'buyer';
    }
  }

  static UserRole fromString(String val) {
    switch (val.toLowerCase()) {
      case 'service_provider':
      case 'provider':
        return UserRole.serviceProvider;
      case 'seller':
        return UserRole.seller;
      default:
        return UserRole.buyer;
    }
  }
}

class Profile {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? businessName;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.businessName,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Anonymous',
      role: UserRoleExtension.fromString(json['role'] ?? 'buyer'),
      businessName: json['business_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.dbValue,
      'business_name': businessName,
      'avatar_url': avatarUrl,
    };
  }
}
