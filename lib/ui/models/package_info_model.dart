import 'dart:async';

import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class PackageInfoModel extends ChangeNotifier {
  String _appName = "";

  String _packageName = "";

  String _version = "";

  String _buildNumber = "";

  String _appID = "";

  Future init() async {
    var packageInfo = await PackageInfo.fromPlatform();

    _appName = packageInfo.appName;
    _packageName = packageInfo.packageName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    var appId = await AppReview.getAppID;

    _appID = appId;

    notifyListeners();
  }

  String get appName => _appName;

  String get packageName => _packageName;

  String get version => _version + "+" + _buildNumber;

  String get appID => _appID;
}