import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

// A Navigator observer that notifies RouteAwares of changes to state of their Route
final routeObserver = RouteObserver<PageRoute>();

mixin RouteAwareAnalytics<T extends StatefulWidget> on State<T> implements RouteAware {
      
  String get screenName;
  String get screenClass;

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {}

  @override
  void didPopNext() {
    // Called when the top route has been popped off,
    // and the current route shows up.
    _setCurrentScreen(screenName, screenClass);
  }

  @override
  void didPush() {
    // Called when the current route has been pushed.
    _setCurrentScreen(screenName, screenClass);
  }

  @override
  void didPushNext() {}

  Future<void> _setCurrentScreen(String screenName, String screenClass) {
    print('Setting current screen to $screenName');
    return FirebaseAnalytics().setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
  }
}