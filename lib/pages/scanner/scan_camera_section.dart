import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unihub/theme/theme.dart';
import 'package:unihub/pages/scanner/scanner_layout.dart';
import 'package:unihub/pages/scan_page.dart'; // for ScanMode

class ScanCameraSection extends StatelessWidget {
  final MobileScannerController controller;
  final ValueNotifier<ScanMode> mode;

  const ScanCameraSection({
    super.key,
    required this.controller,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scanSize = min(constraints.maxHeight, constraints.maxWidth);
          final currentMode = mode.value;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: scanSize,
                maxHeight: scanSize,
              ),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: scanSize * 0.95,
                      height: scanSize * 0.95,
                      child: MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final value = barcode.rawValue;
                            if (value == null) continue;

                            if (currentMode == ScanMode.qr &&
                                value.contains("qr")) {
                              debugPrint('QR Code Detected: $value');
                            } else if (currentMode == ScanMode.barcode &&
                                value.contains("br")) {
                              debugPrint('Barcode Detected: $value');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  QRScannerOverlay(
                    scanAreaWidth: scanSize,
                    scanAreaHeight: scanSize,
                    borderStrokeWidth: scanSize * 0.04,
                    borderPadding: 1.2,
                    borderLength: scanSize * 0.008,
                    borderRadius: 40,
                    borderColor: AppTheme.lightTheme.primaryColor,
                    overlayColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
