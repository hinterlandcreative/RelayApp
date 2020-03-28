import 'package:relay/data/db/app_database.dart';

abstract class DatabaseFactory {
  Future<AppDatabase> create(String dbName);
}

abstract class LocalDatabaseFactory extends DatabaseFactory {}
abstract class RemoteDatabaseFactory extends DatabaseFactory {}