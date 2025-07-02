import 'package:flutter/material.dart';
import 'navbar/setting/base_scaffold.dart';
import 'pages/main/home_page.dart';
import 'pages/main/map_page.dart';
import 'pages/main/scan_page.dart';
import 'pages/main/more_page.dart';

class MainApp extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MainApp({super.key, required this.toggleTheme,});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> pages = [HomePage(), MapPage(), ScanPage(), MorePage()];
  

  @override
  Widget build(BuildContext context) {
    
    return BaseScaffold(
      toggleTheme: widget.toggleTheme,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState((){
          _currentIndex = index;
        });
      },
      body: pages[_currentIndex],
    );
  }
}
