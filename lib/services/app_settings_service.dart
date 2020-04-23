import 'dart:async';

import 'package:commons/commons.dart';

class AppSettingsService {
  static const String last_report_sent = "last_report_sent";

  Completer<SharedPreferences> _prefs = Completer();

  AppSettingsService([SharedPreferences prefs]) {
    _prefs.complete(prefs ?? SharedPreferences.getInstance());
  }

  Future<String> getSettingString(String key, [String defaultValue = ""]) async {
    var prefs = await _prefs.future;
    return await _getSetting(
      prefs,
      key, 
      defaultValue, 
      prefs.getString,
      prefs.setString);
  }

  void setSettingString(String key, String value) {
    _prefs.future.then((prefs) => prefs.setString(key, value));
  }

  Future<List<String>> getSettingListString(String key, [List<String> defaultValue]) async {
    defaultValue = defaultValue ?? [];
    var prefs = await _prefs.future;
    return await _getSetting(
      prefs,
      key, 
      defaultValue, 
      prefs.getStringList,
      prefs.setStringList);
  }

  void setSettingsStringList(String key, List<String> value) {
    _prefs.future.then((prefs) => prefs.setStringList(key, value));
  }

  Future<int> getSettingInt(String key, [int defaultValue = 0]) async {
    var prefs = await _prefs.future;
    return await _getSetting(
      prefs,
      key, 
      defaultValue, 
      prefs.getInt,
      prefs.setInt);
  }

  void setSettingInt(String key, int value) {
    _prefs.future.then((prefs) => prefs.setInt(key, value));
  }

  Future<bool> getSettingBool(String key, [bool defaultValue = false]) async {
    var prefs = await _prefs.future;
    return await _getSetting(
      prefs,
      key, 
      defaultValue, 
      prefs.getBool,
      prefs.setBool);
  }

  void setSettingsBool(String key, bool value) {
    _prefs.future.then((prefs) => prefs.setBool(key, value));
  }

  Future<T> _getSetting<T>(
    SharedPreferences prefs,
    String key, 
    T defaultValue,
    T Function(String) getValue,
    Future<bool> Function(String, T) setValue) async {
    if(!prefs.containsKey(key)) {
      await setValue(key, defaultValue);
      return defaultValue;
    } else {
      return getValue(key);
    }
  }
}