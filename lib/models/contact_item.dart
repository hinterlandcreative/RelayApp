import 'dart:io';

import 'package:flutter/material.dart';

import 'package:relay/data/db/dto/contact_dto.dart';

class ContactItemModel extends ChangeNotifier {
  int _id;
  String _firstName;
  String _lastName;
  String _phone;
  String _imagePath;
  String _company;
  DateTime _birthday;
  File _imageFile;

  ContactItemModel._(this._id, this._firstName, this._lastName, this._phone, this._company, this._birthday, this._imagePath);

  factory ContactItemModel({int id, String firstName, String lastName, String phone, String company, DateTime birthday, String imagePath}) {
    assert(id != null);
    assert(id >= 0);
    assert(firstName.isNotEmpty);
    assert(phone.isNotEmpty);

    return ContactItemModel._(id, firstName, lastName, phone, company, birthday, imagePath);
  }

  factory ContactItemModel.fromDto(ContactDto dto) {
    return ContactItemModel._(dto.id, dto.firstName, dto.lastName, dto.phone, dto.company, dto.birthday, dto.imagePath);
  }

  /// [id] of the group.
  int get id => _id;

  /// The [firstName] of the contact.
  String get firstName => _firstName ?? "";

  String get fullName => (firstName ?? "") + (lastName.isNotEmpty ? " $lastName" : "");

  /// The `File` containing the image referenced at [imagePath].
  set imageFile(File value) {
    if(_imageFile != value) {
      _imageFile = value;
      notifyListeners();
    }
  }

  /// The `File` containing the image referenced at [imagePath].
  File get imageFile => _imageFile;

  /// The [firstName] of the contact.
  set firstName(String value) {
    if(_firstName != value) {
      _firstName = value;
      notifyListeners();
    }
  }
  
  /// The [lastName] of the contact.
  String get lastName => _lastName ?? "";

  /// The [lastName] of the contact.
  set lastName(String value) {
    if(_lastName != value) {
      _lastName = value;
      notifyListeners();
    }
  }

  String get initials => fullName?.isEmpty == true 
    ? company?.isNotEmpty == true ? company.substring(0,1) : ""
    : "${firstName?.isNotEmpty == true ? firstName.substring(0,1) : ""}" +
      "${lastName?.isNotEmpty == true ? lastName.substring(0,1) : ""}";

  /// The [phone] of the contact.
  String get phone => _phone;

  /// The [phone] of the contact.
  set phone(String value) {
    if(_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }

  /// The [company] of the contact.
  String get company => _company;

  /// The [company] of the contact.
  set company(String value) {
    if(_company != value) {
      _company = value;
      notifyListeners();
    }
  }

  /// The [imagePath] of the contact's avatar.
  String get imagePath => _imagePath;

  /// The [imagePath] of the contact's avatar.
  set imagePath(String value) {
    if(_imagePath != value) {
      _imagePath = value;
      notifyListeners();
    }
  }

  /// The [birthday] of the contact.
  DateTime get birthday => _birthday;

  /// The [birthday] of the contact.
  set birthday(DateTime value) {
    if(_birthday != value) {
      _birthday = value;
      notifyListeners();
    }
  }
}