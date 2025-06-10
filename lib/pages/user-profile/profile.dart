import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ProfilePage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isManager = Provider.of<UserRoleProvider>(context).isManager;
    return Scaffold(
      appBar: AppBar(title: const Text("Unihub Theme Demo")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: toggleTheme, // ✅ Use the callback from parent
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.tertiary,
                ),
                foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              child: const Text("Toggle Theme"),
            ),
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
    );
  }
}
