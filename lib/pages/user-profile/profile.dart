import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/notification/notification_page.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ProfilePage({super.key, required this.toggleTheme});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static Container settingBox(
    BuildContext context,
    String title,
    String icon,
    Widget navPage,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: screenHeight * 0.02),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppDecorations.cardDecoration(context),
      child: ListTile(
        horizontalTitleGap: 30,
        leading: SvgPicture.asset(
          icon,
          height: screenHeight * 0.03,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.tertiary,
            BlendMode.srcIn,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontSize: min(screenWidth * 0.035, 24)),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: Theme.of(context).colorScheme.tertiary,
          size: screenHeight * 0.03,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navPage),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManager = Provider.of<UserRoleProvider>(context).isManager;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Profile",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 32),
              CircleAvatar(
                radius: screenHeight * 0.09,
                //backgroundImage: AssetImage(
                // 'assets/profile_placeholder.png',
                //), // Replace with your image asset or NetworkImage
              ),
              const SizedBox(height: 20),
              // Name
              Text(
                "KENJI",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              // Email
              Text(
                "KENJI@GMAIL.COM",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Account Setting Button
              settingBox(
                context,
                "ACCOUNT SETTING",
                "asset/icon/other/Cog.svg",
                NotificationPage(),
              ),

              // Change Password Button
              settingBox(
                context,
                "CHANGE PASSWORD",
                "asset/icon/other/LockClosed.svg",
                NotificationPage(),
              ),

              // Dark Mode Toggle
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: screenHeight * 0.02,
                ),
                decoration: AppDecorations.cardDecoration(context),
                child: ListTile(
                  horizontalTitleGap: 30,
                  leading: SvgPicture.asset(
                    "asset/icon/other/Sun.svg",
                    height: screenHeight * 0.03,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.tertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    "DARK MODE",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: min(screenWidth * 0.035, 24),
                    ),
                  ),
                  trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                    inactiveThumbColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Colors.grey[350],
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.transparent; // ON state
                      }
                      return Colors.transparent; // OFF state
                    }),
                    value: isDark,
                    onChanged: (val) {
                      widget.toggleTheme();
                    },
                  ),
                ),
              ),
              // Log Out Button
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'LOG OUT',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (isManager) {
                    Provider.of<UserRoleProvider>(
                      context,
                      listen: false,
                    ).setManager(false);
                  } else {
                    Provider.of<UserRoleProvider>(
                      context,
                      listen: false,
                    ).setManager(true);
                  }
                }, // ✅ Use the callback from parent
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Text("manager? $isManager"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
