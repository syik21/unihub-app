import 'package:intl/intl.dart';

String formatTimestamp(String timestamp) {
    final utcTime = DateTime.parse(timestamp);
    final localTime = utcTime.toLocal(); // convert from UTC to device timezone
    return DateFormat('dd-MM-yyyy hh:mm a').format(localTime);
}