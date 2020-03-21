import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';
import 'database_factory.dart';
import 'sembast_database.dart';

class SembastDatabaseFactory extends LocalDatabaseFactory {

  @override
  Future<AppDatabase> create(String dbName) async {
    final directory  = await getApplicationDocumentsDirectory();

    final dbPath = join(directory.path, dbName);

    final db = await databaseFactoryIo.openDatabase(dbPath);

    return SembastDatabase(db);
  }
}