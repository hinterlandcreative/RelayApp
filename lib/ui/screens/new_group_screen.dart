import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:relay/ui/models/contact_model.dart';
import 'package:relay/ui/models/contacts_collection_model.dart';

import '../app_styles.dart';
import '../../translation/translations.dart';

class NewGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;

    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
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
                            TextField(
                              onChanged: (s) => print(s),
                              style: AppStyles.heading1.copyWith(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "New Group".i18n,
                                hintStyle: AppStyles.heading1.copyWith(color: Colors.white),
                                border: InputBorder.none)),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: FlatButton(
                        onPressed: () {},
                        child: Text("save".i18n, style: AppStyles.heading1))))))),
            Positioned.fill(
              top: top + 90.0,
              bottom: bottom + 60.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.00)),
                child: Consumer<ContactsCollectionModel>(
                  builder: (context, model, _) {
                    if(model.isLoading) return _buildLoadingWidget(); 
                    if(model.contactsList.isEmpty) return Center(child: Text("Add some contacts first.".i18n, style: AppStyles.heading2));

                    return Padding(
                      padding: EdgeInsets.only(
                        top: 20.0,
                        left: AppStyles.horizontalMargin, 
                        right: AppStyles.horizontalMargin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: MediaQuery.of(context).size.width,
                              maxHeight: 120.0,
                              maxWidth: MediaQuery.of(context).size.width
                            ),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 10.0,
                                children: model.selectedContactsList.map((contact) => 
                                ChoiceChip(
                                  onSelected: (selected) => model.selectContact(context: context, contact: contact),
                                  selected: false,
                                  backgroundColor: AppStyles.primaryGradientEnd,
                                  labelStyle: AppStyles.paragraph,
                                  label: Text(contact.name),
                                  avatar: CircleAvatar(
                                    backgroundColor: AppStyles.lightGrey,
                                    child: Icon(Icons.close, color: Colors.black),),
                                )
                                ).toList(),),
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: model.contactsList.length,
                              itemBuilder: (context, index) {
                                var contact = model.contactsList[index];
                                return ContactListItem(contact: contact);
                              })]));
                  }
                ),))
          ],
        ),
      ),
    );
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

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<ContactsCollectionModel>(context);
    var lastContact = model.contactsList.last;
    return GestureDetector(
      onTap: () => model.selectContact(context: context, contact: contact),
      child: Container(
        height: 80.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Row(
            children: <Widget>[
            contact.selected
            ? Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles.brightGreenBlue
              ),
              child: Icon(Icons.check, color: Colors.white))
            : contact.image != null && contact.image.isNotEmpty 
            ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: MemoryImage(contact.image),
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
                  Text(contact.name, style: AppStyles.heading2Bold,),
                  Text(contact.phoneNumberSubtitle, style: AppStyles.smallText)
                ],
              ),
            )
          ],),
          if(contact != lastContact) Center(child: Container(width: MediaQuery.of(context).size.width * 0.75, height: 1.00, color: Color(0xffdbdbdb),))
        ],),
      ),
    );
  }
}