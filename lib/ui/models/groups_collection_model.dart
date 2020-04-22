import 'dart:async';
import 'dart:collection';

import 'package:relay/core/app_settings_keys.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/models/group_sort.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/services/image_service.dart';
import 'package:relay/services/purchases_service.dart';
import 'package:relay/models/toggleable_group_item.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/group_service.dart';
import 'package:relay/ui/models/collection_base_model.dart';

class GroupsCollectionModel extends CollectionBaseModel<ToggleableGroupItemModel> {
  final GroupService _groupService;
  final PurchasesService _purchasesService;
  final AppSettingsService _appSettings;

  List<ToggleableGroupItemModel> _items = [];

  StreamSubscription _updatesSubscription;
  StreamSubscription _purchasesSubscription;
  bool _hasUnlimitedGroups = false;
  bool _isLoaded = false;

  GroupsCollectionModel._(this._groupService, this._purchasesService, this._appSettings) {
    _updatesSubscription = _groupService.updatesReceived
      .listen((_) => loadChildren());

    _purchasesSubscription = _purchasesService.unlimitedGroupsPurchasesStream
      .listen((_) async {
        _hasUnlimitedGroups = await _purchasesService.hasUnlimitedGroupsEntitlement();
        notifyListeners();
      });

    loadChildren();
  }

  factory GroupsCollectionModel([
    GroupService groupService, 
    PurchasesService purchasesServices, 
    AppSettingsService appSettingsService,
    ImageService imageService]) 
    => GroupsCollectionModel._(
      groupService ?? dependencyLocator<GroupService>(),
      purchasesServices ?? dependencyLocator<PurchasesService>(),
      appSettingsService ?? dependencyLocator<AppSettingsService>()
    );

  @override
  UnmodifiableListView<ToggleableGroupItemModel> get items => UnmodifiableListView(_hasUnlimitedGroups ? _items : _items.take(1));


  bool get shouldShowPaywall => _shouldShowPaywall();

  @override
  void dispose() { 
    _items.forEach((f) => f.dispose());
    _updatesSubscription.cancel();
    _purchasesSubscription.cancel();
    super.dispose();
  }

  @override
  Future loadChildren() async {
    _isLoaded = false;
    var groups  = await _groupService.getAllGroups();
    _hasUnlimitedGroups = await _purchasesService.hasUnlimitedGroupsEntitlement();
    var groupSort = GroupSort.parseInt(await _appSettings.getSettingInt(AppSettingsConstants.group_sorting_settings_key, GroupSort.alphabetical.toInt()));
    if(groupSort == GroupSort.alphabetical) {
      groups.sort((a, b) => a.name.compareTo(b.name));
    } else {
        var noCreationDate = <GroupItemModel>[];
        var noLastSentDate = <GroupItemModel>[];
        var hasLastSentDate = <GroupItemModel>[];
        for(var group in groups) {
          if(group.lastMessageSentDate != null) {
            hasLastSentDate.add(group);
          } else if(group.creationDate != null) {
            noLastSentDate.add(group);
          } else {
            noCreationDate.add(group);
          }
        }

        if(hasLastSentDate.isNotEmpty) hasLastSentDate.sort((a,b) => a.lastMessageSentDate.compareTo(b.lastMessageSentDate));
        if(noLastSentDate.isNotEmpty) noLastSentDate.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        if(noCreationDate.isNotEmpty) noCreationDate.sort((a,b) => a.name.compareTo(b.name));

        groups = null;
        groups = hasLastSentDate + noLastSentDate + noCreationDate;
    }


    _items = groups
      .map((g) => ToggleableGroupItemModel(g))
      .toList();
    _isLoaded = true;

    notifyListeners();
  }

  Future deleteGroup(ToggleableGroupItemModel group) async {
    await _groupService.deleteGroup(group);
    await loadChildren();
  }

  Future<List<ToggleableGroupItemModel>> search(String query) {
    if(query == null || query.isEmpty) {
      return Future.value(<ToggleableGroupItemModel>[]);
    }
    var q = query.toLowerCase();
    return Future
    .value(
      items
        .where((group) => group.name.toLowerCase().contains(q))
        .toList());
  }

  void toggleSelected(ToggleableGroupItemModel group) {
    if(group.selected) {
      _items.firstWhere((g) => g.id == group.id).selected = false;
    } else {
      _items.forEach((g) => g.selected = false);
      _items.firstWhere((g) => g.id == group.id).selected = true;
    }

    notifyListeners();
  }

  Future duplicateGroup(GroupItemModel oldGroup) async {
    await _groupService.duplicateGroup(oldGroup);
  }



  bool _shouldShowPaywall() {
    if(!_isLoaded) {
      return _hasUnlimitedGroups;
    } else {
      return _items.isNotEmpty && !_hasUnlimitedGroups;
    }
  }
}