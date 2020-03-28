import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class OnboardingItemModel {
  final String title;
  final String text;
  final String imageAssetPath;
  final Widget child;

  const OnboardingItemModel({@required this.title, @required this.text, this.imageAssetPath, this.child});
}