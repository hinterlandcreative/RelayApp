import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:relay/data/db/query_package.dart';
import 'package:relay/models/contact_item.dart';
import 'package:relay/data/db/db_collection.dart';
import 'package:relay/data/db/dto/contact_dto.dart';
import 'package:relay/data/db/dto/group_dto.dart';
import 'package:relay/data/db/dto/preferred_send_type.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/services/database_service.dart';
import 'package:relay/services/image_service.dart';
import 'package:relay/translation/translations.dart';

class GroupService {
  final DatabaseService _dbService;
  final ImageService _imageService;

  static const String _contactsDbName = "contacts";
  static const String _groupsDbName = "groups";

  StreamController<void> _groupOrContactsUpdated = StreamController.broadcast();
  Completer<DbCollection> _groupsDb = Completer();
  Completer<DbCollection> _contactsDb = Completer();

  GroupService._(this._dbService, this._imageService) {
    _dbService.getMainStorage().then((db) {
      _groupsDb.complete(db.collections(_groupsDbName));
      _contactsDb.complete(db.collections(_contactsDbName));
    });
  }

  factory GroupService([DatabaseService databaseService, ImageService imageService]) {
    return GroupService._(
      databaseService ?? dependencyLocator<DatabaseService>(),
      imageService ?? dependencyLocator<ImageService>()
    );
  }

  Stream get updatesReceived => _groupOrContactsUpdated.stream;
  
  void dispose() { 
    _groupOrContactsUpdated.close();
  }

  /// Gets all the groups from the database.
  Future<List<GroupItemModel>> getAllGroups() async {
    var groupsDb = await _groupsDb.future;
    var contactsDb = await _contactsDb.future;

    var groups = await groupsDb.getAll((map) => GroupDto.fromMap(map));
    List<GroupItemModel> groupModels = [];
    for(var group in groups) {
      List<ContactDto> contacts = await contactsDb.getMany(group.contacts, itemCreator: (map) => ContactDto.fromMap(map)); 
      groupModels.add(GroupItemModel.fromDTO(group, contacts));
      for(var group in groupModels) {
        for(var contact in group.contacts) {
          if(contact.imagePath != null && contact.imagePath.isNotEmpty) {
            contact.imageFile = await _imageService.getImageFile(contact.imagePath);
          }
        }
      }
    }

    return groupModels;
  }

  /// Add a new group with the specified [name] and [preferredSendType]. After creating the group
  /// you can add contacts to it using the [addContact] method.
  Future<GroupItemModel> addGroup({@required String name, PreferredSendType preferredSendType = PreferredSendType.Unset}) async {
    assert(name != null);
    assert(name.isNotEmpty);

    var groupDb = await _groupsDb.future;

    var dto = GroupDto(
      name: name,
      preferredSendType: preferredSendType,
      creationDate: DateTime.now());

    dto = await _addGroup(groupDb, dto);

    if (dto.id == null || dto.id < 0) {
      return null;
    } else {
      _groupOrContactsUpdated.sink.add(null);
      return GroupItemModel(
        id: dto.id,
        name: dto.name,
        preferredSendType: dto.preferredSendType,
        creationDate: dto.creationDate);
    }
  }

  Future<GroupItemModel> addContact(GroupItemModel group, {String firstName, String lastName, String phone, String company, DateTime birthday, String imagePath}) async {
    assert(group != null);
    assert(group.id >= 0);

    var contactDb = await _contactsDb.future;

    var contact = await _addContact(firstName, lastName, phone, company, birthday, imagePath, contactDb);

    group.addContact(ContactItemModel.fromDto(contact));

    _groupOrContactsUpdated.sink.add(null);
    return await updateGroup(group);
  }

  Future<ContactItemModel> updateContact(ContactItemModel contact) async {
    assert(contact != null);
    assert(contact.id != null);
    assert(contact.id >= 0);

    var dto = ContactDto(
      id: contact.id,
      firstName: contact.firstName,
      lastName: contact.lastName,
      phone: contact.phone,
      company: contact.company,
      birthday: contact.birthday,
      imagePath: contact.imagePath
    );

    var db = await _contactsDb.future;

    await db.update(dto);

    _groupOrContactsUpdated.sink.add(null);
    return ContactItemModel.fromDto(dto);
  }

  Future<GroupItemModel> updateGroup(GroupItemModel group) async {
    assert(group != null);
    assert(group.id != null);
    assert(group.id >= 0);

    var groupDb = await _groupsDb.future;
    var contactDb = await _groupsDb.future;
    
    for(var c in group.contacts.where((c) => c.id != null && c.id >= 0)) {
      c = await updateContact(c);
    }

    if(group.contacts.any((c) => c.id == null || c.id <= 0)) {
      for(var c in group.contacts.where((c) => c.id == null || c.id < 0)) {
        var dto = await _addContact(c.firstName, c.lastName, c.phone, c.company, c.birthday, c.imagePath, contactDb);
        c = ContactItemModel.fromDto(dto);
      }
    }

    var groupDto = GroupDto(
      id: group.id,
      name: group.name,
      preferredSendType: group.preferredSendType,
      contacts: group.contacts.map((c) => c.id).toList(),
      creationDate: group.creationDate,
      lastMessageSentDate: group.lastMessageSentDate
    );

    await groupDb.update(groupDto);

    _groupOrContactsUpdated.sink.add(null);
    return group;
  }

  Future deleteGroup(GroupItemModel group) async {
    assert(group != null);
    assert(group.id > 0);

    var groupDb = await _groupsDb.future;
    var contactDb = await _contactsDb.future;

    for(var c in group.contacts) {
      var otherGroupsWithSameId = await groupDb.query(
        [QueryPackage(
          key: "contacts",
          value: c.id,
          filter: FilterType.Contains
        )],
        (map) => GroupDto.fromMap(map),
        findFirst: true
      );

      if(otherGroupsWithSameId == null) {
        await contactDb.deleteFromId(c.id);
      }
    }

    await groupDb.deleteFromId(group.id);

    _groupOrContactsUpdated.sink.add(null);
  }

  Future<GroupItemModel> deleteContact(GroupItemModel group, ContactItemModel contact) async {
    assert(group != null);
    assert(group.id > 0);
    assert(contact != null);
    assert(contact.id > 0);
    
    var contactDb = await _contactsDb.future;
    if(group.contacts.any((c) => c.id == contact.id)) {
      await contactDb.deleteFromId(contact.id);
      group.removeContact(contact);
      group = await updateGroup(group);
      if(group != null) {
        _groupOrContactsUpdated.sink.add(null);
        return group;
      }
    }

    return group;
  }

  Future<GroupDto> _addGroup(DbCollection groupDb, GroupDto dto) async {
    var id = await groupDb.add(dto);
    return dto.copyWith(id: id);
  }

  Future<ContactDto> _addContact(String firstName, String lastName, String phone, String company, DateTime birthday, String imagePath, DbCollection contactDb) async {
    var contact = ContactDto(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      company: company,
      birthday: birthday,
      imagePath: imagePath
    );
    
    var id = await contactDb.add(contact);

    contact = ContactDto(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      company: company,
      birthday: birthday,
      imagePath: imagePath
    );
    
    return contact;
  }

  Future<GroupItemModel> duplicateGroup(GroupItemModel oldGroup) async {
    assert(oldGroup != null);
    assert(oldGroup.id != null);
    assert(oldGroup.id > 0);

    var groupDb = await _groupsDb.future;
    var contactDb = await _contactsDb.future;

    var missingContacts = oldGroup.contacts.where((c) => c.id <= 0).toList();
    var missingContactIds = <int>[];

    if(missingContacts.isNotEmpty) {
      for(var c in missingContacts) {
        var dto = await _addContact(c.firstName, c.lastName, c.phone, c.company, c.birthday, c.imagePath, contactDb);
        missingContactIds.add(dto.id);
      }
    }

    var dto = GroupDto(
      name: "%s (copy)".fill([oldGroup.name]),
      contacts: oldGroup.contacts.where((c) => c.id != null && c.id > 0).map((c) => c.id).toList() + missingContactIds,
      preferredSendType: oldGroup.preferredSendType,
      lastMessageSentDate: oldGroup.lastMessageSentDate,
      creationDate: DateTime.now()
    );

    dto = await _addGroup(groupDb, dto);
    var contacts = await contactDb.getMany(dto.contacts, itemCreator: (map) => ContactDto.fromMap(map));
    
    _groupOrContactsUpdated.sink.add(null);

    return GroupItemModel.fromDTO(dto, contacts);
  }
}