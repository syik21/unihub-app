import 'package:flutter/material.dart';
import 'package:unihub/pages/Complaint/manager/manager_all_issues.dart';
import 'package:unihub/pages/Complaint/submit_complaint_page.dart';
import 'package:unihub/pages/Complaint/my_complaint.dart';
import 'package:unihub/pages/IoT/control_device_page.dart';
import 'package:unihub/pages/IoT/iot_page.dart';
import 'package:unihub/pages/RoomBooking/Online_Booking/online_booking.dart';
import 'package:unihub/pages/RoomBooking/manager/manger_all_booking.dart';
import 'package:unihub/pages/RoomBooking/my_booking_page.dart';
import 'package:unihub/pages/RoomBooking/qr_booking/qr_booking.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_inventory.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

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
              Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoPageRoute(builder: (context) => page)
                  : MaterialPageRoute(builder: (context) => page),
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
          Provider.of<UserProvider>(context).userType == "manager"
              ? ListView(
                padding: EdgeInsets.all(30),
                children: [
                  moreOption(
                    context,
                    "Booking request",
                    'asset/icon/more_page/Bookmark.svg',
                    ManagerViewBookingPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "manage asset",
                    'asset/icon/more_page/DocumentDuplicate.svg',
                    AssetInventory(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "facility issue",
                    'asset/icon/more_page/exclamation_icon.svg',
                    ManagerViewAllComplaintPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Energy Usage",
                    'asset/icon/more_page/LightningBolt.svg',
                    EnergyUsagePage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "control device",
                    'asset/icon/more_page/LightBulb.svg',
                    ControlDevicePage(),
                  ),
                ],
              )
              : ListView(
                padding: EdgeInsets.all(30),
                children: [
                  moreOption(
                    context,
                    "Room finder",
                    'asset/icon/more_page/location_more_icon.svg',
                    QrRoomBookingPage(room: {"id": '4755409f-6815-42b1-be37-6235ce66e02d', 'name':'B-01-03', 'type': 'Discussion Room', 'capacity': '20', 'current_people': '0', 'status': 'free', 'last_maintenance': '2025-06-15T21:32:28', 'map_id': '96fe6d7e-219f-4b2b-9493-8d5a2da036e7'}),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Room Booking",
                    'asset/icon/more_page/key_icon.svg',
                    OnlineBookingPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Report Issue",
                    'asset/icon/more_page/exclamation_icon.svg',
                    SubmitComplaintPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "My Booking",
                    'asset/icon/more_page/tag_icon.svg',
                    MyBookingPage(),
                  ),
                  const SizedBox(height: 20),
                  moreOption(
                    context,
                    "Reported Issues",
                    'asset/icon/more_page/puzzle_icon.svg',
                    UserViewAllComplaintPage(),
                  ),
                ],
              ),
    );
  }
}
