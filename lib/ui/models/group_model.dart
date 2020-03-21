import 'package:flutter/material.dart';

class GroupModel extends ChangeNotifier {
  /// the title of the group.
  final String title;
  /// the path to the contact images.
  final List<String> imagePath;
  /// the total contacts count for this group.
  final int totalContactCount;

  bool _selected = false;

  GroupModel({this.title, this.imagePath, this.totalContactCount});

  bool get selected => _selected;

  void toggleSelected() {
    _selected = !_selected;
    notifyListeners();
  }
}