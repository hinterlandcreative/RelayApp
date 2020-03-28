abstract class Mappable {
  const Mappable();

  Mappable.fromMap(Map<String, dynamic> map);

  Map<String, dynamic> toMap();

  Mappable copy();
}