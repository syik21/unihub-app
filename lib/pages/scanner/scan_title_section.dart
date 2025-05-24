import 'package:flutter/material.dart';
import 'package:unihub/pages/scan_page.dart'; //  ScanMode

class ScanTitleSection extends StatelessWidget {
  final ScanMode currentMode;

  const ScanTitleSection({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentMode == ScanMode.qr ? "QR Code Scanner" : "Barcode Scanner",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: MediaQuery.textScalerOf(context).scale(22),
              fontFamily: 'Nura',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentMode == ScanMode.qr
                ? "Place a QR code in the area"
                : "Place a barcode in the area",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Nura',
            ),
          ),
        ],
      ),
    );
  }
}