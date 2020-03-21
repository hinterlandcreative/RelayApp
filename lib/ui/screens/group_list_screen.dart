import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/groups_collection_model.dart';
import '../widgets/group_item_card.dart';
import '../app_styles.dart';
import '../widgets/hamburger.dart';
import '../../translation/translations.dart';
import 'new_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewGroupScreen())),
          backgroundColor: AppStyles.brightGreenBlue,
          child: Icon(Icons.add, color: Colors.white,),
        ),
      ),
      body: ChangeNotifierProvider(
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
              top: MediaQuery.of(context).padding.top + 30.0,
              left: 35.0,
              right: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hamburger(
                  onTap: () {}),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 6.0),
                  child: Text("Groups".i18n, style: AppStyles.heading1,),),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                      boxShadow: [
                          BoxShadow(
                              offset: Offset(1.00,1.00),
                              color: Color(0xff000000).withOpacity(0.16),
                              blurRadius: 25,),], 
                    borderRadius: BorderRadius.circular(30.00),), 
                  child: TextField(
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppStyles.paragraph,
                    decoration: InputDecoration(
                      hintText: "Search...".i18n,
                      hintStyle: AppStyles.paragraph,
                      contentPadding: EdgeInsets.only(left: 18.0, top: 0.0),
                      fillColor: Colors.transparent,
                      border: InputBorder.none),),),
              Consumer<GroupsCollectionModel>(
                builder: (_, model, __) {
                  if(model.items == null || model.items.length <= 0) {
                    return Container();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(children: model.items.map((item) => GroupItemCard(group: item,)).toList()),
                  );
                },
              )
            ],),
          ),
        ),
      ),
    );
  }
}