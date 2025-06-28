import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/scanner/scan_title_section.dart';
import 'package:unihub/pages/scanner/scan_camera_section.dart';
import 'package:unihub/pages/scanner/scan_mode_toggle.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';

enum ScanMode { qr, barcode }

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => QRScanner();
}

class QRScanner extends State<ScanPage> {
  bool isScanCompleted = false;
  bool isManager = true;
  final ValueNotifier<ScanMode> currentMode = ValueNotifier(ScanMode.qr);

  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            ScanTitleSection(currentMode: currentMode.value),
            ScanCameraSection(controller: scannerController, mode: currentMode,brFunction: (value) {},qrFunction: (value) {},),
            Provider.of<UserRoleProvider>(context).isManager
                ? ScanModeToggle(
                  currentMode: currentMode.value,
                  onModeChanged: (newMode) {
                    setState(() {
                      currentMode.value = newMode;
                    });
                  },
                )
                : Expanded(child: Container(color: Colors.transparent)),
          ],
        ),
      ),
    );
  }
}
