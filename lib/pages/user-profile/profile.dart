import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ProfilePage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unihub Theme Demo")),
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}