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
            currentMode == ScanMode.qr ? "QR Code Scanner" : "Barcode Scanner",
            style: Theme.of(context).textTheme.headlineMedium
          ),
          const SizedBox(height: 10),
          Text(
            currentMode == ScanMode.qr
                ? "Place and scan a QR code in the area to book the room."
                : "Place a asset barcode in the area",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
