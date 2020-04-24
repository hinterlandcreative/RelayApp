import 'dart:ui' as Ui;

import 'package:commons/commons.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:relay/mixins/route_aware_analytics_mixin.dart';
import 'package:relay/services/purchases_service.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/ui/models/app_settings_model.dart';
import 'package:relay/ui/screens/splash_screen.dart';
import 'package:relay/ioc/dependency_registrar.dart';


void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
  
  DependencyRegistrar.registerDependencies();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if(Translations.missingKeys.isNotEmpty) {
      print(Translations.missingKeys.map((t) => "\n\t\t\t\t\"${t.text}\" : \"${t.text}\",").join("\n"));
    }



    return OKToast(
      position: ToastPosition.bottom,
      textAlign: TextAlign.center,
      textStyle: AppStyles.heading2Bold.copyWith(color: Colors.white),
      backgroundColor: AppStyles.brightGreenBlue,
      radius: 20.0,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsModel()),
          Provider<PurchasesService>.value(value: dependencyLocator<PurchasesService>())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [            
                   GlobalMaterialLocalizations.delegate,
                   GlobalWidgetsLocalizations.delegate,
                   GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [
                   const Ui.Locale('en', "US"), 
                ],
          navigatorObservers: [routeObserver],
          home: I18n(
            initialLocale: Ui.Locale('en', 'US'),
            child: SplashScreen()),
        ),
      ),
    );
  }
}