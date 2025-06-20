import 'package:flutter/material.dart';

class AppDecorations {
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
      boxShadow:
          Theme.of(context).brightness == Brightness.light
              ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
              : [],
    );
  }

  static void showCustomSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    final snackBar = SnackBar(
      margin: EdgeInsets.only(bottom: 30, left: 30, right: 30),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Text(message, style: const TextStyle(color: Color(0xFF14141E))),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(snackBar);

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (_) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              scaffoldMessenger.hideCurrentSnackBar();
              overlayEntry?.remove();
            },
            child: const SizedBox.expand(),
          ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  static void showCustomBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      builder:
          (context) => SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    textAlign: TextAlign.center,
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Close',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
