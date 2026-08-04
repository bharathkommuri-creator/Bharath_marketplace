import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/transfer_chat.dart';

/// Supabase persistence layer for 3-party transfer chat messages.
///
/// Maps to the `transfer_chats` table. Uses the `ad_id` text column
/// to store Flutter app listing IDs (e.g. 'l-b-101') since the DB was
/// originally designed with UUID foreign keys.
///
/// Table columns used:
///   ad_id        TEXT           — listing ID from the Flutter app
///   sender_name  TEXT           — display name of the sender
///   sender_role  user_role ENUM — 'buyer' | 'seller' | 'service_provider'
///   message      TEXT           — chat message body
///   created_at   TIMESTAMPTZ    — auto-set by Postgres DEFAULT NOW()
class ChatService {
  static final _db = Supabase.instance.client;
  static const _table = 'transfer_chats';

  // ---------------------------------------------------------------------------
  // READ: Load existing messages for a listing (one-shot fetch)
  // ---------------------------------------------------------------------------

  /// Fetches all messages for [listingId] ordered by send time (oldest first).
  /// Returns an empty list on any error so the UI degrades gracefully.
  static Future<List<TransferChatMessage>> loadMessages(
      String listingId) async {
    try {
      final rows = await _db
          .from(_table)
          .select('id, ad_id, sender_name, sender_role, message, created_at')
          .eq('ad_id', listingId)
          .order('created_at', ascending: true);

      return rows.map(_rowToMessage).toList();
    } catch (e) {
      debugPrint('[ChatService] loadMessages error for $listingId: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // WRITE: Persist a new message to Supabase
  // ---------------------------------------------------------------------------

  /// Inserts a new chat message into the `transfer_chats` table.
  /// Returns the persisted [TransferChatMessage] (with DB-generated id/timestamp).
  /// Throws on insert failure so callers can handle it (e.g. show a snackbar).
  static Future<TransferChatMessage> insertMessage({
    required String listingId,
    required Profile sender,
    required String message,
  }) async {
    final row = await _db
        .from(_table)
        .insert({
          'ad_id': listingId,
          'sender_name': sender.fullName,
          'sender_role': sender.role.dbValue,
          'message': message,
          // listing_id and sender_id are nullable (per migration) —
          // we use ad_id + sender_name instead for the demo setup.
        })
        .select('id, ad_id, sender_name, sender_role, message, created_at')
        .single();

    return _rowToMessage(row);
  }

  // ---------------------------------------------------------------------------
  // STREAM: Real-time live updates via Supabase Realtime
  // ---------------------------------------------------------------------------

  /// Returns a live [Stream] that emits the full updated message list
  /// every time any message is inserted for [listingId].
  ///
  /// Use this in a [StreamBuilder] for real-time chat display.
  static Stream<List<TransferChatMessage>> streamMessages(String listingId) {
    return _db
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('ad_id', listingId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(_rowToMessage).toList());
  }

  // ---------------------------------------------------------------------------
  // Private: row → model conversion
  // ---------------------------------------------------------------------------

  static TransferChatMessage _rowToMessage(Map<String, dynamic> row) {
    return TransferChatMessage(
      id: row['id']?.toString() ?? '',
      listingId: row['ad_id']?.toString() ?? '',
      senderId: row['sender_id']?.toString() ?? 'anon',
      senderName: row['sender_name']?.toString() ?? 'Unknown',
      senderRole:
          UserRoleExtension.fromString(row['sender_role']?.toString() ?? 'buyer'),
      message: row['message']?.toString() ?? '',
      actionType: row['action_trigger']?.toString(),
      timestamp: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
