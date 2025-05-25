import 'package:flutter/material.dart';
import 'package:unihub/theme/theme.dart';
import 'package:unihub/navbar/setting/base_scaffold.dart';
import 'package:unihub/pages/main/home_page.dart';
import 'package:unihub/pages/main/map_page.dart';
import 'package:unihub/pages/main/scan_page.dart';
import 'package:unihub/pages/main/more_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  ThemeMode _themeMode = ThemeMode.light; // Default mode

  //! Use this in theme changer (new dart file)
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(),
      MapPage(),
      ScanPage(),
      MorePage(toggleTheme: _toggleTheme),
    ];

    return MaterialApp(
      title: 'UniHub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: BaseScaffold(
        toggleTheme: _toggleTheme,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        body: pages[_currentIndex],
      ),
    );
  }
}
