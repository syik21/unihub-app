import 'package:flutter/material.dart';
import 'package:unihub/pages/notification/notification_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              IconButton(
                icon: SvgPicture.asset(
                  'asset/icon/other/notification-icon.svg',
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).brightness == Brightness.light? Color(0xFF14141E) : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
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
