import 'package:path/path.dart' as paths;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openPlatformDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final databasePath = paths.join(directory.path, 'dazie.db');
  return databaseFactoryIo.openDatabase(databasePath);
}
