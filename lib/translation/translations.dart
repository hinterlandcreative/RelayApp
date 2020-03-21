import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

    static var _t = Translations.byLocale("en_us") +
    {
      "en_us": {
        "Search..." : "Search...",
        "Groups" : "Groups",
        "%d Contacts" : "%d Contacts",
        "Compose" : "Compose",
        "New Group" : "New Group",
        "save" : "save",
        "loading your contacts.  " : "loading your contacts.  ",
        "loading your contacts.. " : "loading your contacts.. ",
        "loading your contacts..." : "loading your contacts...",
        " and %d more" : " and %d more"
      }
    };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}