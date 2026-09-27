import 'package:sembast_web/sembast_web.dart';

Future<Database> openPlatformDatabase() =>
    databaseFactoryWeb.openDatabase('dazie');
