import 'package:commons/commons.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import '../../translation/translations.dart';
import 'contact_model.dart';

class ContactsCollectionModel extends ChangeNotifier {
  bool _isLoading = false;

  List<ContactModel> _contactsList = [];

  ContactsCollectionModel() {
    load();
  }

  bool get isLoading => _isLoading;
  List<ContactModel> get contactsList => _contactsList;
  List<ContactModel> get selectedContactsList => _contactsList.where((c) => c.selected).toList();

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
      notifyListeners();
      return;
    }

    if(contact.phoneNumbers.length == 1) {
      _contactsList[index].selectedPhoneNumber = contact.phoneNumbers.first.value;
      notifyListeners();
    } else {
      singleSelectDialog(
        context, 
        "Choose Number".i18n, 
        contact.phoneNumbers
        .map((p) => SimpleItem(index, p.value)).toSet(), 
        (item) {
          _contactsList[index].selectedPhoneNumber = item.title;
          notifyListeners();
        });
    }
  }
}