import 'package:sembast/sembast.dart';

import '../models/conversation.dart';
import 'id_generator.dart';

class ConversationRepository {
  ConversationRepository(Database database)
    : _groups = stringMapStoreFactory.store('groups'),
      _database = database;

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _groups;

  Future<Conversation> createGroup({
    required String name,
    required String ownerId,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || ownerId.isEmpty) {
      throw ArgumentError('A group name and owner are required.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final group = Conversation(
      id: makeId(),
      name: cleanName,
      memberIds: [ownerId],
      createdAt: now,
      updatedAt: now,
    );
    await _groups.record(group.id).put(_database, group.toMap());
    return group;
  }

  Future<Conversation?> getConversation(String id) async {
    final map = await _groups.record(id).get(_database);
    return map == null ? null : Conversation.fromMap(map);
  }

  Future<void> saveConversation(Conversation conversation) async {
    await _groups.record(conversation.id).put(_database, conversation.toMap());
  }

  Future<void> addMember(String groupId, String peerId) async {
    final conversation = await getConversation(groupId);
    if (conversation == null || conversation.memberIds.contains(peerId)) return;
    await saveConversation(
      Conversation(
        id: conversation.id,
        name: conversation.name,
        memberIds: [...conversation.memberIds, peerId],
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        lastMessage: conversation.lastMessage,
        isGroup: conversation.isGroup,
      ),
    );
  }

  Future<void> updateLastMessage(String groupId, String text) async {
    final conversation = await getConversation(groupId);
    if (conversation == null) return;
    await saveConversation(
      Conversation(
        id: conversation.id,
        name: conversation.name,
        memberIds: conversation.memberIds,
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        lastMessage: text,
        isGroup: conversation.isGroup,
      ),
    );
  }

  Stream<List<Conversation>> watchConversations() {
    final query = _groups.query(
      finder: Finder(sortOrders: [SortOrder('updatedAt', false)]),
    );
    return query
        .onSnapshots(_database)
        .map(
          (snapshots) => snapshots
              .map((snapshot) => Conversation.fromMap(snapshot.value))
              .toList(),
        );
  }
}
