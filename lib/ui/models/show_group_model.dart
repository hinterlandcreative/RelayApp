import 'dart:async';

import 'package:commons/commons.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/models/toggleable_contact_model.dart';
import 'package:relay/services/group_service.dart';

class ShowGroupModel extends ChangeNotifier {
  GroupItemModel _group;
  List<ToggleableContactItemModel> _contacts;
  Completer<Set<SimpleItem>> _allContactsCompleter = Completer();

  GroupService _groupService;

  List<Contact> _allContacts;

  ShowGroupModel(this._group, [GroupService groupService]) {
    _groupService = groupService ?? dependencyLocator<GroupService>();
    _updateContactList();
    _fetchAllContacts();
  }

  String get name => _group.name;

  bool get allSelected => !_contacts.any((c) => !c.selected);

  int get selectedContactsCount => selectedContacts.length;

  List<ToggleableContactItemModel> get selectedContacts => _contacts.where((c) => c.selected).toList();

  set name(String value) {
    _group.name = value;
    save();
    notifyListeners();
  }

  List<ToggleableContactItemModel> get contacts => _contacts;

  Future<Set<SimpleItem>> get allContactsOnDevice => _allContactsCompleter.future;

  Future save() async {
    await _groupService.updateGroup(_group);
  }

  void selectAll() {
    _contacts.forEach((c) => c.selected = true);
    notifyListeners();
  }

  void unselectAll() {
    _contacts.forEach((c) => c.selected = false);
    notifyListeners();
  }

  void selectContact(ToggleableContactItemModel contact, bool selected) {
    contact.selected = selected;
    notifyListeners();
  }

  Future addContact(int index, String phone) async {
    var contact = _allContacts[index];
    if(contact != null) {
      _group = await _groupService.addContact(
        _group,
        firstName: contact.givenName,
        lastName: contact.familyName,
        phone: phone,
        company: contact.company,
        birthday: contact.birthday);
      _updateContactList();
    }
  }

  Future delete() async {
    await _groupService.deleteGroup(_group);
  }

  Future deleteContact(ToggleableContactItemModel contact) async {
    _group = await _groupService.deleteContact(_group, contact);
    _updateContactList();
  }

  void _updateContactList() {
    _contacts = _group.contacts.map((c) => ToggleableContactItemModel(c)..selected = true).toList();
    notifyListeners();
  }

  Future _fetchAllContacts() async {
    _allContacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
    List<SimpleItem> _searchableItems = [];
    for(var index in List.generate(_allContacts.length, (i) => (i - 1) + 1)) {
      var contact  = _allContacts[index];
      if(contact.phones.length > 0) {
        for(var phone in contact.phones) {
          _searchableItems.add(
            SimpleItem(
              index,
              "${contact.displayName}\n${phone.value} (${phone.label})",
              remarks: phone.value)
          );
        }
      }
    }

    _allContactsCompleter.complete(_searchableItems.toSet());
  }
}