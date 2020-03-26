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
        body: ChangeNotifierProvider<ContactsCollectionModel>(
          create: (_) => ContactsCollectionModel(),
          child: Stack(
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
                        if(model.allContactsList.isEmpty) return _buildEmptyState();

                        return Padding(
                            padding: EdgeInsets.only(
                              top: 20.0,
                              left: AppStyles.horizontalMargin, 
                              right: AppStyles.horizontalMargin),
                            child: LayoutBuilder(
                              builder: (context, constraints) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: 192.0,
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
                                            maxHeight: 140.0),
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
                                                  child: Icon(Icons.close, color: Colors.black)))).toList())),
                                        ),
                                        Row(children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              height: 34.0,
                                              child: TextField(
                                                onChanged: (query) => model.searchQuery = query,
                                                style: AppStyles.paragraph.copyWith(color: Colors.black),
                                                decoration: InputDecoration(
                                                  hintText: "Search...".i18n,
                                                  hintStyle: AppStyles.paragraph.copyWith(color: Colors.black),
                                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                  ))),
                                            )),
                                          Checkbox(
                                            value: model.filterToOnlyMobileNumbers,
                                            onChanged: (checked) => model.filterToOnlyMobileNumbers = checked,),
                                          Text("Mobile # only".i18n, style: AppStyles.smallText)
                                        ],)
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight - 192.0,
                                    child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: model.allContactsList.length,
                                            itemBuilder: (context, index) {
                                              var contact = model.allContactsList[index];
                                              return ContactListItem(contact: contact);
                                            })
                                  )]),
                            ));
                    }
                  ),))
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

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<ContactsCollectionModel>(context);
    var lastContact = model.allContactsList.last;
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
