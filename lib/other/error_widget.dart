import 'package:flutter/material.dart';

class NoConnectionPage extends StatelessWidget {
  final VoidCallback function;
  const NoConnectionPage({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "Oops!",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 36,
                fontFamily: 'Nura',
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Theme.of(context).brightness == Brightness.light? Image.asset('asset/image/error/discon-image.png'): Image.asset('asset/image/error/discon-imageW.png'),
              const SizedBox(height: 30),
              Text(
                "Connection Lost",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15,
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.8,),
                  "Connection left the chat. Your Wi-Fi ghosted harder than a situationship. Might be time to reboot your life and your router — because clearly, none of them are connecting.",
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: function,
                      child: Text(
                        'Retry',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
