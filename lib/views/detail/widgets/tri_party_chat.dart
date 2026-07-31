import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/profile.dart';
import '../../../models/resale_listing.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transfer_provider.dart';
import '../../../theme/app_theme.dart';

class TriPartyChat extends StatefulWidget {
  final ResaleListing listing;

  const TriPartyChat({Key? key, required this.listing}) : super(key: key);

  @override
  State<TriPartyChat> createState() => _TriPartyChatState();
}

class _TriPartyChatState extends State<TriPartyChat> {
  final TextEditingController _msgController = TextEditingController();

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.serviceProvider:
        return const Color(0xFF2563EB); // Royal Blue
      case UserRole.seller:
        return const Color(0xFFD97706); // Amber
      case UserRole.buyer:
        return AppTheme.primaryGreen; // Emerald
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transferProvider = Provider.of<TransferProvider>(context);
    final messages = transferProvider.getMessages(widget.listing.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.forum_outlined, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3-Party Communication Stream',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightMintBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 Members Active',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.darkForest),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Secure channel between Service Provider, Seller, and Buyer to confirm reservation transfer.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Divider(height: 24, color: AppTheme.borderLight),

          // Message Thread List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isAction = msg.message.contains('_action:');

              if (isAction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.lightMintBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          msg.message.replaceAll(RegExp(r'^\w+_action:\s*'), ''),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkForest),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final roleColor = _getRoleColor(msg.senderRole);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: roleColor.withOpacity(0.15),
                    child: Text(
                      msg.senderName[0].toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: roleColor, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                msg.senderName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  msg.senderRole.nameString,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            msg.message,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat('hh:mm a').format(msg.timestamp),
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Message Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText: 'Type a message as ${authProvider.currentRole.nameString}...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                onPressed: () {
                  // V-02 FIX: guard against null profile (unauthenticated)
                  final profile = authProvider.currentProfile;
                  if (_msgController.text.trim().isNotEmpty && profile != null) {
                    transferProvider.sendMessage(
                      widget.listing.id,
                      profile,
                      _msgController.text.trim(),
                    );
                    _msgController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
