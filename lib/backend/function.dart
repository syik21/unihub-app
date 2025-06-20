import 'package:flutter/foundation.dart';
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

Future<String> getImageUrl(String path) async {
  final response = Supabase.instance.client
      .storage
      .from('image') // your bucket name
      .getPublicUrl(path); // or use createSignedUrl

  return response;
}

Future<bool> checkConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return !listEquals(connectivityResult, [ConnectivityResult.none]);
}