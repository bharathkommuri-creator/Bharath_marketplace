import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/resale_listing.dart';
import '../models/transfer_chat.dart';
import '../services/chat_service.dart';

class TransferProvider extends ChangeNotifier {
  // In-memory cache — used for optimistic UI updates while Supabase responds.
  final Map<String, List<TransferChatMessage>> _chatThreads = {};
  final Map<String, TransferStep> _listingTransferSteps = {};

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Returns cached messages for [listingId].
  /// Triggers a background load from Supabase on first call so the cache
  /// stays warm — any new DB messages will also arrive via the StreamBuilder
  /// in TriPartyChat directly.
  List<TransferChatMessage> getMessages(String listingId) {
    if (!_chatThreads.containsKey(listingId)) {
      // Start with empty list — real messages load from Supabase.
      _chatThreads[listingId] = [];
      _loadFromSupabase(listingId);
    }
    return _chatThreads[listingId]!;
  }

  TransferStep getStep(ResaleListing listing) {
    return _listingTransferSteps[listing.id] ?? listing.transferStep;
  }

  // ---------------------------------------------------------------------------
  // WRITE: sendMessage — optimistic update + Supabase persist
  // ---------------------------------------------------------------------------

  /// Sends a chat message.
  ///
  /// 1. Adds the message to the local cache immediately for instant UI feedback.
  /// 2. Persists it to Supabase `transfer_chats` in the background.
  ///
  /// The [TriPartyChat] StreamBuilder picks up the DB insert via Realtime,
  /// so users on other devices see the message without reloading.
  void sendMessage(String listingId, Profile sender, String text) {
    // Optimistic in-memory update — shows instantly in UI.
    final optimistic = TransferChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      senderId: sender.id,
      senderName: sender.fullName,
      senderRole: sender.role,
      message: text,
      timestamp: DateTime.now(),
    );

    _chatThreads.putIfAbsent(listingId, () => []).add(optimistic);
    notifyListeners();

    // Persist to Supabase — fire and forget (errors logged, not thrown).
    _persistMessage(listingId: listingId, sender: sender, message: text);
  }

  // ---------------------------------------------------------------------------
  // V-05 FIX: Privileged transfer actions with ownership verification
  // ---------------------------------------------------------------------------

  /// A new buyer claims the slot.
  void claimSlot(ResaleListing listing, Profile buyer) {
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.listed) {
      throw StateError(
        'Cannot claim listing "${listing.id}": already in state $currentStep.',
      );
    }
    if (buyer.id == listing.sellerId) {
      throw UnimplementedError('User "${buyer.id}" cannot claim their own listing.');
    }

    _listingTransferSteps[listing.id] = TransferStep.claimed;
    sendMessage(
      listing.id,
      buyer,
      'claimed_slot_action: New Buyer (${buyer.fullName}) has reserved funds and requested transfer approval.',
    );
    notifyListeners();
  }

  /// The service provider confirms the slot transfer.
  void providerApprove(ResaleListing listing, Profile provider) {
    if (provider.id != listing.booking.providerId) {
      throw UnimplementedError(
        'Provider "${provider.id}" is not authorized to approve listing '
        '"${listing.id}" (expected: "${listing.booking.providerId}").',
      );
    }
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.claimed) {
      throw StateError(
        'Cannot approve listing "${listing.id}": expected "claimed", found "$currentStep".',
      );
    }

    _listingTransferSteps[listing.id] = TransferStep.providerVerified;
    sendMessage(
      listing.id,
      provider,
      'provider_verified_action: Service Provider (${provider.fullName}) has updated the reservation name and confirmed slot transfer.',
    );
    notifyListeners();
  }

  /// The original seller releases the slot to complete the transfer.
  void completeTransfer(ResaleListing listing, Profile seller) {
    if (seller.id != listing.sellerId) {
      throw UnimplementedError(
        'User "${seller.id}" is not the seller of listing "${listing.id}".',
      );
    }
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.providerVerified) {
      throw StateError(
        'Cannot complete transfer "${listing.id}": expected "providerVerified", found "$currentStep".',
      );
    }

    _listingTransferSteps[listing.id] = TransferStep.completed;
    sendMessage(
      listing.id,
      seller,
      'completed_action: Original Buyer (${seller.fullName}) has released the slot. Transfer is 100% complete!',
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private: background Supabase fetch
  // ---------------------------------------------------------------------------

  Future<void> _loadFromSupabase(String listingId) async {
    try {
      final dbMessages = await ChatService.loadMessages(listingId);
      if (dbMessages.isNotEmpty) {
        // Replace mock data with real DB messages.
        _chatThreads[listingId] = dbMessages;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[TransferProvider] Could not load messages from Supabase: $e');
      // Keep mock messages as fallback — UI stays functional.
    }
  }

  Future<void> _persistMessage({
    required String listingId,
    required Profile sender,
    required String message,
  }) async {
    try {
      await ChatService.insertMessage(
        listingId: listingId,
        sender: sender,
        message: message,
      );
    } catch (e) {
      debugPrint('[TransferProvider] Failed to persist message to Supabase: $e');
    }
  }
}

