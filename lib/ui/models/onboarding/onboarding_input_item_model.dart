import 'package:flutter/material.dart';

import 'package:relay/ui/models/onboarding/onboarding_item_model.dart';

class OnboardingInputItemModel extends OnboardingItemModel {
  final TextEditingController controller;
  final String submitString;
  final Function(String) onSave;

  OnboardingInputItemModel({
    @required String title, 
    @required String text, 
    String imageAssetPath, 
    @required this.controller, 
    @required this.submitString, 
    @required this.onSave}) 
    : super(title: title, text: text, imageAssetPath: imageAssetPath);

  bool canSave() {
    return controller.text.isNotEmpty;
  }

  void save() {
    onSave(controller.text);
  }
}