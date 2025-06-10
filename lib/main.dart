import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/theme.dart';
import 'package:unihub/navbar/setting/base_scaffold.dart';
import 'package:unihub/pages/main/home_page.dart';
import 'package:unihub/pages/main/map_page.dart';
import 'package:unihub/pages/main/scan_page.dart';
import 'package:unihub/pages/main/more_page.dart';

void main() async{
  await Supabase.initialize(
    url: 'https://mmwsequldlkykpdqowqe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1td3NlcXVsZGxreWtwZHFvd3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzODk2MzAsImV4cCI6MjA2NDk2NTYzMH0.M3sILt6TgfTO2iXTl6lW_qAu1dsQMzKXcTPqBmPjev0',
  );
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
    final List<Widget> pages = [HomePage(), MapPage(), ScanPage(), MorePage()];

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserRoleProvider())],
      child: MaterialApp(
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
      ),
    );
  }
}
