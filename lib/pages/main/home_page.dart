import 'dart:math';
import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static Container quickAccessBox(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.width * 0.38,
      constraints: BoxConstraints(maxWidth: 300, maxHeight: 200),
      decoration: AppDecorations.cardDecoration(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    String username = Provider.of<UserRoleProvider>(context).username;
    return Scaffold(
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Welcome, $username",
                style: Theme.of(context).textTheme.headlineMedium,
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16.0,
                        ), // Optional padding from edges
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            minimumSize: const Size(150, 50),
                          ),
                          child: Text(
                            "Click Me",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
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
            Column(
              spacing: min(MediaQuery.of(context).size.width * 0.05, 30),
              children: [
                Row(
                  spacing: min(MediaQuery.of(context).size.width * 0.05, 30),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [quickAccessBox(context), quickAccessBox(context)],
                ),
                Row(
                  spacing: min(MediaQuery.of(context).size.width * 0.05, 30),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [quickAccessBox(context), quickAccessBox(context)],
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
