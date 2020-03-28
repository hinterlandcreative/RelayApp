import 'package:relay/data/db/db_collection.dart';

abstract class AppDatabase {
  int get version => null;
  Future updateVersion(int version);
  DbCollection collections(String collectionName);
}