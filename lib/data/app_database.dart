import 'package:sembast/sembast_io.dart';

import 'database_factory.dart';

class AppDatabase {
  AppDatabase._(this.database);

  final Database database;

  static Future<AppDatabase> open() async {
    return AppDatabase._(await openPlatformDatabase());
  }

  static Future<AppDatabase> openForTesting(
    String path, {
    DatabaseFactory? factory,
  }) async {
    return AppDatabase._(
      await (factory ?? databaseFactoryIo).openDatabase(path),
    );
  }

  Future<void> close() => database.close();
}
