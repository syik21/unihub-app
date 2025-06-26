import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

String formatTimestamp(String timestamp) {
  final utcTime = DateTime.parse(timestamp);
  final localTime = utcTime.toLocal(); // convert from UTC to device timezone
  return DateFormat('dd/MM/yyyy   hh:mm a').format(localTime);
}

String formatDatestamp(String timestamp) {
  final utcTime = DateTime.parse(timestamp);
  final localTime = utcTime.toLocal(); // convert from UTC to device timezone
  return DateFormat('dd/MM/yyyy').format(localTime);
}
String formatDateWithMonth(String timestamp) {
  final utcTime = DateTime.parse(timestamp);
  final localTime = utcTime.toLocal(); // convert from UTC to device timezone
  return DateFormat('dd MMM yyyy').format(localTime);
}

String formatTimetoString(TimeOfDay t) {
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:${t.minute.toString().padLeft(2, '0')}$period';
}
String formatStringToTime(String timeString) {
  final dateTime = DateFormat.Hm().parse(timeString);
  return formatTimetoString(TimeOfDay.fromDateTime(dateTime));
}

Future<String> getImageUrl(String path) async {
  final response = Supabase.instance.client.storage
      .from('image') // your bucket name
      .getPublicUrl(path); // or use createSignedUrl

  return response;
}

Future<bool> checkConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return !listEquals(connectivityResult, [ConnectivityResult.none]);
}

TimeOfDay parseTimeOfDayFromFullString(String timeString) {
  final parts = timeString.split(":");
  if (parts.length < 2) {
    throw FormatException("Invalid time format, expected HH:mm:ss");
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) {
    throw FormatException("Invalid numeric values in time string");
  }

  return TimeOfDay(hour: hour, minute: minute);
}
