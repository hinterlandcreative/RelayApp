import 'dart:async';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:relay/mixins/route_aware_analytics_mixin.dart';

import 'package:relay/models/contact_item.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/models/message_recipient.dart';
import 'package:relay/ui/models/compose_message_model.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/mixins/color_mixin.dart' as RelayApp;
import 'package:relay/ui/widgets/message_container.dart';
import 'package:relay/translation/translations.dart';

class ComposeMessageScreen extends StatefulWidget {
  final GroupItemModel group;
  final List<ContactItemModel> recipients;
  const ComposeMessageScreen({Key key, @required this.group, @required this.recipients}) : super(key: key);

  @override
  _ComposeMessageScreenState createState() => _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends State<ComposeMessageScreen> with RouteAwareAnalytics {
  final TextEditingController textMessagingController = TextEditingController();

  @override
  String get screenClass => "ComposeMessageScreen";

  @override
  String get screenName => "/ComposeMessage";

  @override
  void dispose() { 
    textMessagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: ChangeNotifierProvider<ComposeMessageModel>(
        create: (_) => ComposeMessageModel(group: widget.group, recipients: widget.recipients),
         child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppStyles.lightGrey,
          body: Stack(
            children: <Widget>[

              // Header
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                height: MediaQuery.of(context).padding.top + 90.0,
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(
                      color: AppStyles.darkGrey,
                      onPressed: () => Navigator.of(context).pop())),
                    Positioned.fill(
                      child: Center(
                        child: Consumer<ComposeMessageModel>(
                          builder: (_,model,__) => Text(model.groupName, style: AppStyles.heading1.copyWith(color: AppStyles.darkGrey),)),)) 
                  ]))),

              // Body
              Positioned.fill(
                top: MediaQuery.of(context).padding.top + 90.0,
                left: 0.0,
                right: 0.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40.00), topRight: Radius.circular(40.00)),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(left: 23.0, right: 23.0, bottom: 23.0),
                      child: Stack(
                        children: <Widget>[
                        
                        // Message list
                        Positioned.fill(
                          bottom: 115.0,
                          left: 40.0,
                          right: 0.0,
                          top: 0.0,
                          child: Consumer<ComposeMessageModel>(
                            builder: (_, model, __) => ListView.builder(
                              reverse: true,
                              itemCount: model.messages.length,
                              itemBuilder: (_, index) {
                                var message = model.messages[index];
                                return MessageContainer(
                                  message: message.message,
                                  sendDateTime: message.sendDateTime,
                                  recipients: message.recipients,
                                  onDetailsPressed: () {},
                              );
                              }))),

                        // New Message Box
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 140.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppStyles.lightGrey,
                              borderRadius: BorderRadius.circular(30.00)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    controller: textMessagingController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none
                                    ),
                                    maxLines: 6,),
                                ),
                                Consumer<ComposeMessageModel>(
                                  builder: (_, model, __) => Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Container(
                                        height: 45.00,
                                        width: 58.00,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppStyles.primaryGradientStart, AppStyles.primaryGradientEnd],
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.topRight),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0.00,3.00),
                                              color: Color(0xff000000).withOpacity(0.16),
                                              blurRadius: 6),
                                          ], 
                                          borderRadius: BorderRadius.circular(25.00)),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              if(textMessagingController.text.isEmpty) {
                                                toast("Please enter a message first.".i18n);
                                                return;
                                              }

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (c) => AlertDialog(
                                                  backgroundColor: Colors.transparent,
                                                  contentPadding: EdgeInsets.all(0),
                                                  content: _SendIndividuallyDialog(
                                                    context: context,
                                                    model: model, 
                                                    messageController: textMessagingController)
                                                )
                                              );
                                            },
                                            icon: Icon(
                                              Icons.person_outline,
                                              color: Colors.white)))),
                                      Icon(
                                        Icons.arrow_forward_ios, 
                                        size: 10.0,
                                        color: RelayApp.HexColor.fromHex("#D9D9D9")),
                                      Container(
                                        height: 45.00,
                                        width: 58.00,
                                        decoration: BoxDecoration(
                                          color: AppStyles.brightGreenBlue,
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0.00,3.00),
                                              color: Color(0xff000000).withOpacity(0.16),
                                              blurRadius: 6),
                                          ], 
                                          borderRadius: BorderRadius.circular(25.00)),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () async {
                                              if(textMessagingController.text.isEmpty) {
                                                toast("Please enter a message first.".i18n);
                                                return;
                                              } else if(await model.sendMessageToGroup(message: textMessagingController.text)) {
                                                textMessagingController.clear();
                                              }
                                            },
                                            icon: Icon(
                                              Icons.people_outline,
                                              color: Colors.white))))
                                    ],
                                  ),
                                )
                              ],),
                            )))
                      ],))),
                )),
            Positioned(
              top: MediaQuery.of(context).padding.top + 70.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: Container(
                  height: 35.00,
                  decoration: BoxDecoration(
                    color: Color(0xfff3f3f3),
                    borderRadius: BorderRadius.circular(20.00)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right:16.0, top: 10.0),
                    child: Consumer<ComposeMessageModel>(
                      builder: (_, model, __) => Text("%d People".plural(model.recipients.length), style: AppStyles.paragraph.copyWith(
                        color: AppStyles.darkGrey,
                        fontWeight: FontWeight.bold)),
                    ),
                  )),
              ),
            )
            ],
          )
        ),
      ),
    );
  }
}

class _SendIndividuallyDialog extends StatefulWidget {
  final BuildContext context;
  final ComposeMessageModel model;
  final TextEditingController messageController;
  const _SendIndividuallyDialog({
    Key key, 
    @required this.model, 
    @required this.context, 
    @required this.messageController
  }) : super(key: key);

  @override
  _SendIndividuallyDialogState createState() => _SendIndividuallyDialogState();
}

class _SendIndividuallyDialogState extends State<_SendIndividuallyDialog> {
  double percent;
  String nextName;
  String nextNumber;
  String index;
  String total;
  Completer<SendMessageNextStep> messageSendCompleter = Completer();

  @override
  void dispose() { 
    if(!messageSendCompleter.isCompleted) {
      messageSendCompleter.complete(SendMessageNextStep.Cancel);
    }
    super.dispose();
  }

  @override
  void initState() {
    percent = 0.0;
    nextName = "";
    nextNumber = "";
    index = "1";
    total = widget.model.recipients.length.toString();

    widget.model
      .sendMessageToIndividuals(message: widget.messageController.text, onSent: onSent)
      .then((didSendMessages) {
        if(didSendMessages) {
          widget.messageController.clear();
        }
        
        return Navigator.pop(widget.context, true);
      });

    super.initState();
  }

  Future<SendMessageNextStep> onSent(double percent, int idx, MessageRecipient recipient) {
    setState(() {
      this.percent = percent;
      index = idx.toString();
      nextName = recipient.name;
      nextNumber = recipient.number;
    });
    
    messageSendCompleter = Completer();
    return messageSendCompleter.future;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),
          width: MediaQuery.of(context).size.width,
          height: 400.0,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 250.0,
                    width: 250.0,
                    child: Lottie.asset(
                      "assets/animations/paper-flying-animation.json",
                      repeat: true)
                  ),
                ),
              ),
              Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    height: 60.0,
                    child: Stack(
                      children: <Widget>[
                        Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(index, style: AppStyles.heading1.copyWith(color: AppStyles.primaryGradientEnd),)),
                          Transform.rotate(
                              angle: -45.0,
                              child: Container(
                                color: AppStyles.primaryGradientEnd,
                                height: 4.0,
                                width: 60.0,),),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(total, style: AppStyles.heading1.copyWith(color: AppStyles.primaryGradientEnd),)),
                      ],),
                      ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Name", style: AppStyles.heading2Bold.copyWith(color: AppStyles.primaryGradientStart),),
                      Text(nextName, style: AppStyles.heading2Bold.copyWith(color: AppStyles.primaryGradientStart),),
                      Text(nextNumber, style: AppStyles.heading2.copyWith(color: AppStyles.primaryGradientStart),)
                  ],),
                )
              ],),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 28.0),
                child: LinearPercentIndicator(
                  lineHeight: 18.0,
                  percent: percent,
                  animateFromLastPercent: true,
                  progressColor: AppStyles.primaryGradientEnd,
                ),
              ),
              Container(
                width: 212.0,
                child: FlatButton(
                  onPressed: () => messageSendCompleter.complete(SendMessageNextStep.Send),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  color: AppStyles.primaryGradientEnd,
                  child: Text("send".i18n, style: AppStyles.paragraph)
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: FlatButton(
                  onPressed: () => messageSendCompleter.complete(SendMessageNextStep.Skip),
                  child: Text("skip".i18n, style: AppStyles.paragraph.copyWith(color: AppStyles.primaryGradientEnd)),),
              )
            ],
          ),
        ),
        Positioned(
          right:0,
          top:0,
          child: IconButton(
            onPressed: () => messageSendCompleter.complete(SendMessageNextStep.Cancel),
            icon: Icon(Icons.close, color: AppStyles.primaryGradientEnd)))
      ],
    );
  }
}