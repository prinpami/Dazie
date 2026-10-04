import 'package:sembast/sembast.dart';

import '../models/local_profile.dart';
import 'id_generator.dart';

class ProfileRepository {
  ProfileRepository(Database database)
    : _profiles = stringMapStoreFactory.store('profiles'),
      _database = database;

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _profiles;
  static const _currentProfileKey = 'current';

  Future<LocalProfile?> getCurrentProfile() async {
    final map = await _profiles.record(_currentProfileKey).get(_database);
    if (map == null || map['id'] is! String) return null;
    return LocalProfile.fromMap(map);
  }

  Future<List<LocalProfile>> getProfiles() async {
    final byId = <String, LocalProfile>{};
    for (final record in await _profiles.find(_database)) {
      if (record.key == _currentProfileKey) continue;
      try {
        final profile = LocalProfile.fromMap(record.value);
        byId[profile.id] = profile;
      } on Object {
        // Ignore malformed records and keep valid local accounts available.
      }
    }

    // Older versions stored the only profile only under `current`.
    final current = await getCurrentProfile();
    if (current != null) byId[current.id] = current;
    final profiles = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return profiles;
  }

  Future<void> activateProfile(String profileId) async {
    final map = await _profiles.record(profileId).get(_database);
    LocalProfile profile;
    if (map != null) {
      profile = LocalProfile.fromMap(map);
    } else {
      // Migrate a legacy profile if its id was not yet copied to its own key.
      final current = await getCurrentProfile();
      if (current == null || current.id != profileId) {
        throw StateError('This account is no longer available on this phone.');
      }
      profile = current;
    }
    await _profiles.record(profileId).put(_database, profile.toMap());
    await _profiles.record(_currentProfileKey).put(_database, profile.toMap());
  }

  Future<void> clearCurrentProfile() async {
    await _database.transaction((txn) async {
      final currentRecord = _profiles.record(_currentProfileKey);
      final map = await currentRecord.get(txn);
      if (map != null && map['id'] is String) {
        final profile = LocalProfile.fromMap(map);
        await _profiles.record(profile.id).put(txn, profile.toMap());
      }
      await currentRecord.delete(txn);
    });
  }

  /// Creates and activates another local account without replacing saved ones.
  Future<LocalProfile> createProfile({required String username}) async {
    final name = username.trim();
    if (name.isEmpty) throw ArgumentError('Enter a display name.');
    return _database.transaction((txn) async {
      final records = await _profiles.find(txn);
      for (final record in records) {
        if (record.key == _currentProfileKey) continue;
        try {
          final existing = LocalProfile.fromMap(record.value);
          if (existing.username.toLowerCase() == name.toLowerCase()) {
            throw StateError(
              'An account with this name already exists. Choose another name.',
            );
          }
        } on StateError {
          rethrow;
        } on Object {
          // A malformed unrelated record must not prevent registration.
        }
      }
      final profile = LocalProfile(
        id: makeId(),
        username: name,
        email: '',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );
      await _profiles.record(profile.id).put(txn, profile.toMap());
      await _profiles.record(_currentProfileKey).put(txn, profile.toMap());
      return profile;
    });
  }

  Future<LocalProfile> saveProfile({
    required String username,
    required String email,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    if (cleanUsername.isEmpty || !cleanEmail.contains('@')) {
      throw ArgumentError('Enter a username and a valid email address.');
    }
    final oldProfile = await getCurrentProfile();
    final profile = LocalProfile(
      id: oldProfile?.id ?? makeId(),
      username: cleanUsername,
      email: cleanEmail,
      createdAt:
          oldProfile?.createdAt ?? DateTime.now().toUtc().toIso8601String(),
    );
    await _profiles.record(profile.id).put(_database, profile.toMap());
    await _profiles.record(_currentProfileKey).put(_database, profile.toMap());
    return profile;
  }

  Future<LocalProfile?> findByIdentity(String identity) async {
    final search = identity.trim().toLowerCase();
    for (final profile in await getProfiles()) {
      if (profile.username.toLowerCase() == search ||
          profile.email.toLowerCase() == search) {
        return profile;
      }
    }
    return null;
  }
}
