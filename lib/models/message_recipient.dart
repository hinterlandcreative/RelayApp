import 'package:relay/models/contact_item.dart';

class MessageRecipient {
  final String name;
  final String number;

  const MessageRecipient(this.name, this.number);

  MessageRecipient.fromContact(ContactItemModel contact) : this(contact.fullName, contact.phone);
}