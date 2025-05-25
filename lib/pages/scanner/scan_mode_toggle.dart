import 'package:flutter/material.dart';
import 'package:unihub/pages/main/scan_page.dart';

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
        child: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.secondary, // optional background
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                Theme.of(context).brightness == Brightness.light
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: ToggleButtons(
            borderColor: Colors.transparent,
            isSelected: [
              currentMode == ScanMode.qr,
              currentMode == ScanMode.barcode,
            ],
            onPressed: (index) {
              onModeChanged(ScanMode.values[index]);
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Theme.of(context).colorScheme.secondary,
            fillColor: Theme.of(context).colorScheme.tertiary,
            color: Theme.of(context).colorScheme.tertiary,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("QR Code"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("Barcode"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
