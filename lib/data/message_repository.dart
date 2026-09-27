import 'package:sembast/sembast.dart';

import '../models/chat_message.dart';
import 'conversation_repository.dart';
import 'id_generator.dart';

class MessageRepository {
  MessageRepository(Database database, this._conversations)
    : _messages = stringMapStoreFactory.store('messages'),
      _database = database;

  final Database _database;
  final ConversationRepository _conversations;
  final StoreRef<String, Map<String, Object?>> _messages;

  Future<ChatMessage> createMessage({
    required String groupId,
    required String senderId,
    required String sender,
    required String text,
    required bool isMine,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || cleanText.length > 2000 || senderId.isEmpty) {
      throw ArgumentError('Messages need a sender and 1 to 2000 characters.');
    }
    final message = ChatMessage(
      id: makeId(),
      groupId: groupId,
      senderId: senderId,
      sender: sender,
      text: cleanText,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      isMine: isMine,
      deliveryStatus: isMine ? 'queued' : 'received',
    );
    await saveMessage(message);
    return message;
  }

  Future<bool> saveMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty || message.text.length > 2000) {
      throw ArgumentError('Messages must have 1 to 2000 characters.');
    }
    if (await _conversations.getConversation(message.groupId) == null) {
      throw StateError('The message group has not been saved on this device.');
    }
    final existing = await _messages.record(message.id).get(_database);
    if (existing != null) return false;
    await _messages.record(message.id).put(_database, message.toMap());
    await _conversations.updateLastMessage(message.groupId, message.text);
    return true;
  }

  Future<void> updateDeliveryStatus(String messageId, String status) async {
    final message = await _messages.record(messageId).get(_database);
    if (message == null) return;
    if (message['deliveryStatus'] == 'delivered' && status != 'delivered') {
      return;
    }
    await _messages.record(messageId).update(_database, {
      'deliveryStatus': status,
    });
  }

  Future<List<ChatMessage>> getLatestMessages(
    String groupId, {
    int limit = 50,
  }) async {
    final snapshots = await _messages.find(
      _database,
      finder: Finder(
        filter: Filter.equals('groupId', groupId),
        sortOrders: [SortOrder('createdAt', false)],
        limit: limit,
      ),
    );
    return snapshots
        .map((snapshot) => ChatMessage.fromMap(snapshot.value))
        .toList()
        .reversed
        .toList();
  }

  Stream<List<ChatMessage>> watchMessages(String groupId) {
    final query = _messages.query(
      finder: Finder(
        filter: Filter.equals('groupId', groupId),
        sortOrders: [SortOrder('createdAt')],
      ),
    );
    return query
        .onSnapshots(_database)
        .map(
          (snapshots) => snapshots
              .map((snapshot) => ChatMessage.fromMap(snapshot.value))
              .toList(),
        );
  }
}
