import 'package:flutter/foundation.dart';

abstract class Toggleable<T extends ChangeNotifier> implements ChangeNotifier {
  final T _baseModel;
  bool _selected = false;

  bool get selected => _selected;

  set selected(bool value) {
    if(_selected != value) {
      _selected = value;
      _baseModel.notifyListeners();
    }
  }

  Toggleable(this._baseModel);

  void toggle() {
    _selected = !_selected;
    _baseModel.notifyListeners();
  }
}