import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static TranslationsByLocale _t = Translations.byLocale("en_us") +
    {
      "en_us": {
        "No" : "No",
        "Yes" : "Yes",
        "Confirm delete?" : "Confirm delete?",
        "Search..." : "Search...",
        "Groups" : "Groups",
        "%d Contacts" : "%d Contacts",
        "Contacts" : "Contacts",
        "Add Contact" : "Add Contact",
        "Open Settings" : "Open Settings",
        "Exit" : "Exit",
        "Compose" : "Compose",
        "compose" : "compose",
        "Please enter a message first." : "Please enter a message first.",
        "send" : "send",
        "skip" : "skip",
        "Skip" : "Skip",
        "Next" : "Next",
        "Get started" : "Get started",
        "New Group" : "New Group",
        "save" : "save",
        "Save" : "Save",
        "%s (copy)" : "%s (copy)",
        "delete" : "delete",
        "Duplicate" : "Duplicate",
				"Delete" : "Delete",
        "Cancel" : "Cancel",
        "No results." : "No results.",
        "Let's add your first group." : "Let's add your first group.",
        "loading your contacts.  " : "loading your contacts.  ",
        "loading your contacts.. " : "loading your contacts.. ",
        "loading your contacts..." : "loading your contacts...",
        " and %d more" : " and %d more",
        "Mobile #" : "Mobile #",
        "Sent on %s" : "Sent on %s",
        "Please select some contacts." : "Please select some contacts.",
        "Choose Number" : "Choose Number",
        "Please give your group a name." : "Please give your group a name.",
        "Okay" : "Okay",
        "Let's add your first group." : "Let's add your first group.",
        "Are you sure you want to delete the group '%s'?" : "Are you sure you want to delete the group '%s'?",
        "Check this box to confirm delete!" : "Check this box to confirm delete!",
        "Group Name" : "Group Name",
        "Your Profile" : "Your Profile",
        "Enter Name" : "Enter Name",
        "change" : "change",
        "Group Sorting" : "Group Sorting",
				"Last Sent First" : "Last Sent First",
				"Alphabetical" : "Alphabetical",
        "Signature" : "Signature",
        "Include signature on every message." : "Include signature on every message.",
        "Settings" : "Settings",
        "Unlimited Groups" : "Unlimited Groups",
        "year*" : "year*",
        "six months*" : "six months*",
        "three months*" : "three months*",
        "two monnths*" : "two months*",
        "monthly*" : "monthly*",
        "weekly*" : "weekly*",
        "product_pricing: %s / %s" : "%s / %s",
				"lifetime" : "lifetime",
				"Restore Purchases" : "Restore Purchases",
				"subscription_tos" : "* Subscriptions will automatically renew and your purchase method will be charged at the end of each period, unless you unsubscribe at least 24 hours before.",
				"Purchase failed." : "Purchase failed.",
        "Terms of Use" : "Terms of Use",
				"Privacy Policy" : "Privacy Policy",
        "I Agree" : "I Agree",
        "Version: %s" : "Version: %s",
        "no-contacts-permission-text" : "Relay cannot function without access to your contacts.\n\nPlease reinstall the app and allow access or open settings to allow Relay access to contacts.",
        "Unlimited groups have not been purchased using this account." : "Unlimited groups have not been purchased using this account.",
        "product_description" : "Unlock unlimited mass texting groups. Create as many new groups as you need and send unlimited messages.\n\nGet access to new pro features like scheduled messages, templates and more.",
        " (%d people selected)" : ""
          .zero("  (No people selected)")
          .one("  (1 person selected)")
          .many("  (%d people selected)"),
        "%d People" : ""
          .zero("Empty")
          .one("1 Person")
          .many("%d People"),
        "Sent to %d people | " : ""
          .one("Sent to 1 person | ")
          .many("Sent to %d people | "),
        "%d Recipients" : ""
          .one("1 Recipient")
          .many("%d Recipients"),
      }
    };

  String get i18n => localize(this, _t);

  String plural(int number) => localizePlural(number, this, _t);

  String fill(List<Object> params) => localizeFill(this.i18n, params);
}