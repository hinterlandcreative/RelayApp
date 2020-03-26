import 'dart:async';

import 'package:commons/commons.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../translation/translations.dart';
import 'contact_model.dart';

class ContactsCollectionModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _filterToOnlyMobileNumbers = false;

  List<ContactModel> _contactsList = [];
  List<ContactModel> _selectedContactsList = [];
  BehaviorSubject<String>  _searchQueries = BehaviorSubject.seeded("");

  ContactsCollectionModel() {
    load();
  }

  bool get isLoading => _isLoading;

  List<ContactModel> get allContactsList => _contactsList;

  List<ContactModel> get selectedContactsList => _selectedContactsList;

  Stream<List<ContactModel>> get filteredContactList => _searchQueries.stream
    .debounceTime(Duration(milliseconds: 300))
    .map((query) => _filterContactsByQuery(query.toLowerCase()));
  
  set searchQuery(String query) {
    _searchQueries.sink.add(query);
  }

  bool get filterToOnlyMobileNumbers => _filterToOnlyMobileNumbers;

  set filterToOnlyMobileNumbers(bool filterToOnlyMobileNumbers) {
    if(filterToOnlyMobileNumbers != _filterToOnlyMobileNumbers) {
      _filterToOnlyMobileNumbers = filterToOnlyMobileNumbers;
      notifyListeners();
    }
  }

  @override
  void dispose() { 
    _searchQueries.close();
    super.dispose();
  }

  Future load() async {
    _isLoading = true;
    
    var contacts = await ContactsService.getContacts();
    _contactsList = contacts
      .where((c) => c.phones.isNotEmpty)
      .map((c) => ContactModel(c))
      .toList();
    _isLoading = false;
    notifyListeners();
  }

  void selectContact({@required BuildContext context, ContactModel contact, bool onlyShowMobileNumbers = false}) {
    var index = _contactsList.indexOf(contact);
    if(index < 0) {
      return;
    }

    if(contact.selected) {
      contact.unselect();
      _selectedContactsList.remove(contact);
      notifyListeners();
      return;
    }

    if(contact.phoneNumbers.length == 1) {
      _contactsList[index].selectedPhoneNumber = contact.phoneNumbers.first.value;
      _selectedContactsList.add(contact);
      notifyListeners();
    } else {
      singleSelectDialog(
        context, 
        "Choose Number".i18n, 
        contact.phoneNumbers
        .map((p) => SimpleItem(index, p.value)).toSet(), 
        (item) {
          _contactsList[index].selectedPhoneNumber = item.title;
          _selectedContactsList.add(contact);
          notifyListeners();
        });
    }
  }

  Iterable<ContactModel> _filterContactsByQuery(String query) {
    if(query == null || query.isEmpty) return _contactsList;
    return _contactsList.where((c) => c.searchString.contains(query));
  }
}