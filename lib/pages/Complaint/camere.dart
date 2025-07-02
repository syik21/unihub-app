import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unihub/pages/asset_manage/backend/asset_backend.dart';
import 'package:unihub/pages/main/scan_page.dart';
import 'package:unihub/pages/scanner/scan_title_section.dart';
import 'package:unihub/pages/scanner/scan_camera_section.dart';

class CameraPage extends StatefulWidget {
  final ValueNotifier<ScanMode> mode;
  const CameraPage({super.key, required this.mode});

  @override
  State<CameraPage> createState() => QRScanner();
}

class QRScanner extends State<CameraPage> {
  bool isScanCompleted = false;
  bool isLoading = false;

  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );

  Future<void> handleBarcode(String value) async {
    if (isScanCompleted) return;

    setState(() {
      isScanCompleted = true;
      isLoading = true;
    });
    final result = await searchAssetByBarcode(value);

    // Optional: Small delay for smooth UX
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      Navigator.pop(context, result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = widget.mode;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor:
            isLoading
                ? Colors.black.withAlpha(150)
                : Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                ScanTitleSection(currentMode: currentMode.value),
                ScanCameraSection(
                  controller: scannerController,
                  mode: currentMode,
                  brFunction: handleBarcode,
                  qrFunction: (value) async {
                    // Add QR handler here if needed
                  },
                ),
                Expanded(child: Container(color: Colors.transparent)),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(150),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
