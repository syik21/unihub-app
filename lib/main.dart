import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/main_app.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/theme.dart';
import 'login/login_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  await Supabase.initialize(
    url: 'https://mmwsequldlkykpdqowqe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1td3NlcXVsZGxreWtwZHFvd3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzODk2MzAsImV4cCI6MjA2NDk2NTYzMH0.M3sILt6TgfTO2iXTl6lW_qAu1dsQMzKXcTPqBmPjev0',
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const UniHubApp(),
    ),
  );
}

class UniHubApp extends StatefulWidget {
  const UniHubApp({super.key});

  @override
  State<UniHubApp> createState() => _UniHubAppState();
}

class _UniHubAppState extends State<UniHubApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'UniHub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AuthScreen(),
        '/main': (context) => MainApp(toggleTheme: _toggleTheme),
      },
    );
  }
}
