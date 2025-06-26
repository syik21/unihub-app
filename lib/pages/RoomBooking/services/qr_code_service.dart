import 'dart:convert';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRCodeService {
  // Generate QR code data for a booking
  static String generateBookingQRData({
    required String bookingId,
    required String venue,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    final data = {
      'booking_id': bookingId,
      'venue': venue,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
    };
    
    return jsonEncode(data);
  }

  // Generate QR code widget
  static Widget generateQRCode(String data) {
    return PrettyQrView.data(
      data: data,
      decoration: const PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(
          color: Colors.black,
          roundFactor: 0.25,
        ),
        image: PrettyQrDecorationImage(
          image: AssetImage('asset/icon/other/notification-icon.svg'),
          position: PrettyQrDecorationImagePosition.embedded,
        ),
      ),
    );
  }

  // Check room status by scanning QR code
  static Future<Map<String, dynamic>?> getRoomStatusFromQR(String scanned) async {
    if (!scanned.startsWith('QR ')) return null;
    String roomCode = scanned.substring(3).trim();
    final response = await Supabase.instance.client
        .from('room')
        .select()
        .eq('name', roomCode)
        .maybeSingle();
    if (response == null) return null;
    return response;
  }
} 