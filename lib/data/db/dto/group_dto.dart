import 'package:sembast/utils/value_utils.dart';

import 'package:relay/data/db/dto/dto.dart';
import 'package:relay/data/db/dto/preferred_send_type.dart';

class GroupDto extends DTO {
  final String name;
  final PreferredSendType preferredSendType;
  final List<int> contacts;
  final DateTime lastMessageSentDate;
  final DateTime creationDate;

  GroupDto({int id, this.name, this.preferredSendType, this.contacts, this.lastMessageSentDate, this.creationDate}) : super(id: id ?? -1);


  @override
  GroupDto copy() {
    return GroupDto(
      name: name,
      preferredSendType: preferredSendType,
      contacts: contacts,
      lastMessageSentDate: lastMessageSentDate,
      creationDate: creationDate
    );
  }

  @override
  GroupDto.fromMap(Map<String, dynamic> map) 
    : this(
        id: map['id'], 
        name: map['name'], 
        contacts: cloneList(map['contacts']).map((i) => i as int).toList(),
        lastMessageSentDate: map.containsKey("lastMessageSentDate") 
          ? map['lastMesssageSentDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageSentDate']) 
            : null
          : null,
        creationDate: map.containsKey('creationDate') ? DateTime.fromMillisecondsSinceEpoch(map['creationDate']) : null,
        preferredSendType: map.containsKey('preferredSendType')
          ? PreferredSendType.values.firstWhere((v) => v.toString().split('.').last == map['preferredSendType'], orElse: () => PreferredSendType.Unset)
          : PreferredSendType.Unset);

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contacts': (contacts ?? <int>[]).toList(growable: false),
      'preferredSendType': preferredSendType.toString().split('.').last,
      'creationDate': creationDate == null ? null : creationDate.millisecondsSinceEpoch,
      'lastMessageSentDate': lastMessageSentDate == null ? null : lastMessageSentDate.millisecondsSinceEpoch
    };
  }

  GroupDto copyWith({
    int id,
    String name,
    PreferredSendType preferredSendType,
    List<int> contacts,
    DateTime lastMessageSentDate,
    DateTime creationDate
  }) {
    return GroupDto(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredSendType: preferredSendType ?? this.preferredSendType,
      contacts: contacts ?? this.contacts,
      lastMessageSentDate: lastMessageSentDate ?? this.lastMessageSentDate,
      creationDate: creationDate ?? this.creationDate
    );
  }

}