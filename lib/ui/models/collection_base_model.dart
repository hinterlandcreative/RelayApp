import 'dart:collection';

import 'package:flutter/material.dart';

abstract class CollectionBaseModel<TModel> extends ChangeNotifier {

  /// the items to display.
  UnmodifiableListView<TModel> get items;

  /// load the children items.
  Future loadChildren();
}