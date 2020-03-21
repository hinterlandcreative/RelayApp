import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';

import '../../translation/translations.dart';

class ContactModel {
  final Contact _contact;
  String _selectedPhoneNumber = "";

  String _searchString;

  ContactModel(this._contact) {
    _searchString = _contact.displayName.toLowerCase()
      + _contact.company.toLowerCase() + " "
      + _contact.phones.map((x) => x.value.replaceAll(RegExp(r'[^\d]',), "")).join() + " "
      + _contact.postalAddresses.map((a) => a.toString().replaceAll(RegExp(r'[^\d\w]'), " ")).join() + " "
      + _contact.emails.map((e) => e.value).join();
  }

  String get name => _contact.displayName;
  String get initials => 
    "${_contact.givenName.isNotEmpty ? _contact.givenName.substring(0,1) : ""}" +
    "${_contact.familyName.isNotEmpty ? _contact.familyName.substring(0,1) : ""}";

  Uint8List get image => _contact.avatar ?? Uint8List.fromList([]);

  List<Item> get phoneNumbers => _contact.phones.toList();

  bool get hasMobileNumbers => _contact.phones.any((p) => p.label == "mobile");

  String get phoneNumberSubtitle => _getPhoneSubtitles();

  String get searchString => _searchString;

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