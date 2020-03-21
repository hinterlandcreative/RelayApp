import 'dto.dart';
import 'package:sembast/sembast.dart';

import 'app_database.dart';
import 'db_collection.dart';
import 'query_package.dart';

class SembastDatabase extends AppDatabase {
  Database _db;
  
  SembastDatabase(Database db) {
    _db = db;
  }
  @override
  DbCollection collections(String collectionName) {
    return SembastStore(_db, collectionName);
  }
}

class SembastStore extends DbCollection {
  Database _db;

  String _storeName;

  SembastStore(Database db, String storeName) {
    _db = db;
    
    _storeName = storeName;
  }

  @override
  Future<int> add(DTO dto) async {
    if(dto.id != -1) {
      await update(dto);
      return dto.id;
    }
    var store = intMapStoreFactory.store(_storeName);

    int newId;
    await _db.transaction((txn) async {
      newId = await store.add((txn), dto.toMap());
    });

    return newId;
  }

  @override
  Future deleteFromDto(DTO dto) async {
    if(dto.id == -1) {
      return;
    }

    await deleteFromId(dto.id);
  }

  @override
  Future deleteFromId(int id) async {
    if(id == -1) {
      return;
    }

    var store = intMapStoreFactory.store(_storeName);

    await _db.transaction((txn) async {
      await store.record(id).delete(txn);
    });
  }

  @override
  Future<List<T>> query<T extends DTO>(List<QueryPackage> query, T Function(Map<String, dynamic>) itemCreator, {SortOrderType sort, String sortKey}) async {
    Finder finder;

    if(query.length == 1) {
      finder = Finder(
        filter: _getFilter(query[0]),
      );
    } else {
      finder = Finder(
        filter: Filter.and(
          query
            .map((q) => _getFilter(q))
            .toList()
        )
      );
    }
    if(sort != null && sortKey.isNotEmpty) {
      finder.sortOrder = SortOrder(sortKey, sort == SortOrderType.Ascending);
    }

    final store = intMapStoreFactory.store(_storeName);
    List<RecordSnapshot<int, Map<String, dynamic>>> records;
    await _db.transaction((txn) async {
      records = await store.find(txn, finder: finder);
    });

    return records
      .map((r) {
        r.value["id"] = r.key;
        return itemCreator(r.value);
      })
      .toList();
  }
    
  @override
  Future update(DTO dto) async {
    if(dto.id == -1) {
      await add(dto);
      return;
    }

    var store = intMapStoreFactory.store(_storeName);

    await _db.transaction((txn) async {
      await store.record(dto.id).put(txn, dto.toMap());
    });
  }

  @override
  Future<List<T>> getAll<T extends DTO>(T Function(Map<String, dynamic>) itemCreator) async {
    var store = intMapStoreFactory.store(_storeName);

    List<RecordSnapshot<int, Map<String, dynamic>>> records;

    await _db.transaction((txn) async {
      records = await store.find(txn);
    });

    return records
      .map((r) {
        r.value["id"] = r.key;
        return itemCreator(r.value);
      })
      .toList();
  }

  @override
  Future<List<T>> search<T extends DTO>(String query, T Function(Map<String, dynamic>) itemCreator) async {
    var finder = Finder(filter: Filter.matches("searchString", ".*$query.*"));
    var store = intMapStoreFactory.store(_storeName);

    List<RecordSnapshot<int, Map<String, dynamic>>> records;
    await _db.transaction((txn) async {
      records = await store.find(txn, finder: finder);
    });

    return records
      .map((r) {
        r.value["id"] = r.key;
        return itemCreator(r.value);
      })
      .toList();
  }

  Filter _getFilter(QueryPackage query) {
    final field = query.key;
    final value = query.value;

    switch(query.filter) {
      case FilterType.GreaterThan:
        return Filter.greaterThan(field, value);
        break;
      case FilterType.LessThan:
        return Filter.lessThan(field, value);
        break;
      case FilterType.NotEqualTo:
        return Filter.notEquals(field, value);
        break;
      case FilterType.GreaterThanOrEqualTo:
        return Filter.greaterThanOrEquals(field, value);
        break;
      case FilterType.LessThanOrEqualTo:
        return Filter.lessThanOrEquals(field, value);
        break;
      default:
        // default case is equals.
        return Filter.equals(field, value);
        break;
    }
  }
}