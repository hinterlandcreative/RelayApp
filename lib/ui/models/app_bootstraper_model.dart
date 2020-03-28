import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:relay/data/db/database_upgrader.dart';
import 'package:relay/services/database_service.dart';
import 'package:relay/ui/models/onboarding/onboarding_model.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/app_settings_service.dart';

class AppBootstrapperModel extends ChangeNotifier {
  final String lastOnboardingVersionSettingString = "last_onboarding_version";
  final Duration _minimumWaitDuration = Duration(milliseconds: 1500);
  final AppSettingsService _appSettings;
  final DatabaseService _databaseService;
  BootstrapStatus _status = BootstrapStatus.Initializing;

  AppBootstrapperModel._(this._appSettings, this._databaseService);

  factory AppBootstrapperModel([AppSettingsService appSettings, DatabaseService dbService]) {
    return AppBootstrapperModel._(
      appSettings ?? dependencyLocator<AppSettingsService>(),
      dbService ?? dependencyLocator<DatabaseService>());
  }

  BootstrapStatus get status => _status;

  Future init() async {
    BootstrapStatus status;
    
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    DatabaseUpgrader.upgradeDatabase(await _databaseService.getMainStorage());
    var lastOnboardingVersion = await _appSettings.getSettingInt(lastOnboardingVersionSettingString, 0);
    if(lastOnboardingVersion < OnboardingModel.currentOnboardingVersion) {
      status = BootstrapStatus.RequiresOnboarding;
    } else {
      status = BootstrapStatus.ReadyToLaunch;
    }
    
    stopwatch.stop();
    if(stopwatch.elapsedMilliseconds < _minimumWaitDuration.inMilliseconds) {
      await Future.delayed(Duration(milliseconds: _minimumWaitDuration.inMilliseconds - stopwatch.elapsedMilliseconds));
    }
    while(await Permission.contacts.isGranted == false) {
      await Permission.contacts.request();
    }
    _status = status;
    notifyListeners();
  }
}

enum BootstrapStatus {
  Initializing,
  ReadyToLaunch,
  RequiresOnboarding
}