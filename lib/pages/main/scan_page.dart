import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/pages/RoomBooking/qr_booking/qr_booking.dart';
import 'package:unihub/pages/scanner/scan_title_section.dart';
import 'package:unihub/pages/scanner/scan_camera_section.dart';
import 'package:unihub/pages/scanner/scan_mode_toggle.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_detail.dart';

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
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            ScanTitleSection(currentMode: currentMode.value),
            ScanCameraSection(
              controller: scannerController,
              mode: currentMode,
              brFunction: handleBrScan,
              qrFunction: handleQrScan,
            ),
            Provider.of<UserProvider>(context).userType == "manager"
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

  Future<void> checkingConnect() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      iconColor: Colors.white,
    );
  }

  Future<void> handleQrScan(String value) async {
    AppDecorations.showLoadingDialog(context, message: "Checking QR...");
    await checkingConnect();
    if (!isConnected) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorMessage("No connection");
      return;
    }
    if (value.startsWith('qr ')) {
      String roomCode = value.substring(3).trim();
      final room =
          await Supabase.instance.client
              .from('room')
              .select('*,map(*)')
              .eq('name', roomCode)
              .maybeSingle();
      if (room == null) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (mounted) {
          _showErrorMessage('Room $roomCode does not exist.');
        }
        return;
      } else if (room['status'] == 'full') {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (mounted) {
          AppDecorations.showTopSnackBar(
            context,
            'Room $roomCode is full.',
            backgroundColor: Colors.red,
            icon: Icons.error,
            iconColor: Colors.white,
          );
        }
        return;
      } else if (room['status'] != 'free' && room['status'] != 'occupied') {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (mounted) {
          AppDecorations.showTopSnackBar(
            context,
            'Room $roomCode is currently in use.',
            backgroundColor: Colors.red,
            icon: Icons.error,
            iconColor: Colors.white,
          );
        }
        return;
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrRoomBookingPage(room: room),
          ),
        );
        return;
      }
    } else {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        AppDecorations.showTopSnackBar(
          context,
          'Invalid QR scanned',
          backgroundColor: Colors.red,
          icon: Icons.error,
          iconColor: Colors.white,
        );
      }
      return;
    }
  }

  Future<void> handleBrScan(String value) async {
    AppDecorations.showLoadingDialog(context, message: "Checking Barcode...");
    await checkingConnect();
    if (!isConnected) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorMessage("No connection");
      return;
    }
    final assetList = await Supabase.instance.client
        .from('asset')
        .select()
        .eq('code', value)
        .limit(1);

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (assetList.isEmpty) {
      if (mounted) {
        AppDecorations.showTopSnackBar(
          context,
          'Asset not found for barcode: $value',
          backgroundColor: Colors.red,
          icon: Icons.error,
          iconColor: Colors.white,
        );
      }
      return;
    }

    final asset = assetList[0];
    if (asset['condition'] != 'good') {
      if (mounted) {
        AppDecorations.showTopSnackBar(
          context,
          'Asset is not in good condition: ${asset['condition']}',
          backgroundColor: Colors.orange,
          icon: Icons.warning,
          iconColor: Colors.white,
        );
      }
      // Optionally: return here if you don't want to allow navigation
      // return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailPage(assetCode: value),
      ),
    );
  }
}
