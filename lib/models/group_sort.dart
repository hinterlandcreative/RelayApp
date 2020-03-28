import 'package:relay/translation/translations.dart';

abstract class GroupSort {
  final int _value;

  static const GroupSort lastSentFirst = _LastSentFirst(1);
  static const GroupSort alphabetical = _Alphabetical(2);

  const GroupSort._(this._value);

  static List<String> get valueStrings => [
    lastSentFirst.toString(),
    alphabetical.toString()
  ];

  static List<GroupSort> get values => [
    lastSentFirst,
    alphabetical
  ];

  static GroupSort parseInt(int value) {
    return values.firstWhere((v) => v._value == value, orElse: () => null);
  }

  int toInt();
}

class _LastSentFirst extends GroupSort {
  const _LastSentFirst(int value) : super._(value);

  @override
  String toString() {
    return "Last Sent First".i18n;
  }

  @override
  bool operator ==(Object other) {
    if((other is GroupSort) == false) return false;

    if(other is _LastSentFirst) return true;

    return false;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  int toInt() => _value;
}

class _Alphabetical extends GroupSort {
  const _Alphabetical(int value) : super._(value);

  @override
  String toString() {
    return "Alphabetical".i18n;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if((other is GroupSort) == false) return false;

    if(other is _Alphabetical) return true;

    return false;
  }

  @override
  int toInt() => _value;
}