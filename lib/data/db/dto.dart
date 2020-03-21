import '../core/mappable.dart';

abstract class DTO extends Mappable {
  final int id;

  const DTO({this.id = -1});
}