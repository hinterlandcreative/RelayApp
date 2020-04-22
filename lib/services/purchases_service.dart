import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:relay/core/app_settings_keys.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/secrets/api_constants.dart';
import 'package:relay/services/analytics_service.dart';
import 'package:relay/services/app_settings_service.dart';

class PurchasesService {
  final AppSettingsService _appSettings;
  final AnalyticsService _analyticsService;

  final String unlimitedGroupsEntitlement = "unlimited groups";
  final String unlimitedGroupOffering = "default";

  String _userId = "";
  Completer _init = Completer();
  StreamController<void> _unlimitedGroupsPurchases = StreamController.broadcast();

  void dispose() { 
    _unlimitedGroupsPurchases.close();
  }

  PurchasesService._(this._appSettings, this._analyticsService) {
    _init.complete(_initialize());
  }

  factory PurchasesService([AppSettingsService appSettings, AnalyticsService analyticsService]) 
  => PurchasesService._(
    appSettings ?? dependencyLocator<AppSettingsService>(),
    analyticsService ?? dependencyLocator<AnalyticsService>());

  Stream<void> get unlimitedGroupsPurchasesStream => _unlimitedGroupsPurchases.stream;
  
  Future<bool> hasUnlimitedGroupsEntitlement() async {
    await _init.future;
    
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      return purchaserInfo.entitlements.all.isNotEmpty 
        && purchaserInfo.entitlements.all.containsKey(unlimitedGroupsEntitlement)
        && purchaserInfo.entitlements.all[unlimitedGroupsEntitlement].isActive;
    } on PlatformException catch (e) {
      _logError(e);
      return false;
    }
  }

  Future<Offering> getUnlimitedGroupsOfferings() async {
    await _init.future;

    try {
      var offerings = await Purchases.getOfferings();
      return offerings.getOffering(unlimitedGroupOffering);
    } on PlatformException catch (e) {
      _logError(e);
      return null;
    } 
  }

  Future<bool> purchaseUnlimitedGroupsPackage(Package package) async {
    await _init.future;

    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      if(purchaserInfo.entitlements.all[unlimitedGroupsEntitlement].isActive) {
        _unlimitedGroupsPurchases.sink.add(null);
        return true;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _logError(e);          
      }
    }

    return false;
  }

  void _logError(PlatformException e) {
    _analyticsService.logException(e);
  }

  Future _initialize() async {
      _userId = await _appSettings.getSettingString(AppSettingsConstants.profile_user_id, Uuid().v1());

      Purchases.setDebugLogsEnabled(true);
      await Purchases.setup(ApiConstants.revenueCatPublicKey, appUserId: _userId);
      print("purchases init completed");
  }

  Future<bool> restorePurchases() async {
    await _init.future;

    try {
      await Purchases.restoreTransactions();
      if(await hasUnlimitedGroupsEntitlement()) {
        _unlimitedGroupsPurchases.sink.add(null);
      }
      return true;
    } on PlatformException catch (e) {
      _logError(e);
      return false;
    }
  }
}