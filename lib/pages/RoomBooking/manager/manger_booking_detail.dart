import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/backend/room_backend.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/RoomBooking/manager/manger_all_booking.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ManagerBookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  const ManagerBookingDetailPage({super.key, required this.booking});

  @override
  State<ManagerBookingDetailPage> createState() =>
      _ManagerBookingDetailPageState();
}

class _ManagerBookingDetailPageState extends State<ManagerBookingDetailPage> {
  final bookingService = RoomBookingService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false, // Prevents auto pop
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ManagerViewBookingPage()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            "back to booking record",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ManagerViewBookingPage()),
              );
            },
          ),
        ),
        body: FutureBuilder(
          future: bookingService.getBookingsWithId(
            widget.booking['Booking_ID'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                ),
              );
            } else if (snapshot.hasError) {
              if (snapshot.data != null) {
                return NoConnectionPage(
                  function: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ManagerBookingDetailPage(
                              booking: widget.booking,
                            ),
                      ),
                    );
                  },
                );
              }
              return Center(child: Text('error!!!!!'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('booking not exist'));
            } else {
              final bookingDetail = snapshot.data!;
              final status = bookingDetail['Status'];
              final purpose = bookingDetail['Purpose'];
              final startDate = bookingDetail['Start_date'];
              final endDate = bookingDetail['End_date'];
              final startTime = bookingDetail['start_time'];
              final endTime = bookingDetail['end_time'];
              final bookingID = bookingDetail['Booking_ID'];
              final bookingDesc = bookingDetail['Description'];
              final roomName = bookingDetail['room']['name'];
              final roomBlock = bookingDetail['room']['map']['block'] ?? '-';
              final roomFloor = bookingDetail['room']['map']['floor'] ?? '-';
              final roomCapacity = bookingDetail['room']['capacity'].toString();
              final userName = bookingDetail['user']['name'];
              final userEmail = bookingDetail['user']['email'];
              final userID = bookingDetail['user']['id'];

              Color boxColor;

              switch (status.toLowerCase()) {
                case 'pending':
                  boxColor = Colors.orangeAccent;
                  break;
                case 'approved':
                  boxColor = Colors.lightGreen;
                  break;
                case 'ongoing':
                  boxColor = Colors.lightBlueAccent;
                  break;
                case 'rejected':
                  boxColor = Colors.redAccent;
                  break;
                default:
                  boxColor = Colors.grey;
              }
              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(24),
                        width: screenWidth * 0.9,
                        decoration: AppDecorations.cardDecoration(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        purpose,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w700,
                                          color: boxColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                  if (startDate != endDate)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('MMM').format(
                                                DateTime.parse(
                                                  startDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.02,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd').format(
                                                DateTime.parse(
                                                  startDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.06,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('yyy').format(
                                                DateTime.parse(
                                                  startDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.015,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: screenWidth * 0.06),
                                        Icon(
                                          Icons.arrow_right_alt_rounded,
                                          size: 48,
                                        ),
                                        SizedBox(width: screenWidth * 0.06),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('MMM').format(
                                                DateTime.parse(
                                                  endDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.02,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd').format(
                                                DateTime.parse(
                                                  endDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.06,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('yyy').format(
                                                DateTime.parse(
                                                  endDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.015,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  if (startDate == endDate)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('dd').format(
                                            DateTime.parse(startDate).toLocal(),
                                          ),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.21,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          children: [
                                            Text(
                                              DateFormat('MMM').format(
                                                DateTime.parse(
                                                  startDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.09,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('yyy').format(
                                                DateTime.parse(
                                                  startDate,
                                                ).toLocal(),
                                              ),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.07,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: screenHeight * 0.045),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Transform.rotate(
                                        alignment: Alignment.bottomCenter,
                                        angle: -90 * 3.1416 / 180,
                                        child: Text(
                                          'Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.04,
                                            color: boxColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Start From',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize:
                                                        screenWidth * 0.022,
                                                    color: boxColor,
                                                  ),
                                                ),
                                                Text(
                                                  formatStringToTime(startTime),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize:
                                                        screenWidth * 0.05,
                                                    color: boxColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '-',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: screenWidth * 0.05,
                                                color: boxColor,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'end at',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize:
                                                        screenWidth * 0.022,
                                                    color: boxColor,
                                                  ),
                                                ),
                                                Text(
                                                  formatStringToTime(endTime),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize:
                                                        screenWidth * 0.05,
                                                    color: boxColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(24),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: boxColor.withAlpha(220),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    '-------  booking details  -------',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenHeight * 0.01,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        lableText(
                                          context,
                                          'Booking_ID',
                                          30.5,
                                          bookingID,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'Description',
                                          20,
                                          bookingDesc,
                                        ),
                                        const SizedBox(height: 30),
                                        const Text(
                                          'Location',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        lableText(
                                          context,
                                          'Room',
                                          65,
                                          roomName,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'block',
                                          61.5,
                                          roomBlock,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'floor',
                                          62.5,
                                          roomFloor,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'capacity',
                                          40,
                                          roomCapacity,
                                        ),
                                        SizedBox(height: 30),
                                        const Text(
                                          'booked by',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        lableText(
                                          context,
                                          'name',
                                          67,
                                          userName,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'email',
                                          65,
                                          userEmail,
                                        ),
                                        const SizedBox(height: 10),
                                        lableText(
                                          context,
                                          'user id',
                                          56,
                                          userID,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status != 'ended' && status != 'rejected' && status != 'ongoing')
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 32,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  isScrollControlled: true,
                                  builder:
                                      (_) =>
                                          status == 'pending'
                                              ? BookingStatusBottomSheet(
                                                onStatusSelected: (
                                                  String changeStatus,
                                                ) {
                                                  _showStatusConfirmation(
                                                    context,
                                                    changeStatus,
                                                  );
                                                },
                                              )
                                              : UpdateBookingBottomSheet(
                                                bookingID: bookingID,
                                                startTime:
                                                    parseTimeOfDayFromFullString(
                                                      startTime,
                                                    ),
                                                endTime:
                                                    parseTimeOfDayFromFullString(
                                                      endTime,
                                                    ),
                                                startDate: DateTime.parse(
                                                  startDate,
                                                ),
                                                endDate: DateTime.parse(
                                                  endDate,
                                                ),
                                                venue:
                                                    bookingDetail['room']['name'],
                                                onStatusSelected: (
                                                  newVenue,
                                                  newDateRange,
                                                  newSTime,
                                                  newETime,
                                                ) {
                                                  _showEditConfirmation(
                                                    context,
                                                    newVenue,
                                                    newDateRange,
                                                    newSTime,
                                                    newETime,
                                                  );
                                                },
                                              ),
                                );
                              },

                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                child: Text(
                                  status == 'pending'
                                      ? 'confirmation'
                                      : 'Edit Booking Detail',
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  static Row lableText(
    BuildContext context,
    String text,
    double gap,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: gap),
        Text(
          ":",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
          ),
        ),
      ],
    );
  }

  void _showSuccessMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.lightGreen,
      icon: Icons.check_circle,
      iconColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icons.cancel_rounded,
      iconColor: Colors.white,
    );
  }

  void _showStatusConfirmation(BuildContext context, String status) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          icon: Icon(Icons.bookmark_outlined),
          title: Text("${status.replaceAll("ed", "")} Booking Confimation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                "Enter your password to ${status.replaceAll("ed", "")} this booking.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Theme.of(context).colorScheme.secondary,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ), // When not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ), // When focused
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                "update",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
              onPressed:
                  () => _handleUpdateStatus(
                    context: context,
                    passwordController: passwordController,
                    managerId:
                        "434699c1-b362-4dc2-9c4d-76d52dd9b691", //! manager id here -----------------------------------------------------------------------------------------
                    bookingId: widget.booking['Booking_ID'],
                    status: status,
                  ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdateStatus({
    required BuildContext context,
    required TextEditingController passwordController,
    required String managerId,
    required String bookingId,
    required String status,
  }) async {
    final enteredPassword = passwordController.text.trim();

    // Store navigator & messenger early to use safely after unmount
    final navigator = Navigator.of(context);

    final isValid = await validateUserPassword(managerId, enteredPassword);

    navigator.pop(); // Close password dialog regardless

    if (isValid) {
      // Show loading
      if (!context.mounted) return;
      AppDecorations.showLoadingDialog(
        context,
        message: "${status.replaceAll("ed", "ing")} booking...",
      );

      final isUpdate = await bookingService.updateBookingStatus(
        bookingId,
        status,
      );

      navigator.pop(); // Close loading dialog

      if (isUpdate) {
        _showSuccessMessage(
          'Booking ${status.replaceAll("ed", "")} successfully',
        );
        setState(() {});
      } else {
        _showErrorMessage('${status.replaceAll("ed", "ing")} booking failed');
      }
    } else {
      _showErrorMessage('Invalid password');
    }
  }

  void _showEditConfirmation(
    BuildContext context,
    String venue,
    DateTimeRange dateRange,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          icon: Icon(Icons.bookmark_outlined),
          title: Text("Edit Booking Detail Confimation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                "Enter your password to edit booking detail.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Theme.of(context).colorScheme.secondary,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ), // When not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ), // When focused
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                "update",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
              onPressed:
                  () => _handleEditBooking(
                    context: context,
                    passwordController: passwordController,
                    managerId:
                        "434699c1-b362-4dc2-9c4d-76d52dd9b691", //! manager id here -----------------------------------------------------------------------------------------
                    bookingId: widget.booking['Booking_ID'],
                    newVenue: venue,
                    newDateRange: dateRange,
                    newStartTime: startTime,
                    newEndTime: endTime,
                  ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEditBooking({
    required BuildContext context,
    required TextEditingController passwordController,
    required String managerId,
    required String bookingId,
    required String newVenue,
    required DateTimeRange newDateRange,
    required TimeOfDay newStartTime,
    required TimeOfDay newEndTime,
  }) async {
    final enteredPassword = passwordController.text.trim();

    // Store navigator & messenger early to use safely after unmount
    final navigator = Navigator.of(context);

    final isValid = await validateUserPassword(managerId, enteredPassword);

    navigator.pop(); // Close password dialog regardless

    if (isValid) {
      // Show loading
      if (!context.mounted) return;
      AppDecorations.showLoadingDialog(
        context,
        message: "editting booking details...",
      );
      final startDate = DateTime(
        newDateRange.start.year,
        newDateRange.start.month,
        newDateRange.start.day,
      );
      final endDate = DateTime(
        newDateRange.end.year,
        newDateRange.end.month,
        newDateRange.end.day,
      );
      final room = await searchRoomByName(newVenue);

      final isUpdate = await bookingService.updateBookingDetail(
        bookingId,
        room?['id'],
        startDate,
        endDate,
        newStartTime,
        newEndTime,
      );

      navigator.pop(); // Close loading dialog

      if (isUpdate) {
        _showSuccessMessage('Booking Updated successfully');
        setState(() {});
      } else {
        _showErrorMessage('Fail to update booking');
      }
    } else {
      _showErrorMessage('Invalid password');
    }
  }
}

class BookingStatusBottomSheet extends StatelessWidget {
  final void Function(String) onStatusSelected;

  const BookingStatusBottomSheet({super.key, required this.onStatusSelected});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statuses = [
      {'label': 'approved', 'color': Colors.green, 'icon': Icons.check_circle},
      {'label': 'rejected', 'color': Colors.red, 'icon': Icons.cancel},
    ];

    String? selectedStatus;

    return StatefulBuilder(
      builder:
          (context, setState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Change Booking Status",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                ...statuses.map((status) {
                  final isSelected = selectedStatus == status['label'];
                  return ListTile(
                    leading: Icon(status['icon'], color: status['color']),
                    title: Text(
                      status['label'],
                      style: TextStyle(
                        color: isSelected ? status['color'] : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check, color: status['color'])
                            : null,
                    onTap: () {
                      setState(() => selectedStatus = status['label']);
                    },
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed:
                      selectedStatus == null
                          ? null
                          : () {
                            Navigator.pop(context);
                            onStatusSelected(selectedStatus!);
                          },
                  icon: const Icon(Icons.check),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class UpdateBookingBottomSheet extends StatefulWidget {
  final void Function(String, DateTimeRange, TimeOfDay, TimeOfDay)
  onStatusSelected;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String bookingID;
  final String venue;

  const UpdateBookingBottomSheet({
    super.key,
    required this.onStatusSelected,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.bookingID,
  });

  @override
  State<UpdateBookingBottomSheet> createState() =>
      _UpdateBookingBottomSheetState();
}

class _UpdateBookingBottomSheetState extends State<UpdateBookingBottomSheet> {
  late String newVenue;
  late DateTimeRange newDateRange;
  late TimeOfDay newStartTime;
  late TimeOfDay newEndTime;
  List<Map<String, dynamic>> venues = [];

  String formatDate(DateTime date) =>
      '${date.day} ${DateFormat.MMM().format(date)} ${date.year}';

  @override
  void initState() {
    super.initState();
    newVenue = widget.venue;
    newDateRange = DateTimeRange(start: widget.startDate, end: widget.endDate);
    newStartTime = widget.startTime;
    newEndTime = widget.endTime;
    loadVenues();
  }

  void loadVenues() async {
    final room = await getAllRooms();
    setState(() {
      venues = room;
      // If newVenue is empty or not in the list, set to first venue
      if (venues.isNotEmpty && !venues.any((v) => v['name'] == newVenue)) {
        newVenue = venues.first['name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Edir Booking details",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'new date time?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 28),
                  const SizedBox(width: 8),
                  Text('DATE', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 2),
                          helpText: 'CHOOSE NEW BOOKING DATE',
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogThemeData(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                colorScheme:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          secondary: Color.fromARGB(
                                            60,
                                            181,
                                            253,
                                            6,
                                          ),
                                          onSurface: Colors.white,
                                          surface:
                                              Theme.of(context).primaryColor,
                                        )
                                        : ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          onSurface: Colors.black,
                                          surface:
                                              Theme.of(context).primaryColor,
                                          secondary: Colors.grey.withAlpha(100),
                                        ),
                                textTheme: TextTheme(
                                  labelLarge:
                                      Theme.of(context).textTheme.labelSmall,
                                  titleSmall:
                                      Theme.of(context).textTheme.labelSmall,
                                  titleLarge:
                                      Theme.of(context).textTheme.headlineLarge,
                                  labelMedium:
                                      Theme.of(context).textTheme.labelSmall,
                                  bodyMedium:
                                      Theme.of(context).textTheme.bodyLarge,
                                  headlineLarge:
                                      Theme.of(context).textTheme.headlineLarge,
                                  bodyLarge:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setState(() {
                            newDateRange = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: AppDecorations.cardDecoration(context),
                        child: Text(
                          newDateRange.start == newDateRange.end
                              ? formatDate(
                                newDateRange.start,
                              ) // One day booking
                              : '${formatDate(newDateRange.start)} - ${formatDate(newDateRange.end)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 28),
                  const SizedBox(width: 8),
                  Text('TIME', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      // Start Time Picker
                      onTap: () async {
                        final pickedStart = await _showTimePicker(
                          context,
                          widget.startTime,
                        );

                        if (pickedStart != null) {
                          final pickedEnd = await _showTimePicker(
                            context,
                            widget.endTime,
                          );
                          if (pickedEnd != null) {
                            setState(() {
                              newStartTime = pickedStart;
                              newEndTime = pickedEnd;
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: AppDecorations.cardDecoration(context),
                        child: Text(
                          '${formatTimetoString(newStartTime)} - ${formatTimetoString(newEndTime)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Location
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'new location?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 28),
                  const SizedBox(width: 8),
                  Text('Venue', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showRoomSelectionDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: AppDecorations.cardDecoration(context),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                venues.isNotEmpty
                                    ? venues.firstWhere(
                                      (venue) => venue['name'] == newVenue,
                                      orElse: () => venues.first,
                                    )['name']!
                                    : 'No venue selected',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            const Icon(Icons.search),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                (newVenue != widget.venue ||
                        newDateRange !=
                            DateTimeRange(
                              start: widget.startDate,

                              end: widget.endDate,
                            ) ||
                        newStartTime != widget.startTime ||
                        newEndTime != widget.endTime)
                    ? () async {
                      final bookingService = RoomBookingService();
                      final roomResult = await searchRoomByName(newVenue);
                      if (roomResult == null) {
                        _showErrorMessage('Room is not found');
                        return;
                      }
                      final startDate = DateTime(
                        newDateRange.start.year,
                        newDateRange.start.month,
                        newDateRange.start.day,
                      );
                      final endDate = DateTime(
                        newDateRange.end.year,
                        newDateRange.end.month,
                        newDateRange.end.day,
                      );

                      // Time validator: prevent same start and end time on the same day
                      DateTime now = DateTime.now();
                      DateTime startDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        newStartTime.hour,
                        newStartTime.minute,
                      );
                      DateTime endDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        newEndTime.hour,
                        newEndTime.minute,
                      );

                      Duration difference = endDateTime.difference(
                        startDateTime,
                      );
                      if (difference.inHours > 24) {
                        _showErrorMessage(
                          "Booking duration cannot exceed 24 hours.",
                        );
                        return;
                      }

                      // Validation rules
                      if (difference.inMinutes <= 0) {
                        _showErrorMessage(
                          "Start time and end time can't be the same.",
                        );
                        return;
                      }

                      if (difference.inMinutes < 60) {
                        _showErrorMessage(
                          "Booking duration must be at least one hour.",
                        );
                        return;
                      }

                      // Check slot availability
                      if (widget.startTime != newStartTime ||
                          widget.endTime != newEndTime) {
                        final slotUnavailable = await bookingService
                            .isBookingSlotAvailableExpectThis(
                              roomId: roomResult['id'], // Use UUID for Room_ID
                              startDate: startDate,
                              endDate: endDate,
                              startTime: newStartTime,
                              endTime: newEndTime,
                              bookingId: widget.bookingID,
                            );
                        if (slotUnavailable.isNotEmpty) {
                          showUnavailableDatetime(slotUnavailable);
                          return;
                        }
                      }
                      Navigator.pop(context);
                      widget.onStatusSelected(
                        newVenue,
                        newDateRange,
                        newStartTime,
                        newEndTime,
                      );
                    }
                    : null,
            icon: const Icon(Icons.check),
            label: const Text("Confirm"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).primaryColor,
              minimumSize: const Size.fromHeight(45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icons.cancel_rounded,
      iconColor: Colors.white,
    );
  }

  void showUnavailableDatetime(List<Map<String, dynamic>> message) {
    if (!mounted) return;
    unavailableDatetime(context, message);
  }

  void unavailableDatetime(
    BuildContext context,
    List<Map<String, dynamic>> slotUnavailable,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      builder:
          (context) => SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Icon(
                      Icons.info_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selected time slot is already booked:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: slotUnavailable.length,
                    itemBuilder: (context, index) {
                      final booking = slotUnavailable[index];
                      final startDate = booking['Start_date'];
                      final endDate = booking['End_date'];
                      final startTime = formatStringToTime(
                        booking['start_time'],
                      );
                      final endTime = formatStringToTime(booking['end_time']);

                      final formattedStartTime = formatStringToTime(startTime);
                      final formattedEndTime = formatStringToTime(endTime);

                      return Text(
                        '• $startDate > $endDate  (Time: $formattedStartTime - $formattedEndTime)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please choose other time.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
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
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2,
                          vertical: 10,
                        ),
                        child: Text(
                          'Close',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  //! time picker
  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
  ) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select Time', // optional hint
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            colorScheme:
                Theme.of(context).brightness == Brightness.dark
                    ? ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.secondary,
                      onPrimary: Theme.of(context).primaryColor,
                      secondary: Theme.of(context).colorScheme.secondary,
                      onSecondary: Theme.of(context).primaryColor,
                      onSurface: Colors.white,
                      surface: Theme.of(context).primaryColor,
                    )
                    : ColorScheme.light(
                      primary: Theme.of(context).colorScheme.secondary,
                      onPrimary: Theme.of(context).primaryColor,
                      secondary: Theme.of(context).colorScheme.secondary,
                      onSecondary: Theme.of(context).primaryColor,
                      onSurface: Colors.black,
                      surface: Theme.of(context).primaryColor,
                    ),
            textTheme: TextTheme(
              titleMedium: Theme.of(context).textTheme.titleSmall,
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
              labelLarge: Theme.of(context).textTheme.labelSmall,
              bodyMedium: Theme.of(context).textTheme.labelSmall,
              bodySmall: Theme.of(context).textTheme.bodySmall,
              bodyLarge: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  //! Venue Filter
  void _showRoomSelectionDialog(BuildContext context) {
    String tempSearchQuery = '';
    String tempSelectedVenue = newVenue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Map<String, dynamic>> filteredVenues =
                venues.where((venue) {
                  if (tempSearchQuery.isEmpty) return true;
                  final name = venue['name']!.toString().toLowerCase();
                  final block = venue['map']['block'].toString().toLowerCase();
                  final floor = venue['map']['floor'].toString().toLowerCase();
                  final type = venue['type']!.toString().toLowerCase();
                  final query = tempSearchQuery.toLowerCase();

                  return name.startsWith(query) ||
                      block.startsWith(query) ||
                      floor.startsWith(query) ||
                      type.startsWith(query);
                }).toList();

            return Dialog(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minHeight: 400,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select A Venue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: AppDecorations.cardDecoration(context),
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          hintText:
                              'Search by venue name, block, floor, or type...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged:
                            (val) => setState(() => tempSearchQuery = val),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: AppDecorations.cardDecoration(context),
                        child:
                            filteredVenues.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No venues found',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: filteredVenues.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final venue = filteredVenues[index];
                                    final isSelected =
                                        tempSelectedVenue == venue['name'];

                                    return ListTile(
                                      selected: isSelected,
                                      title: Text(
                                        venue['name']!,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                      ),
                                      subtitle: Text(
                                        'Block ${venue['map']['block']} • Floor ${venue['map']['floor']} • ${venue['type']}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                      onTap: () {
                                        setState(
                                          () =>
                                              tempSelectedVenue =
                                                  venue['name']!,
                                        );
                                        this.setState(
                                          () => newVenue = venue['name']!,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
