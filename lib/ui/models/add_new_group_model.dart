import 'dart:async';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';

import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/contacts_service.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/services/image_service.dart';
import 'package:relay/services/group_service.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/ui/models/contact_search_result_model.dart';

class AddNewGroupModel extends ChangeNotifier {
  GroupService _groupService;
  ImageService _imageService;
  ContactsService _contactsService;
  bool _isLoading = false;
  bool _filterToOnlyMobileNumbers = false;
  String _groupName = "";
  List<ContactSearchResultModel> _contactsList = [];
  List<ContactSearchResultModel> _selectedContactsList = [];


  AddNewGroupModel([GroupService groupService, ImageService imageService, ContactsService contactsService]) {
    _groupService = groupService ?? dependencyLocator<GroupService>();
    _imageService = imageService ?? dependencyLocator<ImageService>();
    _contactsService = contactsService ?? dependencyLocator<ContactsService>();
    load();
  }

  bool get isLoading => _isLoading;

  String get groupName => _groupName;

  set groupName(String value) {
    if(_groupName != value) {
      _groupName = value;
      notifyListeners();
    }
  }

  List<ContactSearchResultModel> get filteredAllContactsList => _filterToOnlyMobileNumbers 
    ? _contactsList.where((c) => c.hasMobileNumbers).toList()
    : _contactsList;

  List<ContactSearchResultModel> get selectedContactsList => _selectedContactsList.reversed.toList();

  bool get filterToOnlyMobileNumbers => _filterToOnlyMobileNumbers;

  set filterToOnlyMobileNumbers(bool value) {
    if(value != _filterToOnlyMobileNumbers) {
      _filterToOnlyMobileNumbers = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future load() async {
    _isLoading = true;
    
    var contacts = await _contactsService.getAllContacts();
    _contactsList = contacts
      .where((c) => c.phones.isNotEmpty)
      .map((c) => ContactSearchResultModel(c))
      .toList();
    _isLoading = false;
    notifyListeners();
  }

  void selectContact({@required BuildContext context, ContactSearchResultModel contact, bool onlyShowMobileNumbers = false}) {
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
      optionsDialog(
        context, 
        "Choose Number".i18n, 
        contact.phoneNumbers
        .map((p) => Option(
          Text(p.value, style: AppStyles.heading2Bold), 
          p.label == "mobile" ? Icon(Icons.phone_iphone) : Icon(Icons.home),
          () {
          _contactsList[index].selectedPhoneNumber = p.value;
          _selectedContactsList.add(contact);
          notifyListeners();
        })).toList(), 
        );
    }
  }

  Future<List<ContactSearchResultModel>> search(String query) {
    if(query == null || query.isEmpty) return Future.value(_contactsList);

    var q = query.toLowerCase();
    return Future.value(
      _contactsList
        .where((c) => c.searchString.contains(q))
        .toList());
  }

  Future save() async {
    if(validate()) {
      var group = await _groupService.addGroup(name: _groupName);
      for(var contact in selectedContactsList) {
        String imagePath;
        if(contact.image != null && contact.image.isNotEmpty) {
          var stopwatch = Stopwatch();
          stopwatch.start();
          imagePath = await _imageService.saveToFile(path: "contact_images", bytes: contact.image, width: 100, height: 100);
          stopwatch.stop();
          print("writing image duration: " + stopwatch.elapsed.toString());
        }

        group = await _groupService.addContact(
          group, 
          firstName: contact.firstName,
          lastName: contact.lastName,
          company: contact.company,
          phone: contact.selectedPhoneNumber,
          birthday: contact.birthday,
          imagePath: imagePath);
      }
    }
  }

  bool validate() {
    return groupName.isNotEmpty;
  }
}