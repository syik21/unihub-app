import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unihub/pages/scanner/scanner_layout.dart';
import 'package:unihub/pages/main/scan_page.dart';

class ScanCameraSection extends StatefulWidget {
  final MobileScannerController controller;
  final ValueNotifier<ScanMode> mode;
  final Future<void> Function(String) qrFunction;
  final Future<void> Function(String) brFunction;

  const ScanCameraSection({
    super.key,
    required this.controller,
    required this.mode,
    required this.qrFunction,
    required this.brFunction,
  });

  @override
  State<ScanCameraSection> createState() => _ScanCameraSectionState();
}

class _ScanCameraSectionState extends State<ScanCameraSection> with RouteAware {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = min(constraints.maxHeight, constraints.maxWidth);

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
                      controller: widget.controller,
                      onDetect: (capture) async {
                        print("----------------------------------------------------------------------------------------${widget.mode.value}");
                        print("----------------------------------------------------------------------------------------${_scanned}");
                        if (_scanned) return;
                        final currentMode = widget.mode.value;
                        for (final barcode in capture.barcodes) {
                          final value = barcode.rawValue;
                          if (value == null) continue;

                          if (currentMode == ScanMode.qr &&
                              value.contains("qr")) {
                            _scanned = true;
                            await widget.controller.stop();
                            await widget.qrFunction(value);
                            widget.controller.start();
                            _scanned = false;
                          } else if (currentMode == ScanMode.barcode &&
                              value.contains("br")) {
                            _scanned = true;
                            await widget.controller.stop();
                            await widget.brFunction(value);
                            widget.controller.start();
                            _scanned = false;
                          }
                        }
                      },
                    ),
                  ),
                ),

                // Scanner overlay
                QRScannerOverlay(
                  scanAreaWidth: scanSize,
                  scanAreaHeight: scanSize,
                  borderStrokeWidth: scanSize * 0.04,
                  borderPadding: 1.2,
                  borderLength: scanSize * 0.008,
                  borderRadius: 40,
                  borderColor: Theme.of(context).colorScheme.secondary,
                  overlayColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
