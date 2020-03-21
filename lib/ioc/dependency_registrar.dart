import 'package:get_it/get_it.dart';
import '../data/db/database_factory.dart';
import '../data/db/database_provider.dart';
import '../data/db/local_database_factory.dart';
import '../data/db/remote_database_factory.dart';
import '../services/database_service.dart';

final dependencyLocator = GetIt.instance;

class DependencyRegistrar {

  /// Register app dependencies.
  static void registerDependencies() {
    dependencyLocator.registerSingleton<LocalDatabaseFactory>(SembastDatabaseFactory());
    dependencyLocator.registerSingleton<RemoteDatabaseFactory>(FirebaseDatabaseFactory());
    dependencyLocator.registerSingleton(DatabaseProvider());
    dependencyLocator.registerSingleton(DatabaseService());
  }
}