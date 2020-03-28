import 'package:get_it/get_it.dart';

import 'package:relay/services/contacts_service.dart';
import 'package:relay/services/purchases_service.dart';
import 'package:relay/services/analytics_service.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/services/message_service.dart';
import 'package:relay/services/image_service.dart';
import 'package:relay/services/group_service.dart';
import 'package:relay/services/database_service.dart';
import 'package:relay/data/db/database_factory.dart';
import 'package:relay/data/db/database_provider.dart';
import 'package:relay/data/db/local_database_factory.dart';
import 'package:relay/data/db/remote_database_factory.dart';

final dependencyLocator = GetIt.instance;

class DependencyRegistrar {

  /// Register app dependencies.
  static void registerDependencies() {
    dependencyLocator.registerSingleton(AnalyticsService());
    dependencyLocator.registerSingleton(AppSettingsService());
    dependencyLocator.registerSingleton<LocalDatabaseFactory>(SembastDatabaseFactory());
    dependencyLocator.registerSingleton<RemoteDatabaseFactory>(FirebaseDatabaseFactory());
    dependencyLocator.registerSingleton(DatabaseProvider());
    dependencyLocator.registerSingleton(DatabaseService());
    dependencyLocator.registerSingleton(ContactsService());
    dependencyLocator.registerSingleton(ImageService());
    dependencyLocator.registerSingleton(GroupService());
    dependencyLocator.registerSingleton(MessageService());
    dependencyLocator.registerSingleton(PurchasesService());
  }
}