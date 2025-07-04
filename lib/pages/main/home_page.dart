import 'dart:math';
import 'package:flutter/material.dart';
import 'package:unihub/pages/Complaint/manager/manager_all_issues.dart';
import 'package:unihub/pages/Complaint/my_complaint.dart';
import 'package:unihub/pages/Complaint/submit_complaint_page.dart';
import 'package:unihub/pages/IoT/control_device_page.dart';
import 'package:unihub/pages/IoT/iot_page.dart';
import 'package:unihub/pages/RoomBooking/Online_Booking/online_booking.dart';
import 'package:unihub/pages/RoomBooking/manager/manger_all_booking.dart';
import 'package:unihub/pages/RoomBooking/my_booking_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/pages/main/map_preview_widget.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onNavigateToMap;
  const HomePage({super.key, this.onNavigateToMap});
  static GestureDetector quickAccessBox({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget pageToNavigate,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pageToNavigate),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.18,
        width: MediaQuery.of(context).size.width * 0.38,
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        decoration: AppDecorations.cardDecoration(context),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).userName;
    return Scaffold(
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Center(
                child: Text(
                  "hello, $username",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ), //! Add username to welcome
            const SizedBox(height: 30),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(
                  maxWidth: 630,
                  maxHeight: 630,
                ),
                decoration: AppDecorations.cardDecoration(context),
                child: Stack(
                  children: [
                    // This makes sure MapPreviewWidget does not block any gestures
                    Positioned.fill(
                      child: InteractiveViewer(
                        child: AbsorbPointer(
                          absorbing: true,
                          child: MapPreviewWidget(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: ElevatedButton(
                        onPressed: onNavigateToMap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size(150, 50),
                        ),
                        child: Text(
                          "view map",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Quick Access",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 30),
            Provider.of<UserProvider>(context).userType == "manager"
                ? Column(
                  spacing: min(MediaQuery.of(context).size.width * 0.05, 30),
                  children: [
                    Row(
                      spacing: min(
                        MediaQuery.of(context).size.width * 0.05,
                        30,
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        quickAccessBox(
                          context: context,
                          icon: Icons.report_problem,
                          title: 'view complaint',
                          pageToNavigate: ManagerViewAllComplaintPage(),
                        ),
                        quickAccessBox(
                          context: context,
                          icon: Icons.event_note,
                          title: 'view booking',
                          pageToNavigate: ManagerViewBookingPage(),
                        ),
                      ],
                    ),
                    Row(
                      spacing: min(
                        MediaQuery.of(context).size.width * 0.05,
                        30,
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        quickAccessBox(
                          context: context,
                          icon: Icons.bolt,
                          title: 'Energy usage',
                          pageToNavigate: EnergyUsagePage(),
                        ),
                        quickAccessBox(
                          context: context,
                          icon: Icons.settings_remote,
                          title: 'control device',
                          pageToNavigate: ControlDevicePage(),
                        ),
                      ],
                    ),
                  ],
                )
                : Column(
                  spacing: min(MediaQuery.of(context).size.width * 0.05, 30),
                  children: [
                    Row(
                      spacing: min(
                        MediaQuery.of(context).size.width * 0.05,
                        30,
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        quickAccessBox(
                          context: context,
                          icon: Icons.report,
                          title: 'submit complaint',
                          pageToNavigate: SubmitComplaintPage(),
                        ),
                        quickAccessBox(
                          context: context,
                          icon: Icons.meeting_room,
                          title: 'book a room',
                          pageToNavigate: OnlineBookingPage(),
                        ),
                      ],
                    ),
                    Row(
                      spacing: min(
                        MediaQuery.of(context).size.width * 0.05,
                        30,
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        quickAccessBox(
                          context: context,
                          icon: Icons.assignment,
                          title: 'view complaint',
                          pageToNavigate: UserViewAllComplaintPage(),
                        ),
                        quickAccessBox(
                          context: context,
                          icon: Icons.calendar_today,
                          title: 'view booking',
                          pageToNavigate: MyBookingPage(),
                        ),
                      ],
                    ),
                  ],
                ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
