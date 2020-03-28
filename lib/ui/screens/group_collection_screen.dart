import 'dart:async';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:provider/provider.dart';

import 'package:relay/services/purchases_service.dart';
import 'package:relay/ui/screens/paywall_screen.dart';
import 'package:relay/ui/transitions/scale_route.dart';
import 'package:relay/ui/models/groups_collection_model.dart';
import 'package:relay/models/toggleable_group_item.dart';
import 'package:relay/ui/widgets/group_item_card.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/ui/widgets/hamburger.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/ui/screens/group_create_new_screen.dart';

class GroupCollectionScreen extends StatefulWidget {
  const GroupCollectionScreen({Key key}) : super(key: key);

  @override
  _GroupCollectionScreenState createState() => _GroupCollectionScreenState();
}

class _GroupCollectionScreenState extends State<GroupCollectionScreen> {
  bool isMenuOpen = false;
  StreamSubscription<MenuState> _menuOpenedSubscription;
  
  @override
  void didChangeDependencies() {
    if(_menuOpenedSubscription == null) {
      _menuOpenedSubscription = SimpleHiddenDrawerProvider
        .of(context)
        .getMenuStateListener()
        .listen((state) {
          var isOpen = state == MenuState.open;
          if(isMenuOpen != isOpen) {
            setState(() => isMenuOpen = isOpen);
          }
        });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() { 
    _menuOpenedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Consumer<PurchasesService>(
            builder: (context, purchases, _) => FloatingActionButton(
              onPressed: () async {
                if (await purchases.hasUnlimitedGroupsEntitlement()) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GroupCreateNewScreen()));
                } else {
                  Navigator.push(context, ScaleRoute(page:PaywallScreen(onSuccessBuilder: () => GroupCreateNewScreen())));
                }
              },
              backgroundColor: AppStyles.brightGreenBlue,
              child: Icon(Icons.add, color: Colors.white,),
            ),
          ),
        ),
        body: IgnorePointer(
          ignoring: isMenuOpen,
          child: ChangeNotifierProvider(
            create: (_) => GroupsCollectionModel(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppStyles.primaryGradientStart, AppStyles.primaryGradientEnd],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight)),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: AppStyles.horizontalMargin),
                      child: Hamburger(
                        onTap: () => SimpleHiddenDrawerProvider.of(context).toggle()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 6.0, left: AppStyles.horizontalMargin),
                      child: Text("Groups".i18n, style: AppStyles.heading1,),),
                    _buildSearchBar(context),
                ],),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Expanded(
      child: Consumer<GroupsCollectionModel>(
        builder: (context, model, _) {
          if(model.items == null || model.items.length == 0) return _buildEmptyState();

          return SearchBar<ToggleableGroupItemModel>(
            searchBarPadding: EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin),
          onSearch: (query) => model.search(query),
          onItemFound: (group, _) => _buildContactGroup(group),
          hintText: "Search...".i18n,
          hintStyle: AppStyles.paragraph,
          textStyle: AppStyles.paragraph,
          icon: Icon(Icons.search, color: Colors.white38),
          suggestions: model.items,
          cancellationWidget: Text("Cancel".i18n, style: AppStyles.paragraph),
          emptyWidget: _buildNoResultsState(),
          searchBarStyle: SearchBarStyle(
            backgroundColor: Colors.white12,
            padding: EdgeInsets.only(left: 15.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        );
        },
      ),
    );
  }

  Widget _buildContactGroup(ToggleableGroupItemModel item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin),
      child: GroupItemCard(group: item,),
    );
  }

  Widget _buildEmptyState() {
    return _buildFilledText("Let's add your first group.".i18n);
  }

  Center _buildFilledText(String text) {
    return Center(
    child: Text(
      text, 
      style: AppStyles.paragraph.copyWith(color: Colors.white)));
  }

  Widget _buildNoResultsState() {
    return _buildFilledText("No results.".i18n);
  }
}