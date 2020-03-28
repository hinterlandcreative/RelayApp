import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:relay/ui/screens/compose_message_screen.dart';
import 'package:relay/models/toggleable_contact_model.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/ui/models/show_group_model.dart';
import 'package:relay/ui/app_styles.dart';

class GroupViewScreen extends StatelessWidget {
  final GroupItemModel _groupModel;

  const GroupViewScreen(this._groupModel, {Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;

    return ChangeNotifierProvider<ShowGroupModel>(
      create: (_) => ShowGroupModel(_groupModel),
      child: Consumer<ShowGroupModel>(
      builder: (context, model, _) => FocusWatcher(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 80.0 + MediaQuery.of(context).padding.bottom),
          child: FloatingActionButton(
            onPressed: () async {
              var contacts = await model.allContactsOnDevice;
              singleSelectDialog(
                context, 
                "Add Contact".i18n, 
                contacts, 
                (SimpleItem item) {
                  model.addContact(item.id, item.remarks);
                }
              );
            },
            backgroundColor: AppStyles.brightGreenBlue,
            child: Icon(Icons.add, color: Colors.white,)),
          ),
        resizeToAvoidBottomInset: false,
        body: Stack(
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
                  child: Consumer<ShowGroupModel>(
                    builder: (context, model, _) => Row(children: <Widget>[
                      Flexible(
                        flex: 0,
                          child: BackButton(
                            onPressed: () => Navigator.pop(context),
                            color: Colors.white),),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _changeGroupName(context, model),
                          child: TextOneLine(
                            model.name, 
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading1))),
                      Flexible(
                        flex: 0,
                        child: IconButton(
                          onPressed: () => _changeGroupName(context, model),
                          icon: Icon(Icons.mode_edit, color: Colors.white,)),
                      ),
                      Flexible(
                        flex: 0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white,),
                            onPressed: () {
                              confirmationDialog(
                                context, 
                                "Are you sure you want to delete the group '%s'?".fill([model.name]),
                                confirmationText: "Check this box to confirm delete!".i18n,
                                title: "Confirm delete?".i18n,
                                icon: AlertDialogIcon.WARNING_ICON,
                                negativeText: "No".i18n,
                                positiveText: "Yes".i18n,
                                positiveAction: () async {
                                  await model.delete();
                                  Navigator.pop(context);
                                });
                            })))
                    ])
                  ))),
              
              // footer
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                height: bottom + 100.0,
                child: Container(
                  color: AppStyles.brightGreenBlue,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => ComposeMessageScreen(
                            group: _groupModel,
                            recipients: model.selectedContacts,)));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top:30),
                      child: Center(
                        child: Text("compose".i18n, style: AppStyles.heading1)
                      )),
                  ))),

              // body
              Positioned.fill(
                top: top + 90.0,
                bottom: bottom + 60.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40.00)),
                  child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: AppStyles.horizontalMargin),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            var headerHeight = 22.0;
                            var listViewHeight = constraints.maxHeight - headerHeight;

                            return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: headerHeight,
                                child: Row(
                                  children: <Widget>[
                                  Text("Contacts".i18n, style: AppStyles.heading2Bold),
                                  Text(
                                    " (%d people selected)".plural(model.selectedContactsCount),
                                    style: AppStyles.heading2),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Checkbox(
                                        value: model.allSelected,
                                        onChanged: (s) => s ? model.selectAll() : model.unselectAll())))
                                  ])),
                            if(model.contacts.length > 0) Container(
                              height: listViewHeight,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: model.contacts.length,
                                itemBuilder: (context, index) {
                                  var contact = model.contacts[index];
                                  return _buildContactWidget(context, contact);
                                }))
                              ]);
                          })))),
            ])))));
  }

  void _changeGroupName(BuildContext context, ShowGroupModel model) {
    singleInputDialog(
      context,
      label: "",
      title: "Group Name".i18n,
      maxLines: 1,
      validator: (s) => s != null && s.isNotEmpty ? null : "Name can't be empty!",
      value: model.name,
      positiveText: "Save".i18n,
      positiveAction: (name) => model.name = name,
      negativeText: "Cancel".i18n
    );
  }

  Widget _buildContactWidget(BuildContext context, ToggleableContactItemModel contact) {
    var model = Provider.of<ShowGroupModel>(context);
    var lastContact = model.contacts.last;

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          icon: Icons.delete,
          color: Colors.red,
          caption: "delete".i18n,
          onTap: () => model.deleteContact(contact),
        )
      ],
      child: GestureDetector(
        onTap: () => model.selectContact(contact, !contact.selected),
        child: Container(
          height: 80.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Row(
              children: <Widget>[
              contact.imagePath != null && contact.imagePath.isNotEmpty 
              ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: FileImage(contact.imageFile),
                    fit: BoxFit.fill,)
                ),
                width: 50,
                height: 50,
              )
              : Container(
                width: 50,
                height: 50,
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
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(contact.initials, style: AppStyles.heading1.copyWith(color: Colors.white),),
                  ),),),
              Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.fullName, style: AppStyles.heading2Bold,),
                    Text(contact.phone, style: AppStyles.smallText)
                  ],
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Checkbox(
                  onChanged: (s) => model.selectContact(contact, s),
                  value: contact.selected,)
              ),
            )
            ],),
            if(contact != lastContact) Center(child: Container(width: MediaQuery.of(context).size.width * 0.75, height: 1.00, color: Color(0xffdbdbdb),))
          ],),
        ),
      ),
    );
  }
}
