import 'dart:async';

import 'package:app_review/app_review.dart';
import 'package:commons/commons.dart';
import 'package:flutter/widgets.dart';
import 'package:relay/core/app_settings_keys.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/analytics_service.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/translation/translations.dart';

class AppReviewsService {
  final String _reviewsShownEvent = "reviews_shown";
  final AppSettingsService _appSettings;
  final AnalyticsService _analyticsService;

  AppReviewsService._(this._appSettings, this._analyticsService);

  factory AppReviewsService([AppSettingsService appSettingsService, AnalyticsService analyticsService]) {
    return AppReviewsService._(
      appSettingsService ?? dependencyLocator<AppSettingsService>(),
      analyticsService ?? dependencyLocator<AnalyticsService>()
    );
  }

  Future<bool> shouldRequestReviews() async {
    var appOpens = await _appSettings.getSettingInt(AppSettingsConstants.analytics_app_open_count);
    var messagesSent = await _appSettings.getSettingInt(AppSettingsConstants.analytics_message_count);
    var didShowReviews = await _appSettings.getSettingBool(AppSettingsConstants.reviews_have_been_shown);

    if(didShowReviews) {
      return false;
    }

    print("reviews have not been shown.");

    if(appOpens > 5 && messagesSent > 3) {
      print ("reviews should show");
      return true;
    } else {
      return false;
    }
  }

  Future requestReviews(BuildContext context) async {
    if(await AppReview.isRequestReviewAvailable == false) {
      Completer<bool> completer = Completer();
      infoDialog(
        context, 
        "Do you want to rate or review Relay on the app store?".i18n,
        title: "Enjoying Relay?".i18n,
        showNeutralButton: false,
        positiveAction: () => completer.complete(true),
        positiveText: "Review Relay".i18n,
        negativeAction: () => completer.complete(false),
        negativeText: "Not Right Now".i18n
      );

      await completer.future;

      await AppReview.storeListing;
    } else {
      await AppReview.requestReview;
    }

    _appSettings.setSettingsBool(AppSettingsConstants.reviews_have_been_shown, true);
    _analyticsService.trackEvent(_reviewsShownEvent);
  }
}