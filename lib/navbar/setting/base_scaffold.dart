import 'package:flutter/material.dart';
import 'package:unihub/navbar/app_bar.dart';
import 'package:unihub/navbar/bottom_bar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final bool showAppBar;
  final bool showBottomNav;
  final int currentIndex;
  final void Function(int) onTap;

  const BaseScaffold({
    super.key,
    required this.body,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? const CustomAppBar() : null,
      body: body,
      bottomNavigationBar: showBottomNav
          ? CustomBottomNavBar(currentIndex: currentIndex, onTap: onTap)
          : null,
    );
  }
}