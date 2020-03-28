import 'dart:async';

import 'package:contacts_service/contacts_service.dart' as cs;
import 'package:flutter/material.dart';

class ContactsService {
  Completer<Iterable<cs.Contact>> _allContacts = Completer();

  ContactsService() {
    _invalidateCachedContacts();

    WidgetsBinding.instance.addObserver(
      _OnNextResumeLifecyleEventObserver(
        () async => _invalidateCachedContacts()
    ));
  }
  
  Future<List<cs.Contact>> getAllContacts() async {
    var list = await _allContacts.future;
    return list.toList();
  }

  Future _invalidateCachedContacts() async {
    if(_allContacts.isCompleted) {
      _allContacts = Completer();
    }

    var contactList = await cs.ContactsService.getContacts();
    _allContacts.complete(contactList);
  }
}

class _OnNextResumeLifecyleEventObserver extends WidgetsBindingObserver {
  final Future Function() onResume;

  _OnNextResumeLifecyleEventObserver(this.onResume);

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.resumed) {
      await onResume();
    }
  }
}