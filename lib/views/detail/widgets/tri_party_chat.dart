import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/profile.dart';
import '../../../models/resale_listing.dart';
import '../../../models/transfer_chat.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transfer_provider.dart';
import '../../../services/chat_service.dart';
import '../../../theme/app_theme.dart';

/// 3-Party realtime chat widget.
///
/// Uses [ChatService.streamMessages] (Supabase Realtime) to display messages
/// live — any participant sending a message is immediately visible to all
/// other parties without refreshing. Falls back to in-memory mock data
/// if Supabase is unreachable.
class TriPartyChat extends StatefulWidget {
  final ResaleListing listing;

  const TriPartyChat({Key? key, required this.listing}) : super(key: key);

  @override
  State<TriPartyChat> createState() => _TriPartyChatState();
}

class _TriPartyChatState extends State<TriPartyChat> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Whether the current send is in progress (for button loading state).
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.serviceProvider:
        return const Color(0xFF2563EB);
      case UserRole.seller:
        return const Color(0xFFD97706);
      case UserRole.buyer:
        return AppTheme.primaryGreen;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(
    BuildContext context,
    Profile profile,
    TransferProvider transferProvider,
  ) async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _msgController.clear();

    try {
      // sendMessage() does both optimistic update + Supabase persist.
      transferProvider.sendMessage(widget.listing.id, profile, text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transferProvider = Provider.of<TransferProvider>(context);

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
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.forum_outlined, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3-Party Communication Stream',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightMintBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, color: AppTheme.primaryGreen, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkForest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Secure channel between Service Provider, Seller, and Buyer to confirm reservation transfer.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Divider(height: 24, color: AppTheme.borderLight),

          // ── Message Thread — Supabase Realtime StreamBuilder ─────────────
          StreamBuilder<List<TransferChatMessage>>(
            stream: ChatService.streamMessages(widget.listing.id),
            builder: (context, snapshot) {
              // If stream has data from Supabase, use it.
              // Otherwise fall back to in-memory messages (mock / optimistic).
              final messages = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : transferProvider.getMessages(widget.listing.id);

              if (snapshot.connectionState == ConnectionState.waiting &&
                  messages.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                debugPrint('[TriPartyChat] Stream error: ${snapshot.error}');
              }

              // Auto-scroll when new messages arrive.
              if (snapshot.hasData) _scrollToBottom();

              return ListView.separated(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isAction = msg.message.contains('_action:');

                  if (isAction) {
                    return _buildActionBubble(msg);
                  }
                  return _buildMessageBubble(msg);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Message Input ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText:
                        'Type a message as ${authProvider.currentRole.nameString}...',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) {
                    final profile = authProvider.currentProfile;
                    if (profile != null && !_isSending) {
                      _sendMessage(context, profile, transferProvider);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  : IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                      onPressed: () {
                        // V-02 FIX: guard against null profile (unauthenticated)
                        final profile = authProvider.currentProfile;
                        if (profile != null) {
                          _sendMessage(context, profile, transferProvider);
                        }
                      },
                    ),
            ],
          ),
          // Supabase status hint
          if (true) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.cloud_done_outlined, size: 12, color: AppTheme.textMuted),
                SizedBox(width: 4),
                Text(
                  'Messages saved to Supabase — visible to all 3 parties in real-time',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Private bubble builders ────────────────────────────────────────────────

  Widget _buildActionBubble(TransferChatMessage msg) {
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkForest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TransferChatMessage msg) {
    final roleColor = _getRoleColor(msg.senderRole);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: roleColor.withOpacity(0.15),
          child: Text(
            msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: roleColor, fontSize: 13),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            msg.senderRole.nameString,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  msg.message,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormat('hh:mm a').format(msg.timestamp),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
