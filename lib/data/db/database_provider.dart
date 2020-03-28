import 'package:path/path.dart';

import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/data/db/app_database.dart';
import 'package:relay/data/db/database_factory.dart';

class DatabaseProvider {
  LocalDatabaseFactory _localDbFactory;
  RemoteDatabaseFactory _remoteDbFactory;
  Map<String, AppDatabase> _localDatabases = Map<String, AppDatabase>();
  Map<String, AppDatabase> _remoteDatabases = Map<String, AppDatabase>();

  /// Creates an instance of the database provider.
  DatabaseProvider([LocalDatabaseFactory local, RemoteDatabaseFactory remote]) {
    

    _localDbFactory = local ?? dependencyLocator<LocalDatabaseFactory>();
    _remoteDbFactory = remote ?? dependencyLocator<RemoteDatabaseFactory>();
  }

/// Gets a local database with the given [dbName].
 Future<AppDatabase> getLocalDatabase(String dbName) async {
   final name = _normalizeName(dbName);
   if(_localDatabases.containsKey(name)) {
     return _localDatabases[name];
   }

    return _localDatabases[name] = await _localDbFactory.create(name);  
  }

  Future<AppDatabase> getRemoteDatabase(String dbName) async {
    final name = _normalizeName(dbName);
    if(_remoteDatabases.containsKey(name)) {
      return _remoteDatabases[name];
    }

    return _remoteDatabases[name] = await _remoteDbFactory.create(name);
  }

  String _normalizeName(String dbName) {
    if(!dbName.endsWith(".db")) {
      dbName = join(dbName, ".db");
    }
    
   return dbName.toLowerCase();
  }
}






  