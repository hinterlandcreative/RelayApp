import 'dart:io';

import 'package:flutter/material.dart';

import 'package:relay/models/toggleable.dart';
import 'package:relay/models/contact_item.dart';

class ToggleableContactItemModel extends Toggleable<ContactItemModel> implements ChangeNotifier, ContactItemModel {
  final ContactItemModel _baseModel;
  ToggleableContactItemModel(this._baseModel) : super(_baseModel);

  String get fullName => _baseModel.fullName;

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

  @override
  DateTime get birthday => _baseModel.birthday;

  @override 
  set birthday(DateTime value) => _baseModel.birthday = value;

  @override
  String get company => _baseModel.company;
  
  @override
  set company(String value) => _baseModel.company = value;

  @override
  String get firstName => _baseModel.firstName;
  
  @override
  set firstName(String value) => _baseModel.firstName = value;

  @override
  File get imageFile => _baseModel.imageFile;
  
  @override
  set imageFile(File value) => _baseModel.imageFile = value;

  @override
  String get imagePath => _baseModel.imagePath;
  
  @override
  set imagePath(String value) => _baseModel.imagePath = value;

  @override
  String get lastName => _baseModel.lastName;
  
  @override
  set lastName(String value) => _baseModel.lastName = value;

  @override
  String get phone => _baseModel.phone;
  
  @override
  set phone(String value) => _baseModel.phone = value;

  @override
  int get id => _baseModel.id;

  @override
  String get initials => _baseModel.initials;

}