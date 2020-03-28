import 'package:flutter/foundation.dart';
import 'package:sembast/utils/value_utils.dart';

import 'package:relay/data/db/dto/dto.dart';

class MessageDto extends DTO {
  final String message;
  final DateTime sendDateTime;
  final Map<String, String> recipients;
  final int groupId;

  const MessageDto({
    int id, 
    @required this.message, 
    @required this.sendDateTime, 
    @required this.recipients, 
    @required this.groupId}) : super(id: id ?? -1);

  @override
  MessageDto.fromMap(Map<String, dynamic> map) : this(
    id: map['id'],
    groupId: map['groupId'],
    message: map['message'],
    recipients: Map<String, String>.from(cloneMap(map['recipients'])),
    sendDateTime: map.containsKey('sendDateTime') && map['sendDateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['sendDateTime']) : null);

  @override
  MessageDto copy() {
    return MessageDto(
      id: id,
      groupId: groupId,
      message: message,
      recipients: recipients,
      sendDateTime: sendDateTime);
  }

  @override
  Map<String, dynamic> toMap() {
    try {
      return {
        'id' : id,
        'groupId' : groupId,
        'message' : message,
        'sendDateTime' : sendDateTime.millisecondsSinceEpoch,
        'recipients' : Map<String, dynamic>.from(recipients)
      };
    } catch(e) {
      return {};
    }
  }

  MessageDto copyWith({int id, int groupId, String message, DateTime sendDateTime, Map<String, String> recipients}) {    
    return MessageDto(
      id: id ?? this.id,
      message: message ?? this.message, 
      sendDateTime: sendDateTime ?? this.sendDateTime, 
      recipients: recipients ?? this.recipients, 
      groupId: groupId ?? this.groupId);
  }
}