import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:relay/data/db/dto/contact_dto.dart';
import 'package:relay/data/db/dto/group_dto.dart';
import 'package:relay/data/db/dto/preferred_send_type.dart';
import 'package:relay/models/contact_item.dart';

class GroupItemModel extends ChangeNotifier {
  int _id;
  String _name;
  PreferredSendType _preferredSendType;
  List<ContactItemModel> _contacts;
  DateTime _lastMessageSentDate;
  DateTime _creationDate;

  GroupItemModel._(this._id, this._name, this._contacts, this._preferredSendType, this._lastMessageSentDate, this._creationDate);

  factory GroupItemModel({
    int id, 
    String name = "", 
    List<ContactItemModel> contacts, 
    PreferredSendType preferredSendType = PreferredSendType.Unset, 
    DateTime lastMessageSent,
    DateTime creationDate}) {
    assert(id != null);
    assert(id >= 0);
    assert(name != null);
    assert(name.isNotEmpty);
    assert(creationDate != null);
    assert(creationDate.isBefore(DateTime.now()));

    return GroupItemModel._(id, name, contacts ?? [], preferredSendType, lastMessageSent, creationDate);
  }

  factory GroupItemModel.fromDTO(GroupDto g, List<ContactDto> contacts) {
    return GroupItemModel(
      id: g.id,
      name: g.name,
      preferredSendType: g.preferredSendType,
      contacts: contacts.map((c) => ContactItemModel.fromDto(c)).toList(),
      lastMessageSent: g.lastMessageSentDate,
      creationDate: g.creationDate);
  }

  /// [id] of the group.
  int get id => _id;

  /// The [preferredSendType] is a default way to communicate with this group.
  PreferredSendType get preferredSendType => _preferredSendType;

  /// The [preferredSendType] is a default way to communicate with this group.
  set preferredSendType(PreferredSendType value) {
    if(_preferredSendType != value) {
      _preferredSendType = value;
    }

    notifyListeners();
  }

  /// [name] of the group.
  String get name => _name;

  /// [name] of the group.
  set name(String value) {
    if(_name != value) {
      _name = value;
    }

    notifyListeners();
  }

  /// The [contacts] list for the group.
  List<ContactItemModel> get contacts => _contacts;

  /// the last `DateTime` that a message was sent to this group.
  DateTime get lastMessageSentDate => _lastMessageSentDate;

  /// the last `DateTime` that a message was sent to this group.
  set lastMessageSentDate(DateTime value) {
    _lastMessageSentDate = value;
    notifyListeners();
  }

  /// The `DateTime` of the groups creation.
  DateTime get creationDate => _creationDate;

  /// Add a new [contact] to the [contacts] list.
  void addContact(ContactItemModel contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  /// Remove a [contact] from the [contacts] list.
  void removeContact(ContactItemModel contact) {
    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }
}