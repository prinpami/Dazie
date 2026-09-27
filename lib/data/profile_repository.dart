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
    return map == null ? null : LocalProfile.fromMap(map);
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
    await _profiles.record(_currentProfileKey).put(_database, profile.toMap());
    return profile;
  }

  Future<LocalProfile?> findByIdentity(String identity) async {
    final profile = await getCurrentProfile();
    if (profile == null) return null;
    final search = identity.trim().toLowerCase();
    if (profile.username.toLowerCase() == search ||
        profile.email.toLowerCase() == search) {
      return profile;
    }
    return null;
  }
}
