import 'package:sembast/sembast.dart';

import '../models/peer_profile.dart';

class PeerRepository {
  PeerRepository(Database database)
    : _peers = stringMapStoreFactory.store('peers'),
      _database = database;

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _peers;

  Future<void> savePeer(PeerProfile peer) async {
    await _peers.record(peer.id).put(_database, peer.toMap());
  }

  Future<PeerProfile?> getPeer(String id) async {
    final map = await _peers.record(id).get(_database);
    return map == null ? null : PeerProfile.fromMap(map);
  }
}
