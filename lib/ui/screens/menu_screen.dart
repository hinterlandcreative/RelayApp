import 'dart:io';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:provider/provider.dart';

import 'package:relay/ui/models/app_settings_model.dart';
import 'package:relay/ui/screens/settings_screen.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/ui/widgets/long_arrow_button.dart';
import 'package:relay/mixins/color_mixin.dart';
import 'package:relay/ui/app_styles.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key key,
  }) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [HexColor.fromHex("#626672"), HexColor.fromHex("#6B7899")]
          )
        ),
      child: Consumer<AppSettingsModel>(
        builder: (context, model, __) => Stack(children: <Widget>[
          if(model.name != null && model.name.isNotEmpty) Positioned(
            top: 0.0,
            left: 0.0,
            child: Container(
              height: 165.00 + MediaQuery.of(context).padding.top,
              width: 209.00,
              decoration: BoxDecoration(
                color: Color(0xff6f7a9a),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.00))
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: AppStyles.horizontalMargin),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(model: model)));
                      SimpleHiddenDrawerProvider.of(context).toggle();
                    },
                    child: Row(
                      children: <Widget>[
                        if(model.imagePath != null && model.imagePath.isNotEmpty) Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(model.imagePath))),
                            color: AppStyles.darkGrey
                          ),
                        ),
                        Box(width: 10.0,),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextOneLine(
                              model.name,
                              style: AppStyles.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.w100)
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                )
              )
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 25.0),
              child: LongArrowButton(
                onTap: () {
                  SimpleHiddenDrawerProvider.of(context).toggle();
                },
              ),
            )
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.top + 90.0,
            left: AppStyles.horizontalMargin,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(model: model,)));
                SimpleHiddenDrawerProvider.of(context).toggle();
              },
              child: Row(children: <Widget>[
                Icon(Icons.settings, color: Colors.white,),
                Box(width: 10.0),
                Text(
                  "Settings".i18n, 
                  style: AppStyles.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.w100)
                )
              ],),
            )
          )
        ],),
      ),
      ),
    );
  }
}

