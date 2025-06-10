import 'package:flutter/material.dart';
import 'package:unihub/pages/RoomBooking/Online_Booking/online_booking.dart';
import 'package:unihub/pages/notification/notification_page.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/pages/asset_manage/asset_inventory.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  static Material moreOption(
    BuildContext context,
    String optionTitle,
    String icon,
    Widget page,
  ) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            // Center it horizontally // Set max width here
              child: Container(
                constraints: BoxConstraints(maxWidth: 1000),
                height: 100,
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.cardDecoration(context),
                child: Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    SvgPicture.asset(icon, height: 40),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                    Text(
                      optionTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Provider.of<UserRoleProvider>(context).isManager
              ? ListView(
                padding: EdgeInsets.all(30),
                children: [
                  moreOption(
                    context,
                    "room finder",
                    'asset/icon/more_page/key_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "manage asset",
                    'asset/icon/more_page/key_icon.svg',
                    AssetInventory(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Energy Usage",
                    'asset/icon/more_page/key_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "control device",
                    'asset/icon/more_page/key_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "facility issue",
                    'asset/icon/more_page/key_icon.svg',
                    NotificationPage(),
                  ),
                ],
              )
              : ListView(
                padding: EdgeInsets.all(30),
                children: [
                  moreOption(
                    context,
                    "Room Booking",
                    'asset/icon/more_page/location_more_icon.svg',
                    OnlineBookingPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Room Finder",
                    'asset/icon/more_page/key_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Report Issue",
                    'asset/icon/more_page/exclamation_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "My Booking",
                    'asset/icon/more_page/tag_icon.svg',
                    NotificationPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Reported Issues",
                    'asset/icon/more_page/puzzle_icon.svg',
                    NotificationPage(),
                  ),
                ],
              ),
    );
  }
}
