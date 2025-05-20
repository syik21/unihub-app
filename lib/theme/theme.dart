import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/text_style.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Nura",
    brightness: Brightness.light,
    primaryColor: Color(0xFF14141E),
    scaffoldBackgroundColor: Colors.white,
    textTheme: MyTextStyle.lightTextTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Nura",
    brightness: Brightness.dark,
    primaryColor: Color(0xFFB5FD06),
    scaffoldBackgroundColor: Color(0xFF14141E),
    textTheme: MyTextStyle.darkTextTheme,
  );
}
