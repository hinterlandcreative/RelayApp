import 'db_collection.dart';

abstract class AppDatabase {
  DbCollection collections(String collectionName);
}