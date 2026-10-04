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
      ownerId: ownerId,
      memberIds: [ownerId],
      createdAt: now,
      updatedAt: now,
    );
    await _groups.record(group.id).put(_database, group.toMap());
    return group;
  }

  Future<Conversation?> findOwnedGroup(String name, String ownerId) async {
    final groups = await _groups.find(_database);
    for (final record in groups) {
      final group = Conversation.fromMap(record.value);
      if (group.ownerId == ownerId &&
          group.name.trim().toLowerCase() == name.trim().toLowerCase()) {
        return group;
      }
    }
    return null;
  }

  Future<bool> isDeleted(String id) async => await stringMapStoreFactory
      .store('deleted_groups')
      .record(id)
      .exists(_database);

  Future<void> allowRejoin(String id) async {
    await stringMapStoreFactory
        .store('deleted_groups')
        .record(id)
        .delete(_database);
  }

  Future<void> deleteConversation(String id) async {
    await _database.transaction((txn) async {
      final messages = stringMapStoreFactory.store('messages');
      final finder = Finder(filter: Filter.equals('groupId', id));
      for (final record in await messages.find(txn, finder: finder)) {
        await stringMapStoreFactory
            .store('deleted_messages')
            .record(record.key)
            .put(txn, {'groupId': id});
      }
      await messages.delete(txn, finder: finder);
      await _groups.record(id).delete(txn);
      await stringMapStoreFactory.store('deleted_groups').record(id).put(txn, {
        'deleted': true,
      });
    });
  }

  Future<Conversation?> getConversation(String id) async {
    final map = await _groups.record(id).get(_database);
    return map == null ? null : Conversation.fromMap(map);
  }

  Future<void> saveConversation(Conversation conversation) async {
    await _groups.record(conversation.id).put(_database, conversation.toMap());
  }

  Future<void> addMember(String groupId, String peerId) async {
    await _database.transaction((txn) async {
      final record = _groups.record(groupId);
      final map = await record.get(txn);
      if (map == null) return;
      final members = (map['memberIds'] as List).whereType<String>().toSet();
      if (!members.add(peerId)) return;
      await record.update(txn, {'memberIds': members.toList()});
    });
  }

  Future<void> updateLastMessage(String groupId, String text) async {
    final conversation = await getConversation(groupId);
    if (conversation == null) return;
    await saveConversation(
      Conversation(
        id: conversation.id,
        name: conversation.name,
        ownerId: conversation.ownerId,
        memberIds: conversation.memberIds,
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        lastMessage: text,
        isGroup: conversation.isGroup,
      ),
    );
  }

  Stream<List<Conversation>> watchConversations({String? profileId}) {
    final query = _groups.query(
      finder: Finder(sortOrders: [SortOrder('updatedAt', false)]),
    );
    return query
        .onSnapshots(_database)
        .map(
          (snapshots) => snapshots
              .map((snapshot) => Conversation.fromMap(snapshot.value))
              .where(
                (conversation) =>
                    profileId == null ||
                    conversation.ownerId == profileId ||
                    conversation.memberIds.contains(profileId),
              )
              .toList(),
        );
  }
}
