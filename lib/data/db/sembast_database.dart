import 'package:flutter/foundation.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';

import 'dto/dto.dart';
import 'package:sembast/sembast.dart';

import 'app_database.dart';
import 'db_collection.dart';
import 'query_package.dart';

class SembastDatabase implements AppDatabase {
  Database _db;
  
  SembastDatabase(Database db) {
    _db = db;
  }

  @override
  int get version => _db.version;
  
  @override
  DbCollection collections(String collectionName) {
    return SembastStore(_db, collectionName);
  }

  @override
  Future updateVersion(int version) async {
    assert(_db.version < version);
    var path = _db.path;
    var exported = await exportDatabase(_db);
    exported["version"] = version;
    _db.close();
    var db = await importDatabase(exported, databaseFactoryIo, path);
    _db = db;
  }
}

class SembastStore implements DbCollection {
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
    var map  = dto.toMap();
    await _db.transaction((txn) async {
      newId = await store.add((txn), map);
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
  Future<List<T>> query<T extends DTO>(List<QueryPackage> query, T Function(Map<String, dynamic>) itemCreator, {SortOrderType sort, String sortKey, bool findFirst = false}) async {
    Finder finder;

    if(query.length == 1) {
      finder = Finder(
        filter: _getFilter(query.first),
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
      if(findFirst) {
        records = [ await store.findFirst(txn, finder: finder) ];
      } else {
        records = await store.find(txn, finder: finder);
      }
    });

    return records
      .map((r) {
        var map = Map<String,dynamic>.from(r.value);
        map["id"] = r.key;
        return itemCreator(map);
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
        var map = Map<String,dynamic>.from(r.value);
        map["id"] = r.key;
        return itemCreator(map);
      })
      .toList();
  }

  @override
  Future<T> getOne<T extends DTO>(int id, {@required T Function(Map<String, dynamic>) itemCreator}) async {
    assert(id >= 0);
    assert(itemCreator != null);

    var store = intMapStoreFactory.store(_storeName);
    Map<String, dynamic> record;
    await _db.transaction((txn) async {
      if(await store.record(id).exists(txn)) {
        record = await store.record(id).get(txn);
      }
    });

    if(record != null) {
      return itemCreator(record);
    }

    return null;
  }

  @override
  Future<List<T>> getMany<T extends DTO>(List<int> idList, {@required T Function(Map<String, dynamic>) itemCreator}) async {
    List<T> items = [];
    for(var id in idList.where((i) => i != null && i >= 0)) {
      items.add(await getOne(id, itemCreator: itemCreator));
    }

    return items.where((item) => item != null).toList();
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
      case FilterType.Contains:
        if(value is int) {
          return Filter.custom((RecordSnapshot<dynamic, dynamic> record) {
            var valueRec = record.value[field];
            if(valueRec is int) {
              return valueRec == value; 
            } else if(valueRec is List) {
              return valueRec.contains(value);
            } else {
              return false;
            }
          });
        } else {
          return Filter.matches(field, value, anyInList: true);
        }
        break;
      default:
        // default case is equals.
        return Filter.equals(field, value);
        break;
    }
  }
}