import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'package:relay/core/app_settings_keys.dart';
import 'package:relay/services/analytics_service.dart';
import 'package:relay/services/app_settings_service.dart';
import 'package:relay/data/db/query_package.dart';
import 'package:relay/data/db/dto/message_dto.dart';
import 'package:relay/data/db/db_collection.dart';
import 'package:relay/models/message_recipient.dart';
import 'package:relay/models/group_item.dart';
import 'package:relay/models/message_item.dart';
import 'package:relay/ioc/dependency_registrar.dart';
import 'package:relay/services/database_service.dart';
import 'package:relay/services/group_service.dart';

class MessageService {
  static const String _messageDbName = "messages";
  static const String _messageSentEvent = "messaging_message_sent";
  final DatabaseService _dbService;
  final GroupService _groupService;
  final AppSettingsService _appSettingsService;
  final AnalyticsService _analyticsService;

  Completer<DbCollection> _messageDb = Completer();

  MessageService._(this._dbService, this._groupService, this._appSettingsService, this._analyticsService) {
    _dbService.getMainStorage().then((db) {
      _messageDb.complete(db.collections(_messageDbName));
    });
  }

  factory MessageService([DatabaseService databaseService, GroupService groupService, AppSettingsService appSettings, AnalyticsService analyticsService]) {
    return MessageService._(
      databaseService ?? dependencyLocator<DatabaseService>(), 
      groupService ?? dependencyLocator<GroupService>(),
      appSettings ?? dependencyLocator<AppSettingsService>(),
      analyticsService ?? dependencyLocator<AnalyticsService>());
  }

  Future<List<MessageItemModel>> getAllMessages(GroupItemModel group) async {
    assert(group != null);
    assert(group.id > 0);

    var db = await _messageDb.future;

    var messages = await db.query([QueryPackage(
      key: "groupId",
      value: group.id,
      filter: FilterType.EqualTo
    )], (map) => MessageDto.fromMap(map));

    return messages
      .map((m) => MessageItemModel.fromDto(m, group))
      .toList();
  }

  Future<MessageSendingResult> sendMessage({
    @required List<MessageRecipient> recipients,
    @required String message}) async {
    assert(recipients != null);
    assert(recipients.isNotEmpty);
    assert(message != null);
    assert(message.isNotEmpty);
    
    if(await _appSettingsService.getSettingBool(AppSettingsConstants.auto_include_signature_settings_key)) {
      String signature = await _appSettingsService.getSettingString(AppSettingsConstants.signature_settings_key);
      message = message + signature;
    }
    
    var result = await sendSMS(message: message, recipients: recipients.map((r) => r.number).toList());
    if(result == "cancelled") {
      return MessageSendingResult.Cancelled;
    } else if (result == "failed") {
      return MessageSendingResult.Failed;
    } else if (result == "sent" || result == "SMS Sent!") {
      return MessageSendingResult.Success;
    }
    
    print("Unknown Result Message: $result");
    return MessageSendingResult.Failed;
  }

  Future<MessageItemModel> logMessage({
    @required List<MessageRecipient> recipients, 
    @required GroupItemModel group, 
    @required String message}) async {
    assert(group != null);
    assert(group.id > 0);
    assert(recipients != null);
    assert(recipients.isNotEmpty);
    assert(message != null);
    assert(message.isNotEmpty);

    var dto = MessageDto(
      message: message, 
      sendDateTime: DateTime.now(), 
      recipients: Map.fromIterables(
        recipients.map((r) => r.name), 
        recipients.map((r) => r.number)), 
      groupId: group.id);

    var db = await _messageDb.future;

    var id = await db.add(dto);

    dto = dto.copyWith(id: id);

    group.lastMessageSentDate = dto.sendDateTime;
    group = await _groupService.updateGroup(group);

    var messageCount = await _appSettingsService.getSettingInt(AppSettingsConstants.analytics_message_count);
    _appSettingsService.setSettingInt(AppSettingsConstants.analytics_message_count, messageCount++);

    await _analyticsService.trackEvent(
      _messageSentEvent,
      properties: {
        'recipients': recipients.length,
      });

    return MessageItemModel.fromDto(dto, group);
  }
}

enum MessageSendingResult {
  Success,
  Cancelled,
  Failed
}