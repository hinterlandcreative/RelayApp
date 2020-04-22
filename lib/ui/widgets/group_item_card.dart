import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/ui/screens/compose_message_screen.dart';
import 'package:vibration/vibration.dart';

import 'package:relay/ui/models/groups_collection_model.dart';
import 'package:relay/ui/screens/group_view_screen.dart';
import 'package:relay/models/toggleable_group_item.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/models/contact_item.dart';
import 'package:relay/ui/widgets/three_dots.dart';
import 'package:relay/translation/translations.dart';

class GroupItemCard extends StatelessWidget {
  final ToggleableGroupItemModel group;
  const GroupItemCard({
    Key key, @required this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<GroupsCollectionModel>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
        height: group.selected ? 142.0 : 100.0,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70.00,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1.00,1.00),
                      color: Color(0xff000000).withOpacity(0.16),
                      blurRadius: 25,),], 
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0), 
                    bottomRight: Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.only(top:28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupViewScreen(group))),
                        child: Text(
                          "%d Contacts".i18n.fill([group.contacts.length]),
                          style: AppStyles.heading2Bold.copyWith(color: Colors.white))),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: 2.00,
                          color: Color(0xffffffff).withOpacity(0.12),),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeMessageScreen(group: group, recipients: group.contacts))),
                        child: Text(
                          "Compose".i18n,
                          style: AppStyles.heading2Bold.copyWith(color: AppStyles.brightGreenBlue)))
                  ],),
                ),),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: GestureDetector(
                onLongPress: () => _showModalDialog(context, group),
                onDoubleTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupViewScreen(group))),
                onTap: () {
                  model.toggleSelected(group);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(2.00, 2.00),
                        color: Color(0xff000000).withOpacity(0.16),
                        blurRadius: 25.0,),], 
                    borderRadius: BorderRadius.circular(20.00),),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                        Text(group.name, style: AppStyles.heading2Bold),
                        Row(children: group.contacts.length > 5
                        ? group.contacts
                          .take(5)
                          .map((contact) => contact.imagePath == null || contact.imagePath.isEmpty
                            ? _buildInitialsAvatar(contact)
                            : _getSmallContactImage(contact.imageFile)).toList() + [ThreeDots()]
                        : group.contacts.map((contact) => contact.imagePath == null || contact.imagePath.isEmpty
                            ? _buildInitialsAvatar(contact)
                            : _getSmallContactImage(contact.imageFile)).toList())
                        ],)
                      ),
                  ),
              ),
            ),
          ],
        ),
      ),
      );
  }

  Widget _buildInitialsAvatar(ContactItemModel contact) {
    return Padding(
      padding: const EdgeInsets.only(right:10.0),
      child: Container(
        width: 25.0,
        height: 25.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppStyles.primaryGradientStart, 
              AppStyles.primaryGradientEnd],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
          shape: BoxShape.circle),
        child: Center(
          child:Padding(
            padding: const EdgeInsets.all(4.0),
            child: AutoSizeText(
              contact.initials, 
              minFontSize: 1,
              style: AppStyles.heading1.copyWith(color: Colors.white),),
          ),),),
    );
  }

  Widget _getSmallContactImage(File image) {
    return Padding(
      padding: const EdgeInsets.only(right:10.0),
      child: Container(
        height: 25.0,
        width: 25.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(image))
        )));
  }

  void _showModalDialog(BuildContext context, GroupItemModel model) async {
    var groupCollectionModel = Provider.of<GroupsCollectionModel>(context, listen: false);
    try {
      if(await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 100);
      }
    } catch(_) {}

    optionsDialog(
      context, 
      model.name, 
      <Option>[
        if(!groupCollectionModel.shouldShowPaywall) Option(
          Text("Duplicate".i18n, style: AppStyles.heading2Bold),
          Icon(Icons.content_copy),
          () => Provider.of<GroupsCollectionModel>(context, listen: false).duplicateGroup(model)
        ),
        Option(
          Text("Delete".i18n, style: AppStyles.heading2Bold),
          Icon(Icons.delete_outline),
          () => confirmationDialog(
            context, 
            "Are you sure you want to delete the group '%s'?".fill([model.name]),
            confirmationText: "Check this box to confirm delete!".i18n,
            title: "Confirm delete?".i18n,
            icon: AlertDialogIcon.WARNING_ICON,
            negativeText: "No".i18n,
            positiveText: "Yes".i18n,
            positiveAction: () async {
              await Provider.of<GroupsCollectionModel>(context, listen: false).deleteGroup(model);
            })
        )
    ]);
  }
}