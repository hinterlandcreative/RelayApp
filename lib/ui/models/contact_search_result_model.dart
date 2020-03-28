import 'dart:typed_data';
import 'dart:core';

import 'package:contacts_service/contacts_service.dart';

import 'package:relay/translation/translations.dart';

class ContactSearchResultModel {
  final Contact _contact;
  String _selectedPhoneNumber = "";
  String _searchString = "";

  ContactSearchResultModel(this._contact) {
    _searchString = _contact.displayName.toLowerCase()
      + (_contact.company == null ? "" : _contact.company.toLowerCase()) + " "
      + _contact.phones.map((x) => x.value.replaceAll(RegExp(r'[^\d]',), "")).join() + " "
      + _contact.postalAddresses.map((a) => a.toString().replaceAll(RegExp(r'[^\d\w]'), " ")).join() + " "
      + _contact.emails.map((e) => e.value).join();
  }

  String get firstName => _contact.givenName;
  String get lastName => _contact.familyName;
  String get name => _contact.displayName;
  String get initials => (_contact.givenName == null || _contact.givenName.isEmpty) && (_contact.familyName == null || _contact.familyName.isEmpty) 
    ? _contact.displayName.substring(0,1)
    : "${_contact.givenName.isNotEmpty ? _contact.givenName.substring(0,1) : ""}" +
      "${_contact.familyName.isNotEmpty ? _contact.familyName.substring(0,1) : ""}";

  String get company => _contact.company;

  DateTime get birthday => _contact.birthday;

  Uint8List get image => _contact.avatar ?? Uint8List.fromList([]);

  List<Item> get phoneNumbers => _contact.phones.toList();

  bool get hasMobileNumbers => _contact.phones.any((p) => p.label == "mobile");

  String get phoneNumberSubtitle => _getPhoneSubtitles();

  bool get selected => _selectedPhoneNumber.isNotEmpty;

  void unselect() {
    selectedPhoneNumber = "";
  }
  
  String get selectedPhoneNumber => _selectedPhoneNumber;

  set selectedPhoneNumber(String selectedPhoneNumber) {
    if(selectedPhoneNumber != _selectedPhoneNumber) {
      _selectedPhoneNumber = selectedPhoneNumber;      
    }
  }
  String get searchString => _searchString;
  
  String _getPhoneSubtitles() {
    if(_contact == null 
    ||_contact.phones == null 
    ||_contact.phones.isEmpty) return "";

    if(_contact.phones.length <= 2) {
      return _contact.phones.map((i) => i.value).join(", ");
    } else {
      var firstTwo = _contact.phones.take(2).map((i) => i.value).join(", ");
      return firstTwo + " and %d more".i18n.fill([_contact.phones.length - 2]);
    }
  }
}
