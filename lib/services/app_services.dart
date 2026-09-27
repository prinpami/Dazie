import '../data/app_database.dart';
import '../data/conversation_repository.dart';
import '../data/message_repository.dart';
import '../data/peer_repository.dart';
import '../data/profile_repository.dart';
import '../data/settings_repository.dart';

import 'package:sembast/sembast_io.dart';

import 'chat_sync_service.dart';
import 'nearby_service.dart';
import 'nearby_service_factory.dart';

class AppServices {
  AppServices._({
    required this.database,
    required this.profiles,
    required this.peers,
    required this.conversations,
    required this.messages,
    required this.settings,
    required this.nearby,
    required this.chatSync,
  });

  final AppDatabase database;
  final ProfileRepository profiles;
  final PeerRepository peers;
  final ConversationRepository conversations;
  final MessageRepository messages;
  final SettingsRepository settings;
  final NearbyService nearby;
  final ChatSyncService chatSync;

  static Future<AppServices> open({
    String? testDatabasePath,
    DatabaseFactory? testDatabaseFactory,
    NearbyService? nearbyService,
  }) async {
    final database = testDatabasePath == null
        ? await AppDatabase.open()
        : await AppDatabase.openForTesting(
            testDatabasePath,
            factory: testDatabaseFactory,
          );
    final profiles = ProfileRepository(database.database);
    final peers = PeerRepository(database.database);
    final conversations = ConversationRepository(database.database);
    final messages = MessageRepository(database.database, conversations);
    final settings = SettingsRepository(database.database);
    final nearby = nearbyService ?? createNearbyService();
    final chatSync = ChatSyncService(
      nearby: nearby,
      profiles: profiles,
      peers: peers,
      conversations: conversations,
      messages: messages,
    );
    return AppServices._(
      database: database,
      profiles: profiles,
      peers: peers,
      conversations: conversations,
      messages: messages,
      settings: settings,
      nearby: nearby,
      chatSync: chatSync,
    );
  }

  Future<void> close() async {
    await chatSync.dispose();
    await nearby.stop();
    await database.close();
  }
}
