import 'package:sembast/sembast.dart';

import '../models/chat_message.dart';
import 'conversation_repository.dart';
import 'id_generator.dart';

class MessageRepository {
  MessageRepository(Database database, ConversationRepository conversations)
    : _messages = stringMapStoreFactory.store('messages'),
      _database = database;

  final Database _database;
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
    return _database.transaction((txn) async {
      final groups = stringMapStoreFactory.store('groups');
      final group = await groups.record(message.groupId).get(txn);
      if (group == null) {
        throw StateError(
          'The message group has not been saved on this device.',
        );
      }
      if (await stringMapStoreFactory
              .store('deleted_messages')
              .record(message.id)
              .exists(txn) ||
          await _messages.record(message.id).exists(txn)) {
        return false;
      }
      await _messages.record(message.id).put(txn, message.toMap());
      final latest = await _messages.findFirst(
        txn,
        finder: Finder(
          filter: Filter.equals('groupId', message.groupId),
          sortOrders: [SortOrder('createdAt', false)],
        ),
      );
      await groups.record(message.groupId).update(txn, {
        'lastMessage': latest?.value['text'] ?? '',
        'updatedAt': latest?.value['createdAt'] ?? group['createdAt'],
      });
      return true;
    });
  }

  /// Local deletion is remembered so history sync cannot restore this message.
  Future<void> deleteMessage(String messageId) async {
    await _database.transaction((txn) async {
      final message = await _messages.record(messageId).get(txn);
      if (message == null) return;
      final groupId = message['groupId'] as String;
      await stringMapStoreFactory
          .store('deleted_messages')
          .record(messageId)
          .put(txn, {'groupId': groupId});
      await _messages.record(messageId).delete(txn);
      final latest = await _messages.findFirst(
        txn,
        finder: Finder(
          filter: Filter.equals('groupId', groupId),
          sortOrders: [SortOrder('createdAt', false)],
        ),
      );
      final group = stringMapStoreFactory.store('groups').record(groupId);
      final data = await group.get(txn);
      if (data != null) {
        await group.update(txn, {
          'lastMessage': latest?.value['text'] ?? '',
          'updatedAt': latest?.value['createdAt'] ?? data['createdAt'],
        });
      }
    });
  }

  Future<ChatMessage?> getMessage(String id) async {
    final map = await _messages.record(id).get(_database);
    return map == null ? null : ChatMessage.fromMap(map);
  }

  Future<List<ChatMessage>> getPendingMessages(String groupId) async {
    final records = await _messages.find(
      _database,
      finder: Finder(
        filter: Filter.and([
          Filter.equals('groupId', groupId),
          Filter.inList('deliveryStatus', ['queued', 'sent']),
        ]),
        sortOrders: [SortOrder('createdAt')],
      ),
    );
    return records.map((record) => ChatMessage.fromMap(record.value)).toList();
  }

  Future<void> updateDeliveryStatus(String messageId, String status) async {
    await _database.transaction((txn) async {
      final message = await _messages.record(messageId).get(txn);
      if (message == null) return;
      if (message['deliveryStatus'] == 'delivered' && status != 'delivered') {
        return;
      }
      await _messages.record(messageId).update(txn, {'deliveryStatus': status});
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
