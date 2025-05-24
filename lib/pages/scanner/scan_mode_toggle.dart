import 'package:flutter/material.dart';
import 'package:unihub/pages/scan_page.dart'; // for ScanMode
import 'package:unihub/theme/theme.dart';

class ScanModeToggle extends StatelessWidget {
  final ScanMode currentMode;
  final void Function(ScanMode) onModeChanged;

  const ScanModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ToggleButtons(
          isSelected: [
            currentMode == ScanMode.qr,
            currentMode == ScanMode.barcode,
          ],
          onPressed: (index) {
            onModeChanged(ScanMode.values[index]);
            debugPrint(" ${ScanMode.values[index]}");
          },
          borderRadius: BorderRadius.circular(10),
          selectedColor: Colors.white,
          fillColor: AppTheme.lightTheme.primaryColor,
          color: AppTheme.lightTheme.primaryColor,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("QR Code"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Barcode"),
            ),
          ],
        ),
      ),
    );
  }
}