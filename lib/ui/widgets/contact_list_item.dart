import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:relay/ui/models/add_new_group_model.dart';
import 'package:relay/ui/models/contact_search_result_model.dart';
import 'package:relay/ui/app_styles.dart';

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final ContactSearchResultModel contact;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AddNewGroupModel>(context);
    var lastContact = model.filteredAllContactsList.last;
    return GestureDetector(
      onTap: () => model.selectContact(context: context, contact: contact),
      child: Container(
        height: 80.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: MemoryImage(contact.image),
                  fit: BoxFit.fill)))
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextOneLine(contact.name, style: AppStyles.heading2Bold,),
                    Text(contact.phoneNumberSubtitle, style: AppStyles.smallText)
                  ],
                ),
              ),
            )
          ],),
          if(contact != lastContact) Center(child: Container(width: MediaQuery.of(context).size.width * 0.75, height: 1.00, color: Color(0xffdbdbdb),))
        ],),
      ),
    );
  }
}