import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/text_style.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Nura",
    iconTheme: IconThemeData(color: Color(0xFF14141E)),

    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      primary: Colors.white,
      secondary: Colors.white,
      tertiary: Color(0xFF14141E), //For button or need to emphasize item
      shadow: Color.fromARGB(51, 0, 0, 0),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,

    textTheme: MyTextStyle.lightTextTheme,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Color(0xFF14141E)),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF14141E),
      unselectedItemColor: Color(0xFF14141E),
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      type: BottomNavigationBarType.fixed,
    ),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Nura",
    iconTheme: IconThemeData(color: Colors.white),

    brightness: Brightness.dark,
    primaryColor: Color(0xFF14141E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF14141E),
      primary: Color(0xFF14141E),
      secondary: Color(0xFF2F3545),
      tertiary: Color.fromARGB(255, 181, 253, 6),
      //For button or need to emphasize item
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Color(0xFF14141E),

    textTheme: MyTextStyle.darkTextTheme,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF14141E),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF14141E),
      selectedItemColor: Color(0xFFB5FD06), // Or any primary color
      unselectedItemColor: Colors.white,
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
