import 'package:flutter/material.dart';
import '../mixins/color_mixin.dart';

class AppStyles {
  static Color get lightGrey => HexColor.fromHex("#DBDBDB");
  static Color get primaryGradientStart => HexColor.fromHex("#3E7389");
  static Color get primaryGradientEnd => HexColor.fromHex("#4447A8");
  static Color get brightGreenBlue => HexColor.fromHex("#76CAD8");

  static TextStyle get heading1 => TextStyle(fontFamily: "Avenir", fontSize: 24, fontWeight: FontWeight.bold, color:Colors.white);
  static TextStyle get heading2 => TextStyle(fontFamily: "Avenir", fontSize: 16, color:Colors.black);
  static TextStyle get heading2Bold => heading2.copyWith(fontWeight: FontWeight.bold);
  static TextStyle get paragraph => TextStyle(fontFamily: "Avenir", fontSize: 14, color:Colors.white,);
  static TextStyle get smallText => TextStyle(fontFamily: "Avenir", fontSize: 10, color:Colors.black,);

  static double get horizontalMargin => 30.0;
}