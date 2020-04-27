import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/models/message_recipient.dart';
import 'package:relay/models/message_item.dart';
import 'package:relay/models/contact_item.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/services/message_service.dart';

class ComposeMessageModel extends ChangeNotifier {
  final MessageService _messageService;
  final GroupItemModel _group;
  final List<ContactItemModel> recipients;

  List<MessageItemModel> _messages = [];

  ComposeMessageModel._(this._messageService, this._group, this.recipients) {
    _loadData();
  }

  factory ComposeMessageModel({
    @required GroupItemModel group,
    @required List<ContactItemModel> recipients, 
    MessageService messageService}) {
    return ComposeMessageModel._(
      messageService ?? dependencyLocator<MessageService>(),
      group,
      recipients
    );
  }

  String get groupName => _group.name;

  UnmodifiableListView<MessageItemModel> get messages => UnmodifiableListView(_messages.reversed);

  Future _loadData() async {
    _messages = await _messageService.getAllMessages(_group);
    notifyListeners();
  }

  Future<bool> sendMessageToGroup({@required String message}) async {
    assert(message != null);

    var messageRecipients = recipients.map((r) => MessageRecipient.fromContact(r)).toList();

    if (await _sendMessage(message, messageRecipients) == MessageSendingResult.Success) {
      await _logAndUpdateMessages(messageRecipients, message);
      return true;
    }

    return false;
  }

  Future<bool> sendMessageToIndividuals({@required String message, @required Future<SendMessageNextStep> Function(double progress, int index, MessageRecipient recipient) onSent}) async {
    assert(onSent != null);
    assert(message != null);
    assert(message.isNotEmpty);

    var messageRecipients = recipients.map((r) => MessageRecipient.fromContact(r)).toList();
    List<MessageRecipient> sentRecipients = [];
    for(int index in List.generate(recipients.length, (i) => (i - 1) + 1)) {
      var recipient = messageRecipients[index];
      double percent = (index + 1) / recipients.length;
      var nextStep = await onSent(percent, index + 1, recipient);
      if(nextStep == SendMessageNextStep.Cancel) {
        if(index == 0 || sentRecipients.isEmpty) return false;

        var sublist = messageRecipients.sublist(0, index + 1);
        await _logAndUpdateMessages(sublist, message);
        return true;
      } else if (nextStep == SendMessageNextStep.Skip) {
        continue;
      } else {
        if(await _sendMessage(message, [recipient]) == MessageSendingResult.Success) {
          sentRecipients.add(recipient);
        }
      }
    }

    if(sentRecipients.isNotEmpty) {
      await _logAndUpdateMessages(sentRecipients, message);
    }

    return sentRecipients.isNotEmpty;
  }

  Future _logAndUpdateMessages(List<MessageRecipient> messageRecipients, String message) async {
    var sentMessage = await _messageService.logMessage(
      recipients: messageRecipients, 
      group: _group, 
      message: message);
    
    _messages.add(sentMessage);
    notifyListeners();
  }

  Future<MessageSendingResult> _sendMessage(String message, List<MessageRecipient> recipients) async {
    return await _messageService.sendMessage(
      message: message,
      recipients: recipients);
  }
}

enum SendMessageNextStep {
  Send,
  Skip,
  Cancel
}