import 'profile.dart';

class TransferChatMessage {
  final String id;
  final String listingId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String message;
  final String? actionType; // 'claim', 'provider_approve', 'release_payout'
  final DateTime timestamp;

  TransferChatMessage({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.actionType,
    required this.timestamp,
  });

  factory TransferChatMessage.fromJson(Map<String, dynamic> json) {
    return TransferChatMessage(
      id: json['id'] ?? '',
      listingId: json['listing_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? 'User',
      senderRole: UserRoleExtension.fromString(json['sender_role'] ?? 'buyer'),
      message: json['message'] ?? '',
      actionType: json['action_type'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
