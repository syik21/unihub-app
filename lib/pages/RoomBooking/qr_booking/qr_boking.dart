import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unihub/services/room_booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:unihub/pages/RoomBooking/Online_Booking/quick_room_booking.dart';

class QrBookingPage extends StatefulWidget {
  const QrBookingPage({super.key});

  @override
  State<QrBookingPage> createState() => _QrBookingPageState();
}

class _QrBookingPageState extends State<QrBookingPage> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? scannedData;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleScannedCode(String code) async {
    print('Scanned code: $code');
    if (!isScanning) return;
    setState(() {
      isScanning = false;
      scannedData = code;
    });

    // 1. Handle room QR (plain text)
    if (code.startsWith('QR ')) {
      print('Detected room QR: $code');
      String roomCode = code.substring(3).trim();
      print('Extracted room code: $roomCode');
      final room = await Supabase.instance.client
          .from('room')
          .select()
          .eq('name', roomCode)
          .maybeSingle();
      print('Room query result: $room');
      if (room != null) print('Room status: ${room['status']}');
      if (room != null && room['status'] == 'free') {
        if (!mounted) return;
        print('Navigating to QuickRoomBookingPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuickRoomBookingPage(
              roomName: room['name'],
              roomType: room['type'],
              roomUuid: room['id'],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        print('Room not available for booking.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room not available for booking.')),
        );
        setState(() {
          isScanning = true;
          scannedData = null;
        });
      }
      return;
    }

    // 2. Handle booking QR (JSON)
    try {
      final data = Map<String, dynamic>.from(
        const JsonDecoder().convert(code),
      );

      // Show booking details dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Room Booking Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Venue: ${data['venue']}'),
              Text('Date: ${DateTime.parse(data['date']).toString().split(' ')[0]}'),
              Text('Time: ${data['start_time']} - ${data['end_time']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanning = true;
                  scannedData = null;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final bookingService = RoomBookingService();
                  // Construct start and end DateTime from QR data
                  final date = data['date'];
                  final startDateTime = DateTime.parse(date + 'T' + data['start_time']);
                  final endDateTime = DateTime.parse(date + 'T' + data['end_time']);
                  await bookingService.createBooking(
                    userId: Supabase.instance.client.auth.currentUser!.id,
                    roomId: data['roomId'] ?? '',
                    startDateTime: startDateTime,
                    endDateTime: endDateTime,
                    purpose: 'QR Booking',
                    description: 'Booked via QR code',
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Room booked successfully'),
                      ),
                    );
                    setState(() {
                      isScanning = true;
                      scannedData = null;
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error booking room: $e'),
                      ),
                    );
                    setState(() {
                      isScanning = true;
                      scannedData = null;
                    });
                  }
                }
              },
              child: const Text('Book Room'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Invalid QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid QR code: $e'),
        ),
      );
      setState(() {
        isScanning = true;
        scannedData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                print('onDetect fired!');
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  print('Barcode found: ${barcode.rawValue}');
                  _handleScannedCode(barcode.rawValue ?? '');
                }
              },
            ),
          ),
          if (!isScanning)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = true;
                    scannedData = null;
                  });
                },
                child: const Text('Scan Again'),
              ),
            ),
        ],
      ),
    );
  }
}