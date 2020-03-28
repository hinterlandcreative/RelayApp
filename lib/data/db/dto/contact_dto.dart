import 'package:relay/data/db/dto/dto.dart';

class ContactDto extends DTO {
  final String firstName;
  final String lastName;
  final String phone;
  final String imagePath;
  final String company;
  final DateTime birthday;

  const ContactDto({int id, this.firstName, this.lastName, this.phone, this.imagePath, this.company, this.birthday}) : super(id: id ?? -1);

  @override 
  ContactDto.fromMap(Map<String, dynamic> map) : this(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      imagePath: map['imagePath'],
      company: map['company'],
      birthday: map.containsKey('birthday') && map['birthday'] != null ? DateTime.fromMillisecondsSinceEpoch(map['birthday']) : null);

  @override
  ContactDto copy() {
    return ContactDto(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      imagePath: imagePath,
      company: company,
      birthday: birthday);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'imagePath': imagePath,
      'company': company,
      'birthday': birthday != null ? birthday.millisecondsSinceEpoch : null
    };
  }

}