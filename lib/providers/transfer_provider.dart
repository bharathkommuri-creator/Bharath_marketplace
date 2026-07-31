import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/resale_listing.dart';
import '../models/transfer_chat.dart';
import '../services/mock_data_service.dart';

class TransferProvider extends ChangeNotifier {
  final Map<String, List<TransferChatMessage>> _chatThreads = {};
  final Map<String, TransferStep> _listingTransferSteps = {};

  List<TransferChatMessage> getMessages(String listingId) {
    if (!_chatThreads.containsKey(listingId)) {
      _chatThreads[listingId] = MockDataService.getInitialChatMessages(listingId);
    }
    return _chatThreads[listingId]!;
  }

  TransferStep getStep(ResaleListing listing) {
    return _listingTransferSteps[listing.id] ?? listing.transferStep;
  }

  void sendMessage(String listingId, Profile sender, String text) {
    final msg = TransferChatMessage(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      senderId: sender.id,
      senderName: sender.fullName,
      senderRole: sender.role,
      message: text,
      timestamp: DateTime.now(),
    );

    if (!_chatThreads.containsKey(listingId)) {
      _chatThreads[listingId] = [];
    }
    _chatThreads[listingId]!.add(msg);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // V-05 FIX: All privileged transfer actions now verify that the caller
  // is actually the authorized party for the given listing before proceeding.
  // ---------------------------------------------------------------------------

  /// A new buyer claims the slot.
  /// Authorization: any authenticated buyer may claim an ACTIVE listing.
  /// The listing must be in [TransferStep.listed] state.
  void claimSlot(ResaleListing listing, Profile buyer) {
    // V-05: Verify the listing is in a claimable state.
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.listed) {
      throw StateError(
        'Cannot claim listing "${listing.id}": it is already in state $currentStep.',
      );
    }
    // V-05: Verify the buyer is not the seller themselves (no self-purchase).
    if (buyer.id == listing.sellerId) {
      throw UnimplementedError(
        'User "${buyer.id}" cannot claim their own listing.',
      );
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
  /// Authorization: only the provider whose ID matches [listing.booking.providerId].
  void providerApprove(ResaleListing listing, Profile provider) {
    // V-05: Verify caller is actually the provider for THIS listing.
    if (provider.id != listing.booking.providerId) {
      throw UnimplementedError(
        'Provider "${provider.id}" is not authorized to approve listing '
        '"${listing.id}" (expected provider: "${listing.booking.providerId}").',
      );
    }
    // V-05: Verify the listing is in the correct state for this action.
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.claimed) {
      throw StateError(
        'Cannot approve listing "${listing.id}": expected state "claimed", '
        'but found "$currentStep".',
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
  /// Authorization: only the user whose ID matches [listing.sellerId].
  void completeTransfer(ResaleListing listing, Profile seller) {
    // V-05: Verify caller is actually the original seller for THIS listing.
    if (seller.id != listing.sellerId) {
      throw UnimplementedError(
        'User "${seller.id}" is not the seller of listing "${listing.id}" '
        '(expected seller: "${listing.sellerId}").',
      );
    }
    // V-05: Verify the listing is in the correct state for this action.
    final currentStep = getStep(listing);
    if (currentStep != TransferStep.providerVerified) {
      throw StateError(
        'Cannot complete transfer for listing "${listing.id}": expected state '
        '"providerVerified", but found "$currentStep".',
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
}
