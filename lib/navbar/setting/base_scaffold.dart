import 'package:flutter/material.dart';
import 'package:unihub/navbar/app_bar.dart';
import 'package:unihub/navbar/bottom_bar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final void Function(int) onTap;

  const BaseScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: body,
      bottomNavigationBar:CustomBottomNavBar(currentIndex: currentIndex, onTap: onTap),
    );
  }
}