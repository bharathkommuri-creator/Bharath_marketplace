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

  void claimSlot(String listingId, Profile buyer) {
    _listingTransferSteps[listingId] = TransferStep.claimed;
    sendMessage(
      listingId,
      buyer,
      'claimed_slot_action: New Buyer (${buyer.fullName}) has reserved funds and requested transfer approval.',
    );
    notifyListeners();
  }

  void providerApprove(String listingId, Profile provider) {
    _listingTransferSteps[listingId] = TransferStep.providerVerified;
    sendMessage(
      listingId,
      provider,
      'provider_verified_action: Service Provider (${provider.fullName}) has updated the reservation name and confirmed slot transfer.',
    );
    notifyListeners();
  }

  void completeTransfer(String listingId, Profile seller) {
    _listingTransferSteps[listingId] = TransferStep.completed;
    sendMessage(
      listingId,
      seller,
      'completed_action: Original Buyer (${seller.fullName}) has released the slot. Transfer is 100% complete!',
    );
    notifyListeners();
  }
}
