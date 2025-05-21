import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 30,
      title: Text(
        "UniHub",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 24,
          fontFamily: 'Nura',
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: 15,
          ), // You can change to `left: 16` to move left
          child: Row(
            children: [
              IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
              IconButton(icon: Icon(Icons.person), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
