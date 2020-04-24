import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:commons/commons.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:relay/mixins/route_aware_analytics_mixin.dart';
import 'package:waiting_dialog/waiting_dialog.dart';

import 'package:relay/ui/models/add_new_group_model.dart';
import 'package:relay/ui/models/contact_search_result_model.dart';
import 'package:relay/ui/widgets/contact_list_item.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/translation/translations.dart';

class GroupCreateNewScreen extends StatefulWidget {

  @override
  _GroupCreateNewScreenState createState() => _GroupCreateNewScreenState();
}

class _GroupCreateNewScreenState extends State<GroupCreateNewScreen> with RouteAwareAnalytics {
  final double _topOfContentHeight = 100.0;

  final double _selectedContactsWidgetHeight = 80.0;

  final TextEditingController groupTextEditingController = TextEditingController();

  @override
  String get screenClass => "GroupCreateNewScreen";

  @override
  String get screenName => "/GroupCreateNew";

  @override
  void dispose() { 
    groupTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;

    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider<AddNewGroupModel>(
          create: (_) => AddNewGroupModel(),
          child: Stack(
            children: <Widget>[

              // header
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                height: top + 130.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppStyles.primaryGradientStart, AppStyles.primaryGradientEnd],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight)),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15.0, 
                      right: AppStyles.horizontalMargin),
                    child: Row(children: <Widget>[
                      BackButton(onPressed: () {
                        return Navigator.pop(context);
                      }, color: Colors.white,),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: top),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Consumer<AddNewGroupModel>(
                                builder: (context, model, _) => TextField(
                                  controller: groupTextEditingController,
                                  style: AppStyles.heading1.copyWith(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "New Group".i18n,
                                    hintStyle: AppStyles.heading1.copyWith(color: Colors.white),
                                    border: InputBorder.none)),
                              ),
                              Container(
                                height: 0.50,
                                color: Colors.white)])))])))),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                height: bottom + 100.0,
                child: Container(
                  color: AppStyles.brightGreenBlue,
                  child: Padding(
                    padding: EdgeInsets.only(top:30),
                    child: null))),
              
              // body
              Positioned.fill(
                top: top + 90.0,
                bottom: bottom + 60.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40.00)),
                  child: Consumer<AddNewGroupModel>(
                    builder: (context, model, _) {
                        if(model.isLoading) return _buildLoadingWidget();
                        if(model.filteredAllContactsList.isEmpty) return _buildEmptyState();

                        return Padding(
                            padding: EdgeInsets.only(
                              top: 0.0,
                              left: AppStyles.horizontalMargin, 
                              right: AppStyles.horizontalMargin),
                            child: LayoutBuilder(
                              builder: (context, constraints) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: _topOfContentHeight,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        model.selectedContactsList.isEmpty
                                        ? Expanded(child: Center(child: Text("Please select some contacts.".i18n),))
                                        : ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: 0.0,
                                            maxHeight: _selectedContactsWidgetHeight),
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              spacing: 10.0,
                                              children: model.selectedContactsList.map((contact) => 
                                              ChoiceChip(
                                                onSelected: (selected) => model.selectContact(context: context, contact: contact),
                                                selected: false,
                                                backgroundColor: AppStyles.primaryGradientEnd,
                                                labelStyle: AppStyles.paragraph,
                                                label: TextOneLine(contact.name.length < 15 ? contact.name : contact.name.substring(0, 14) + "...",),
                                                avatar: CircleAvatar(
                                                  backgroundColor: AppStyles.lightGrey,
                                                  child: Icon(Icons.close, color: Colors.black)))).toList())))])),
                                  SizedBox(
                                    height: constraints.maxHeight - _topOfContentHeight,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned.fill(
                                          top: 0.0,
                                          child: SearchBar<ContactSearchResultModel>(
                                            shrinkWrap: true,
                                            searchBarPadding: EdgeInsets.only(right: 100.0),
                                            textStyle: AppStyles.paragraph.copyWith(color: Colors.black),
                                            searchBarStyle: SearchBarStyle(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                                              borderRadius: BorderRadius.circular(10.0)),
                                            onSearch: (query) => model.search(query),
                                            onItemFound: (contact, _) => ContactListItem(contact: contact,),
                                            suggestions: model.filteredAllContactsList,
                                            buildSuggestion: (contact, _) => ContactListItem(contact: contact,),),
                                        ),
                                      Positioned(
                                        right: 0.0,
                                        width: 100.0,
                                        height: 75.0,
                                        child: GestureDetector(
                                          onTap: () => model.filterToOnlyMobileNumbers = !model.filterToOnlyMobileNumbers,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Checkbox(
                                                value: model.filterToOnlyMobileNumbers, 
                                                onChanged: (newValue) => model.filterToOnlyMobileNumbers = newValue),
                                              Text("Mobile #".i18n, style: AppStyles.smallText, overflow: TextOverflow.ellipsis,)]),
                                        ))]))])));
                    }
                  ))),

              // this is to fix a very annoying bug with flappy_search_bar
              // Reported here: https://github.com/smartnsoft/flappy_search_bar/issues/21
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                height: 100.0 + MediaQuery.of(context).padding.bottom,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      top:40.0,
                      child: LayoutBuilder(
                      builder: (context, constraints) => Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        color: AppStyles.brightGreenBlue,
                        child: Consumer<AddNewGroupModel>(
                          builder: (_, model, __) => FlatButton(
                            onPressed: () {
                              if(groupTextEditingController.value.text == null || groupTextEditingController.value.text.isEmpty) {
                                infoDialog(
                                  context, 
                                  "Please give your group a name.".i18n,
                                  neutralText: "Okay".i18n);
                                return;
                              }
                              
                              model.groupName = groupTextEditingController.value.text;
                              showWaitingDialog(
                                context: context, 
                                onWaiting: () => model.save(),
                                onDone: () => Navigator.pop(context));
                            },
                            child: Text("save".i18n, style: AppStyles.heading1)),
                        ))))
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState([String emptyLabel = "Add some contacts first."]) {
    return Center(child: Text(emptyLabel.i18n, style: AppStyles.heading2));
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 75,
            width: 75,
            child: FlareActor(
              "assets/animations/loading.flr", 
              animation: "active",),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: FadeAnimatedTextKit(
              textAlign: TextAlign.left,
              text: [
                "loading your contacts.  ".i18n,
                "loading your contacts.. ".i18n,
                "loading your contacts...".i18n],
              pause: Duration(milliseconds: 150),
              textStyle: AppStyles.heading2),
          )
        ],
      ));
  }
}
