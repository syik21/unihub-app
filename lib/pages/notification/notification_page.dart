import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          AppDecorations.showTopSnackBar(
            context,
            'Complaint deleted successfully',
            backgroundColor: Colors.lightGreen,
            icon: Icons.check_circle,
            iconColor: Colors.white,
          );
          
        },
        child: Text('LOG OUT', style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}
