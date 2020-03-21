import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:relay/ui/models/contacts_collection_model.dart';

import 'ui/screens/group_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print(Translations.missingKeys);
    print(Translations.missingTranslations);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactsCollectionModel>(create: (_) => ContactsCollectionModel(),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [            
                 GlobalMaterialLocalizations.delegate,
                 GlobalWidgetsLocalizations.delegate,
                 GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                 const Locale('en', "US"), 
              ],
        home: I18n(
          initialLocale: Locale('en', 'US'),
          child: GroupListScreen()),
      ),
    );
  }
}