import 'package:flutter/material.dart';
import 'package:unihub/theme/theme.dart';
import 'package:unihub/navbar/setting/base_scaffold.dart';
import 'package:unihub/pages/home_page.dart';
import 'package:unihub/pages/map_page.dart';
import 'package:unihub/pages/scan_page.dart';
import 'package:unihub/pages/more_page.dart';

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

  final List<Widget> _pages = const [
    HomePage(),
    MapPage(),
    ScanPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniHub',
      debugShowCheckedModeBanner: false,
      home: BaseScaffold(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        body: _pages[_currentIndex],
      ),
    );
  }
}
