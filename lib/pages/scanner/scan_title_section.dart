import 'package:flutter/material.dart';
import 'package:unihub/pages/main/scan_page.dart'; //  ScanMode

class ScanTitleSection extends StatelessWidget {
  final ScanMode currentMode;

  const ScanTitleSection({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentMode == ScanMode.qr ? "Enter a room" : "Search asset",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            currentMode == ScanMode.qr
                ? "Scan a room QR code in the area before entering."
                : "Place a asset barcode in the area to find its details.",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
