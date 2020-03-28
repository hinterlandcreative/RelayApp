import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:relay/models/message_recipient.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/translation/translations.dart';

class MessageContainer extends StatelessWidget {
  /// The text of the message.
  final String message;
  
  /// The [recipients] that received this [message];
  final List<MessageRecipient> recipients;

  /// `DateTime` when the message was sent.
  final DateTime sendDateTime;

  /// Callback when the details text is tapped.
  final Function onDetailsPressed;

  /// Padding after the message box and details text have been drawn.
  final EdgeInsets padding;

  const MessageContainer({
    Key key, 
    @required this.message,
    @required this.sendDateTime,
    @required this.onDetailsPressed,
    @required this.recipients,
    this.padding = const EdgeInsets.only(bottom: 40.0), 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 80.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppStyles.primaryGradientStart, AppStyles.primaryGradientEnd],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40.00), topRight: Radius.circular(40.00), bottomLeft: Radius.circular(40.00))),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                message,
                style: AppStyles.paragraph.copyWith(color: Colors.white)))),
        ),
        Padding(padding: EdgeInsets.only(top: 3.0)),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            child: AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("%d Recipients".plural(recipients.length), 
                  style: AppStyles.heading1.copyWith(color: Colors.black)),
                  Text(
                    "Sent on %s".fill([DateFormat.yMMMMd(Intl.defaultLocale).add_jm().format(sendDateTime)]),
                    style: AppStyles.paragraph.copyWith(color: Colors.black))
                ],
              ),
              content: SizedBox(
                width: min(400.0, MediaQuery.of(context).size.width - 80.0),
                height: min(200.0, MediaQuery.of(context).size.height / 2),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipients.length,
                  itemBuilder: (context, index) {
                    var recipient = recipients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(children: <Widget>[
                        Text(recipient.name, style: AppStyles.heading2Bold),
                        Text(recipient.number, style: AppStyles.paragraph.copyWith(color: Colors.black))],),
                    );
                    }),
              ))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "Sent to %d people | ".plural(recipients.length) + DateFormat.yMd(Intl.defaultLocale).add_jm().format(sendDateTime), 
                style: AppStyles.paragraph.copyWith(color: AppStyles.darkGrey),),
              SizedBox(width: 5.0,),
              Container(
                height: 16.0,
                width: 16.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppStyles.darkGrey)),
                child: AutoSizeText("i", minFontSize: 0,))
            ],
          ),
        ),
      ],),
    );
  }
}