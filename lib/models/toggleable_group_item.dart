
import 'package:flutter/foundation.dart';

import 'package:relay/data/db/dto/preferred_send_type.dart';
import 'package:relay/models/toggleable.dart';
import 'package:relay/models/contact_item.dart';
import 'package:relay/models/group_item.dart';

class ToggleableGroupItemModel extends Toggleable<GroupItemModel> implements ChangeNotifier, GroupItemModel {
  final GroupItemModel _baseModel;
  ToggleableGroupItemModel(this._baseModel) : super(_baseModel);

  /// [id] of the group.
  @override
  int get id => _baseModel.id;

  /// The [preferredSendType] is a default way to communicate with this group.
  @override
  PreferredSendType get preferredSendType => _baseModel.preferredSendType;

  /// The [preferredSendType] is a default way to communicate with this group.
  @override
  set preferredSendType(PreferredSendType value) {
    _baseModel.preferredSendType = value;
  }

  /// [name] of the group.
  @override
  String get name => _baseModel.name;

  /// [name] of the group.
  @override
  set name(String value) {
    _baseModel.name = value;
  }

  /// The [contacts] list for the group.
  @override
  List<ContactItemModel> get contacts => _baseModel.contacts;

  /// the last `DateTime` that a message was sent to this group.
  @override
  DateTime get lastMessageSentDate => _baseModel.lastMessageSentDate;

  /// the last `DateTime` that a message was sent to this group.
  @override 
  set lastMessageSentDate(DateTime value) => _baseModel.lastMessageSentDate = value;

  /// The `DateTime` of the groups creation.
  @override
  DateTime get creationDate => _baseModel.creationDate;

  /// Add a new [contact] to the [contacts] list.
  @override
  void addContact(ContactItemModel contact) => _baseModel.addContact(contact);

  /// Remove a [contact] from the [contacts] list.
  @override
  void removeContact(ContactItemModel contact) => _baseModel.removeContact(contact);

  @override
  void addListener(listener) => _baseModel.addListener(listener);

  @override
  void dispose() => _baseModel.dispose();

  @override
  bool get hasListeners => _baseModel.hasListeners;

  @override
  void notifyListeners() => _baseModel.notifyListeners();

  @override
  void removeListener(listener) => _baseModel.removeListener(listener);
}