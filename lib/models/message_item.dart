import 'dart:collection';

import 'package:relay/models/message_recipient.dart';
import 'package:relay/data/db/dto/message_dto.dart';
import 'package:relay/models/group_item.dart';

class MessageItemModel {
  final String message;
  final UnmodifiableListView<MessageRecipient> recipients;
  final DateTime sendDateTime;
  final GroupItemModel group;
  final int id;

  MessageItemModel({this.message, this.recipients, this.sendDateTime, this.group, this.id});

  MessageItemModel.fromDto(MessageDto dto, GroupItemModel group) : this(
    id: dto.id,
    message: dto.message,
    sendDateTime: dto.sendDateTime,
    group: group,
    recipients: UnmodifiableListView(
      dto
        .recipients
        .entries
        .map((contact) 
          => MessageRecipient(
            contact.key, 
            contact.value)))
  );
}