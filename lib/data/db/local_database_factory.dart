import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'package:relay/data/db/app_database.dart';
import 'package:relay/data/db/database_factory.dart';
import 'package:relay/data/db/sembast_database.dart';

class SembastDatabaseFactory extends LocalDatabaseFactory {
  @override
  Future<AppDatabase> create(String dbName) async {
    final directory  = await getApplicationDocumentsDirectory();

    final dbPath = join(directory.path, dbName);

    final db = await databaseFactoryIo.openDatabase(dbPath);

    return SembastDatabase(db);
  }
}