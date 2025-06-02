import 'package:flutter/material.dart';
import 'package:unihub/pages/RoomBooking/Online_Booking/online_booking.dart';
import 'package:unihub/pages/notification/notification_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          // Center it horizontally
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000), // Set max width here
            child: Container(
              height: 100,
              padding: EdgeInsets.all(16),
              decoration: AppDecorations.cardDecoration(context),
              child: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  SvgPicture.asset(icon, height: 24),
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
      child: ListView(
        padding: EdgeInsets.all(30),
        children: [
          moreOption(
            context,
            "Room Booking",
            'asset/icon/navbar/map-icon.svg',
            OnlineBookingPage(),
          ),
          const SizedBox(height: 20),
          moreOption(
            context,
            "Room Finder",
            'asset/icon/navbar/map-icon.svg',
            NotificationPage(),
          ),
          const SizedBox(height: 20),
          moreOption(
            context,
            "Report Issue",
            'asset/icon/navbar/map-icon.svg',
            NotificationPage(),
          ),
          const SizedBox(height: 20),
          moreOption(
            context,
            "My Booking",
            'asset/icon/navbar/map-icon.svg',
            NotificationPage(),
          ),
          const SizedBox(height: 20),
          moreOption(
            context,
            "Reported Issues",
            'asset/icon/navbar/map-icon.svg',
            NotificationPage(),
          ),
        ],
      ),
    );
  }
}
