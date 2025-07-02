import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/RoomBooking/view_booking_detail_page.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  final bookingService = RoomBookingService();
  List<Map<String, dynamic>>? allbooking = [];
  List<Map<String, dynamic>>? filteredBookings = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isConnected = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    checkingconnection();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        loadBooking(userId);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body:
          isConnected
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'My booking',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      decoration: AppDecorations.cardDecoration(context),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (val) {
                                filterComplaintDetail(
                                  query: val,
                                  selectedStatuses: selectedStatuses,
                                  selectedDate: selectedDate,
                                );
                              },
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              decoration: InputDecoration(
                                hintText: 'search a booking',
                                hintStyle: TextStyle(
                                  fontFamily: 'Nura',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                                border: InputBorder.none,
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: () {
                                _showFilterModal(context);
                              },
                              child: Icon(
                                Icons.tune_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Wrap(
                        spacing: 20, // horizontal spacing between status items
                        runSpacing: 8, // vertical spacing when wrapped
                        children: [
                          _buildStatusDot(
                            'pending',
                            Colors.orange.withAlpha(200),
                          ),
                          _buildStatusDot(
                            'Up-Coming',
                            Colors.lightGreen.withAlpha(200),
                          ),
                          _buildStatusDot(
                            'on-going',
                            Colors.lightBlue.withAlpha(200),
                          ),
                          _buildStatusDot(
                            'rejected',
                            Colors.redAccent.withAlpha(200),
                          ),
                          _buildStatusDot('ended', Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child:
                          isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.grey[300],
                                ),
                              )
                              : filteredBookings!.isEmpty
                              ? const Center(child: Text("No booking found"))
                              : ListView.builder(
                                itemCount: filteredBookings?.length,
                                itemBuilder: (context, index) {
                                  final bookingDetail =
                                      filteredBookings![index];
                                  final title = bookingDetail['Purpose'];
                                  final status = bookingDetail['Status'];
                                  final startDate = bookingDetail['Start_date'];
                                  final endDate = bookingDetail['End_date'];
                                  final startTime = formatStringToTime(
                                    bookingDetail['start_time'],
                                  );
                                  final endTime = formatStringToTime(
                                    bookingDetail['end_time'],
                                  );

                                  final location =
                                      bookingDetail['room']['name'];
                                  final block =
                                      bookingDetail['room']['map']['block'];
                                  final floor =
                                      bookingDetail['room']['map']['floor'];
                                  return buildMyBookingTile(
                                    context,
                                    title,
                                    status,
                                    startDate,
                                    endDate,
                                    startTime,
                                    endTime,
                                    location,
                                    block,
                                    floor,
                                    bookingDetail,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              )
              : NoConnectionPage(
                function: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => MyBookingPage()),
                  );
                },
              ),
    );
  }

  Future<void> loadBooking(String? userId) async {
    try {
      final userId = Provider.of<UserProvider>(context).userId;
      final result = await bookingService.getUserBookings(
        userId, //! user id here ------------------------------------------------------------------------------------------------------------
      );
      if (mounted) {
        setState(() {
          allbooking = result;
          filteredBookings = result;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error here
    }
  }

  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  void filterComplaintDetail({
    required String query,
    required Set<String> selectedStatuses,
    DateTime? selectedDate,
  }) {
    final q = query.toLowerCase();
    setState(() {
      filteredBookings =
          allbooking?.where((complaint) {
            final status = (complaint['Status'] ?? '').toString().toLowerCase();
            final room =
                (complaint['room']?['name'] ?? '').toString().toLowerCase();
            final type = complaint['Purpose']?.toLowerCase() ?? '';
            final dateStr = complaint['Start_date'];
            final dateEnd = complaint['End_date'];
            DateTime? strDate;
            DateTime? endDate;

            // Parse complaint date
            try {
              strDate = DateTime.parse(dateStr).toLocal();
              endDate = DateTime.parse(dateEnd).toLocal();
            } catch (_) {}

            final matchesQuery =
                status.startsWith(q) ||
                room.startsWith(q) ||
                type.toString().startsWith(q);
            final matchesStatus =
                selectedStatuses.isEmpty || selectedStatuses.contains(status);
            final matchesDate =
                selectedDate == null ||
                (strDate != null &&
                    endDate != null &&
                    !selectedDate.isBefore(strDate) &&
                    !selectedDate.isAfter(endDate));

            return matchesQuery && matchesStatus && matchesDate;
          }).toList();
    });
  }

  DateTime? selectedDate;
  Set<String> selectedStatuses = {};

  void _showFilterModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: const Text(
                        '- Filter -',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.upcoming),
                        const SizedBox(width: 10),
                        const Text(
                          "Status: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: Colors.orangeAccent,
                          title: const Text(
                            "Pending",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("pending"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("pending");
                              } else {
                                selectedStatuses.remove("pending");
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: Colors.lightGreen,
                          title: const Text(
                            "Up-coming",
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("approved"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("approved");
                              } else {
                                selectedStatuses.remove("approved");
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: Colors.lightBlue,
                          title: const Text(
                            "On-going",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("ongoing"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("ongoing");
                              } else {
                                selectedStatuses.remove("ongoing");
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: Colors.redAccent,
                          title: const Text(
                            "Rejected",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("rejected"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("rejected");
                              } else {
                                selectedStatuses.remove("rejected");
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: Colors.grey,
                          title: const Text(
                            "Ended",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("ended"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("ended");
                              } else {
                                selectedStatuses.remove("ended");
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 📅 Date Picker
                    Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 10),
                        const Text(
                          'Date:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(DateTime.now().year),
                                lastDate: DateTime(DateTime.now().year + 2),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogTheme: DialogThemeData(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                      ), // Background color
                                      colorScheme:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? ColorScheme.dark(
                                                primary:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                onPrimary:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                secondary:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                onSecondary:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                onSurface: Colors.white,
                                                surface:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              )
                                              : ColorScheme.light(
                                                primary:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                onPrimary:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                secondary:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                onSecondary:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                onSurface: Colors.black,
                                                surface:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                      textTheme: TextTheme(
                                        headlineLarge:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineLarge,
                                        titleSmall:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                        titleMedium:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                        displayLarge: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 50,
                                          fontFamily: 'Nura',
                                        ),
                                        displayMedium: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 50,
                                          fontFamily: 'Nura',
                                        ),
                                        labelLarge:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                        bodyMedium:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                        bodySmall:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        bodyLarge:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                      ),
                                      // You can also customize shape, button text, etc.
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: AppDecorations.cardDecoration(
                                context,
                              ).copyWith(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? formatDatestamp(
                                      selectedDate!.toLocal().toString(),
                                    )
                                    : 'Select a date',
                                style: TextStyle(
                                  color:
                                      selectedDate != null
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.tertiary
                                          : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          filterComplaintDetail(
                            query: searchController.text,
                            selectedStatuses: selectedStatuses,
                            selectedDate: selectedDate,
                          );
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text('Apply Filters'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          selectedStatuses.clear();
                          selectedDate = null;
                          setState(() {});
                        },
                        child: Text(
                          "Clear All",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
    setState(() {
      filterComplaintDetail(
        query: searchController.text,
        selectedStatuses: selectedStatuses,
        selectedDate: selectedDate,
      );
    });
  }
}

Widget _buildStatusDot(String label, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 8,
        width: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );
}

Widget buildMyBookingTile(
  BuildContext context,
  String title,
  String status,
  String startDate,
  String endDate,
  String startTime,
  String endTime,
  String location,
  String block,
  String floor,
  Map<String, dynamic> booking,
) {
  // Decide color and icon based on status
  Color boxColor;
  final screenWidth = MediaQuery.of(context).size.width;

  switch (status.toLowerCase()) {
    case 'pending':
      boxColor = Colors.orangeAccent.withAlpha(200);
      break;
    case 'approved':
      boxColor = Colors.lightGreen.withAlpha(200);
      break;
    case 'ongoing':
      boxColor = Colors.lightBlue;
      break;
    case 'rejected':
      boxColor = Colors.redAccent.withAlpha(200);
      break;
    default:
      boxColor = Colors.grey;
  }

  return Column(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoPageRoute(
                  builder:
                      (context) => ViewBookingDetailPage(
                        booking: booking,
                        page: MyBookingPage(),
                      ),
                )
                : MaterialPageRoute(
                  builder:
                      (context) => ViewBookingDetailPage(
                        booking: booking,
                        page: MyBookingPage(),
                      ),
                ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(left: 24, right: 24, bottom: 30),
          height: 200,
          decoration: AppDecorations.cardDecoration(context),
          child: Row(
            children: [
              // Left section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: boxColor, // cyan blue
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flag, size: 16, color: Color(0xFF14141E)),
                          SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: min(screenWidth * 0.035, 16),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF14141E),
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'block $block      floor $floor',
                        style: TextStyle(
                          fontSize: min(screenWidth * 0.03, 12),
                          height: 1.5,
                          color: Color(0xFF14141E),
                        ),
                      ),

                      SizedBox(height: 20),
                      Text(
                        'Time\n$startTime - $endTime',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: min(screenWidth * 0.04, 16),
                          height: 1.5,
                          color: Color(0xFF14141E),
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: min(screenWidth * 0.04, 16),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right section (Date)
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child:
                        startDate == endDate
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM',
                                  ).format(DateTime.parse(startDate).toLocal()),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd',
                                  ).format(DateTime.parse(startDate).toLocal()),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'yyy',
                                  ).format(DateTime.parse(startDate).toLocal()),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('MMM').format(
                                        DateTime.parse(startDate).toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd').format(
                                        DateTime.parse(startDate).toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyy').format(
                                        DateTime.parse(startDate).toLocal(),
                                      ),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Icon(Icons.arrow_drop_down_rounded, size: 40),
                                const SizedBox(height: 1),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('MMM').format(
                                        DateTime.parse(endDate).toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd').format(
                                        DateTime.parse(endDate).toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyy').format(
                                        DateTime.parse(startDate).toLocal(),
                                      ),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
