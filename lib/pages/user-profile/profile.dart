import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/login/account_settings_page.dart';
import 'package:unihub/login/change_password_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ProfilePage({super.key, required this.toggleTheme});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GestureDetector settingBox(
    BuildContext context,
    String title,
    String icon,
    Widget navPage,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () async {
        await checkingConnect();
        if (isConnected == true) {
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => navPage),
          );
        } else {
          _showErrorMessage("no connection!");
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: screenHeight * 0.02,
        ),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: min(screenWidth * 0.035, 24),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            size: screenHeight * 0.03,
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icons.cancel_rounded,
      iconColor: Colors.white,
    );
  }

  Map<String, dynamic>? userDetail;
  bool isConnected = true;
  bool _initialized = false;
  dynamic userImageUrl;

  @override
  void initState() {
    super.initState();
    checkingconnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        loadUser(userId);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[300]
                        : Color(0xFF2F3545),
                child:
                    userImageUrl != null && userImageUrl.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            userImageUrl,
                            width: screenHeight * 0.18,
                            height: screenHeight * 0.18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // If image fails to load (e.g. no connection), fallback
                              return Container(
                                color: Colors.grey[300],
                                width: screenHeight * 0.18,
                                height: screenHeight * 0.18,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
              ),
              const SizedBox(height: 20),
              // Name
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Text(
                    userProvider.userName?.toUpperCase() ?? "USER",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              // Email
              Text(
                Provider.of<UserProvider>(context).userEmail ?? 'no email',
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
                AccountSettingsPage(toggleTheme: widget.toggleTheme),
              ),

              // Change Password Button
              settingBox(
                context,
                "CHANGE PASSWORD",
                "asset/icon/other/LockClosed.svg",
                ChangePasswordPage(toggleTheme: widget.toggleTheme),
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
                  onPressed: () {
                    final userProvider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );
                    userProvider.logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Text(
                    'LOG OUT',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUser(String? user) async {
    try {
      final userId = Provider.of<UserProvider>(context).userId;
      final result = await searchUserById(
        userId, //! user id here ------------------------------------------------------------------------------------------------------------
      );
      if (mounted) {
        setState(() {
          userDetail = result;
          userImageUrl = userDetail?['image_url'];
        });
      }
    } catch (e) {
      // Handle error here
    }
  }

  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  Future<void> checkingConnect() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }
}
