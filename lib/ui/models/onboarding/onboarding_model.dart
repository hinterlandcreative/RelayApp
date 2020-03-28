import 'package:flutter/material.dart';

import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/analytics_service.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/ui/models/onboarding/onboarding_item_model.dart';
import 'package:relay/ui/app_styles.dart';

class OnboardingModel extends ChangeNotifier {
  static const int currentOnboardingVersion = 1;

  final String lastOnboardingVersionSettingString = "last_onboarding_version";
  final String onboardingCompleteEvent = "onboarding_complete";

  final List<OnboardingItemModel> items = [
    OnboardingItemModel(
      title: "Mass texting made simple!", 
      text: "Relay is designed to make texting large groups without massive REPLY ALL threads simple and easy.",
      imageAssetPath: "assets/images/onboarding0.png"),
    OnboardingItemModel(
      title: "Do you have group messaging turned on?", 
      text: "That's ok! Just remember to use the 'send " + 
            "individually' button when composing messages.",
      imageAssetPath: "assets/images/onboarding2.png",
      child: Container(
        height: 45.00,
        width: 58.00,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppStyles.primaryGradientStart, AppStyles.primaryGradientEnd],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
          boxShadow: [
            BoxShadow(
              offset: Offset(0.00,3.00),
              color: Color(0xff000000).withOpacity(0.16),
              blurRadius: 6),
          ], 
          borderRadius: BorderRadius.circular(25.00)),
        child: Center(
          child: IconButton(
            onPressed: () { },
            icon: Icon(
              Icons.person_outline,
              color: Colors.white)))))
  ];

  final AppSettingsService _appSettings;

  final AnalyticsService _analyticsService;

  OnboardingModel._(this._appSettings, this._analyticsService);

  factory OnboardingModel([AppSettingsService settingsService, AnalyticsService analyticsService]) {
    return OnboardingModel._(
      settingsService ?? dependencyLocator<AppSettingsService>(),
      analyticsService ?? dependencyLocator<AnalyticsService>());
  }

  Future skip(int onboardingPage) async {
    _appSettings.setSettingInt(lastOnboardingVersionSettingString, currentOnboardingVersion);
    
    await _analyticsService.trackEvent(
      onboardingCompleteEvent,
      properties: {
        'result': 'skipped',
        'lastPageSeen': onboardingPage,
        'version': currentOnboardingVersion
      });
  }

  Future complete() async {
    _appSettings.setSettingInt(lastOnboardingVersionSettingString, currentOnboardingVersion);

    await _analyticsService.trackEvent(
      onboardingCompleteEvent,
      properties: {
        'result': 'completed',
        'version': currentOnboardingVersion
      });
  }
}