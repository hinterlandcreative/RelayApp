import 'dart:io';

import 'package:flutter/material.dart';

import 'package:relay/core/app_settings_keys.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/models/group_sort.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/services/image_service.dart';

class AppSettingsModel extends ChangeNotifier {
  final AppSettingsService _appSettings;
  final ImageService _imageService;

  String _name = "";
  String _imagePath = "";
  GroupSort _defaultGroupSort = GroupSort.lastSentFirst;
  String _signature = "";
  bool _autoIncludeSignature = false;


  AppSettingsModel._(this._appSettings, this._imageService) {
    _loadData();
  }

  factory AppSettingsModel([AppSettingsService appSettings, ImageService imageService]) 
    => AppSettingsModel._(
      appSettings ?? dependencyLocator<AppSettingsService>(),
      imageService ?? dependencyLocator<ImageService>());

  String get name => _name;
  set name(String value) {
    if(_name != value) {
      _name = value;
      _appSettings.setSettingString(AppSettingsConstants.profile_name_settings_key, value);
      notifyListeners();
    }
  }

  String get imagePath => _imagePath;

  Future updateImagePath(File image) async {
    var path = await _imageService.importFile(image);
    _imagePath = await _imageService.getImagePath(path);
    _appSettings.setSettingString(AppSettingsConstants.profile_image_path_settings_key, path);
    notifyListeners();
  }

  GroupSort get defaultGroupSort => _defaultGroupSort;
  set defaultGroupSort(GroupSort value) {
    if(_defaultGroupSort != value) {
      _defaultGroupSort = value;
      _appSettings.setSettingInt(AppSettingsConstants.group_sorting_settings_key, value.toInt());
      notifyListeners();
    }
  }

  String get signature => _signature;
  set signature(String value) {
    if(_signature != value) {
      _signature = value;
      _appSettings.setSettingString(AppSettingsConstants.signature_settings_key, value);
      notifyListeners();
    }
  }

  bool get autoIncludeSignature => _autoIncludeSignature;
  set autoIncludeSignature(bool value) {
    if(_autoIncludeSignature != value) {
      _autoIncludeSignature = value;
      _appSettings.setSettingsBool(AppSettingsConstants.auto_include_signature_settings_key, value);
      notifyListeners();
    }
  }

  void _loadData() async {
    _name = await _appSettings.getSettingString(AppSettingsConstants.profile_name_settings_key);
    var path = await _appSettings.getSettingString(AppSettingsConstants.profile_image_path_settings_key);
    _imagePath = await _imageService.getImagePath(path);
    _defaultGroupSort = GroupSort.parseInt(
      await _appSettings.getSettingInt(
        AppSettingsConstants.group_sorting_settings_key, GroupSort.alphabetical.toInt()
      )
    );

    _signature = await _appSettings.getSettingString(AppSettingsConstants.signature_settings_key);
    _autoIncludeSignature = await _appSettings.getSettingBool(AppSettingsConstants.auto_include_signature_settings_key);
    print("settings loaded");
    notifyListeners();
  }
}