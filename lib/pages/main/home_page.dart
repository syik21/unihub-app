import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Main title',
              style: Theme.of(context).textTheme.headlineLarge
            ),
            SizedBox(height: 10), // Optional spacing between texts
            Text(
              'Sub title',
              style: Theme.of(context).textTheme.headlineMedium
            ),
            SizedBox(height: 10), // Optional spacing between texts
            Text(
              'heading',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: 'Nura',
              ),
            ),
            SizedBox(height: 10), // Optional spacing between texts
            Text(
              'normal',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                fontFamily: 'Nura',
              ),
            ),
            SizedBox(height: 10), // Optional spacing between texts
            Text(
              'info',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: 'Nura',
              ),
            ),
            SizedBox(height: 10), // Optional spacing between texts
            Text(
              'smaller info',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Nura',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
