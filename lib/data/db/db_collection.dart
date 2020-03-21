import 'dto.dart';
import 'query_package.dart';

abstract class DbCollection {
  /// delete the item by id.
  Future deleteFromId(int id);

  /// delete the supplied item.
  Future deleteFromDto(DTO dto);

  /// add a new item. If the item already exists, update it.
  Future<int> add(DTO dto);

  // update an existing item. If the item doesn't exist, add it.
  Future update(DTO dto);

  // Query the collection based on the provided [query]. If multiple queries are provided they are combined into an 'and' filter.
  // Optionally sorts the results based on [sortKey] of a specific field by the supplied [sort] order.
  Future<List<T>> query<T extends DTO>(List<QueryPackage> query, T Function(Map<String, dynamic>) itemCreator, {SortOrderType sort, String sortKey});

  /// get all the items in this collection.
  Future<List<T>> getAll<T extends DTO>(T Function(Map<String, dynamic>) itemCreator);

  /// Search all records for a specified [query] string
  Future<List<T>> search<T extends DTO>(String query, T Function(Map<String, dynamic>) itemCreator);
}

enum FilterType {
  EqualTo,
  GreaterThan,
  LessThan,
  NotEqualTo,
  GreaterThanOrEqualTo,
  LessThanOrEqualTo
}

enum SortOrderType {
  Ascending,
  Decending
}