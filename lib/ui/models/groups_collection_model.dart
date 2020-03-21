import 'dart:collection';

import 'collection_base_model.dart';
import 'group_model.dart';

class GroupsCollectionModel extends CollectionBaseModel<GroupModel> {
  List<GroupModel> _items = [];

  @override
  UnmodifiableListView<GroupModel> get items => UnmodifiableListView(_items);

  GroupsCollectionModel() {
    loadChildren();
  }

  @override
  Future loadChildren() {
    _items = [
      GroupModel(
        title: "Workout Buddies", 
        imagePath: [
          "assets/profile1.png",
          "assets/profile2.png",
          "assets/profile3.png",
          "assets/profile4.jpeg",
          "assets/profile5.png",
          "assets/profile6.png"], 
        totalContactCount: 6),
      GroupModel(
        title: "Service Group", 
        imagePath: [
          "assets/profile1.png",
          "assets/profile2.png",
          "assets/profile3.png",
          "assets/profile4.jpeg",
          "assets/profile5.png",
          "assets/profile6.png"], 
        totalContactCount: 6),
    ];

    notifyListeners();
  }

}