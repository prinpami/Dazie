import 'package:sembast/sembast.dart';

import 'database_factory_stub.dart'
    if (dart.library.io) 'database_factory_native.dart'
    if (dart.library.js_interop) 'database_factory_web.dart'
    as platform;

Future<Database> openPlatformDatabase() => platform.openPlatformDatabase();
