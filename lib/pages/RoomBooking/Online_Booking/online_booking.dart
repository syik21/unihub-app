import 'package:flutter/material.dart';
import 'package:unihub/backend/room_backend.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/other/successful_page.dart';
import 'package:unihub/pages/RoomBooking/my_booking_page.dart';
import 'package:unihub/pages/RoomBooking/view_booking_detail_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:unihub/backend/function.dart';

class OnlineBookingPage extends StatefulWidget {
  const OnlineBookingPage({super.key});

  @override
  State<OnlineBookingPage> createState() => _OnlineBookingPageState();
}

class _OnlineBookingPageState extends State<OnlineBookingPage> {
  // Form fields

  // Dropdown options
  final List<String> usages = [
    'meeting',
    'event purpose',
    'lecture',
    'lab',
    'discussion',
    'other',
  ];

  String? usage;
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
  String description = '';
  DateTimeRange? selectedRange;
  String formatDate(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';
  String selectedVenue = '';

  List<Map<String, dynamic>> venues = [];

  final TextEditingController desController = TextEditingController();

  bool _desEmpty = false;
  bool _dateEmpty = false;
  bool _venueEmpty = false;
  bool _timeInvalid = false;

  bool _isSubmitting = false;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    usage = usages[0];
    checkingconnection();
    loadVenues();
  }

  void loadVenues() async {
    final room = await getAllRooms();
    setState(() {
      venues = room;
    });
  }

  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  Future<void> checkingFutureConnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Cancel", style: Theme.of(context).textTheme.titleSmall),
      ),
      body:
          isConnected
              ? SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "ROOM BOOKING",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Usage Dropdown
                      Text(
                        'WHAT IS THE USAGE?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                value: usage,
                                items:
                                    usages.map((u) {
                                      return DropdownMenuItem<String>(
                                        value: u,
                                        child: Text(
                                          u,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (val) => setState(() => usage = val!),
                                buttonStyleData: ButtonStyleData(
                                  height: 60,
                                  width: constraints.maxWidth,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: AppDecorations.cardDecoration(
                                    context,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.shadow,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  elevation: 4,
                                  offset: const Offset(0, 4),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  overlayColor: WidgetStateProperty.resolveWith<
                                    Color?
                                  >((Set<WidgetState> states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.black.withValues(
                                        alpha: 0.1,
                                      ); // Highlight hovered item background
                                    }
                                    return null; // Default background for other states
                                  }),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      //! Date & Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WHEN IS THE BOOKING?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'DATE',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(
                                        DateTime.now().year + 2,
                                      ),
                                      initialDateRange:
                                          selectedRange ??
                                          DateTimeRange(
                                            start: DateTime.now(),
                                            end: DateTime.now(),
                                          ),
                                      helpText: 'CHOOSE BOOKING DATE RANGE',
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            dialogTheme: DialogThemeData(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            colorScheme:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? ColorScheme.dark(
                                                      primary:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                      onPrimary:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                      secondary: Color.fromARGB(
                                                        60,
                                                        181,
                                                        253,
                                                        6,
                                                      ),
                                                      onSurface: Colors.white,
                                                      surface:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                    )
                                                    : ColorScheme.light(
                                                      primary:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                      onPrimary:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                      onSurface: Colors.black,
                                                      surface:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                      secondary: Colors.grey
                                                          .withAlpha(100),
                                                    ),
                                            textTheme: TextTheme(
                                              labelLarge:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall,
                                              titleSmall:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall,
                                              titleLarge:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.headlineLarge,
                                              labelMedium:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall,
                                              bodyMedium:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge,
                                              headlineLarge:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.headlineLarge,
                                              bodyLarge:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (picked != null) {
                                      setState(() {
                                        selectedRange = picked;
                                      });
                                    }
                                    validateDate();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: AppDecorations.cardDecoration(
                                      context,
                                    ).copyWith(
                                      color:
                                          _dateEmpty
                                              ? Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.red[100]
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      border: Border.all(
                                        color:
                                            _dateEmpty
                                                ? Colors.red.withAlpha(100)
                                                : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      selectedRange != null
                                          ? selectedRange!.start ==
                                                  selectedRange!.end
                                              ? formatDate(
                                                selectedRange!.start,
                                              ) // One day booking
                                              : '${formatDate(selectedRange!.start)} - ${formatDate(selectedRange!.end)}' // Multiple days
                                          : 'SELECT DATE RANGE',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
                                        color:
                                            selectedRange != null
                                                ? Theme.of(
                                                  context,
                                                ).textTheme.labelMedium?.color
                                                : _dateEmpty
                                                ? Colors.red[300]
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_dateEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 3,
                                left: 100,
                                bottom: 5,
                              ),
                              child: Text(
                                'Please select a date range',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontFamily: "Nura",
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'TIME',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  // Start Time Picker
                                  onTap: () async {
                                    final pickedStart = await _showTimePicker(
                                      context,
                                      startTime,
                                    );

                                    if (pickedStart != null) {
                                      final pickedEnd = await _showTimePicker(
                                        context,
                                        endTime,
                                      );
                                      if (pickedEnd != null) {
                                        setState(() {
                                          startTime = pickedStart;
                                          endTime = pickedEnd;
                                        });
                                      }
                                    }
                                    setState(() {
                                      _timeInvalid = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: AppDecorations.cardDecoration(
                                      context,
                                    ).copyWith(
                                      color:
                                          _timeInvalid
                                              ? Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.red[100]
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      border: Border.all(
                                        color:
                                            _timeInvalid
                                                ? Colors.red.withAlpha(100)
                                                : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      '${formatTimetoString(startTime)} - ${formatTimetoString(endTime)}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_timeInvalid)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 3,
                                left: 100,
                                bottom: 5,
                              ),
                              child: Text(
                                'This session has been booked.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontFamily: "Nura",
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WHERE IS IT?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Venue',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _showRoomSelectionDialog(context);
                                    setState(() {
                                      _venueEmpty = false;
                                    });
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: AppDecorations.cardDecoration(
                                      context,
                                    ).copyWith(
                                      color:
                                          _venueEmpty
                                              ? Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.red[100]
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      border: Border.all(
                                        color:
                                            _venueEmpty
                                                ? Colors.red.withAlpha(100)
                                                : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedVenue.isNotEmpty
                                                ? venues.firstWhere(
                                                  (venue) =>
                                                      venue['name'] ==
                                                      selectedVenue,
                                                )['name']!
                                                : 'Select a room...',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium?.copyWith(
                                              color:
                                                  selectedVenue.isEmpty
                                                      ? _venueEmpty
                                                          ? Colors.red[300]
                                                          : Colors.grey
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .labelMedium
                                                          ?.color,
                                            ),
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
                          if (_venueEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3, left: 110),
                              child: Text(
                                'Please select a venue',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontFamily: "Nura",
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESCRIPTION',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: AppDecorations.cardDecoration(
                              context,
                            ).copyWith(
                              color:
                                  _desEmpty
                                      ? Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.red[100]
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary
                                      : Theme.of(context).colorScheme.primary,
                              border: Border.all(
                                color:
                                    _desEmpty
                                        ? Colors.red.withAlpha(100)
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              enableInteractiveSelection: true,
                              controller: desController,
                              onChanged: (val) {
                                validateDes();
                                setState(() {
                                  description = val;
                                });
                              },
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              style: Theme.of(context).textTheme.bodySmall,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'WRITE SOMETHING...',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  fontFamily: 'Nura',
                                  color:
                                      _desEmpty ? Colors.red[300] : Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                          if (_desEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3, left: 5),
                              child: Text(
                                'Please describe the purpose',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontFamily: "Nura",
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await checkingFutureConnection();
                            if (_isSubmitting) {
                              return;
                            } // 🔒 Prevent double submit
                            setState(() {
                              _isSubmitting = true;
                            });
                            if (!isConnected) {
                              showErrorMessage(
                                'NO Internet. Please check your connection.',
                              );
                              return;
                            }

                            try {
                              validateDate();
                              validateVenue();
                              validateDes();
                              if (_dateEmpty ||
                                  _venueEmpty ||
                                  _desEmpty ||
                                  _timeInvalid) {
                                showErrorMessage(
                                  'Please fill in all the details. Thank you!',
                                );
                                return;
                              }

                              final bookingService = RoomBookingService();
                              //! Use permanent user ID for development -------------------------------------------------------------------------------------------------------
                              final userId =
                                  '434699c1-b362-4dc2-9c4d-76d52dd9b691';

                              final roomResult = await searchRoomByName(
                                selectedVenue,
                              );
                              if (!_venueEmpty && roomResult == null) {
                                showErrorMessage('Room is not found');
                                return;
                              }

                              /*  //! Validate room
                    final roomAvailable = await bookingService.isRoomAvailable(
                      selectedVenue,
                    );
                    if (!roomAvailable) {
                      showErrorMessage('Selected room is not available');
                      return;
                    }*/

                              if (selectedRange == null) {
                                showErrorMessage('Please select a date range');
                                return;
                              }
                              // Compose start and end DateTime
                              final startDate = DateTime(
                                selectedRange!.start.year,
                                selectedRange!.start.month,
                                selectedRange!.start.day,
                              );
                              final endDate = DateTime(
                                selectedRange!.end.year,
                                selectedRange!.end.month,
                                selectedRange!.end.day,
                              );

                              // Time validator: prevent same start and end time on the same day
                              DateTime now = DateTime.now();
                              DateTime startDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                startTime.hour,
                                startTime.minute,
                              );
                              DateTime endDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                endTime.hour,
                                endTime.minute,
                              );

                              Duration difference = endDateTime.difference(
                                startDateTime,
                              );

                              // Validate
                              if (difference.inMinutes <= 0) {
                                showErrorMessage(
                                  "start time and end time can't be the same.",
                                );
                                setState(() {
                                  _timeInvalid = true;
                                });
                                return;
                              }

                              if (difference.inMinutes < 60) {
                                showErrorMessage(
                                  'Booking duration must be at least one hour.',
                                );
                                setState(() {
                                  _timeInvalid = true;
                                });
                                return;
                              }
                              if (difference.inHours > 24) {
                                showErrorMessage(
                                  "Booking duration cannot exceed 24 hours.",
                                );
                                setState(() {
                                  _timeInvalid = true;
                                });
                                return;
                              }

                              // Check slot availability
                              final slotUnavailable = await bookingService
                                  .isBookingSlotAvailable(
                                    roomId:
                                        roomResult?['id'], // Use UUID for Room_ID
                                    startDate: startDate,
                                    endDate: endDate,
                                    startTime: startTime,
                                    endTime: endTime,
                                  );
                              if (slotUnavailable.isNotEmpty) {
                                showUnavailableDatetime(slotUnavailable);
                                return;
                              }

                              // Create booking
                              if (!_dateEmpty &&
                                  !_venueEmpty &&
                                  !_desEmpty &&
                                  !_timeInvalid &&
                                  slotUnavailable.isEmpty) {
                                try {
                                  final isBookingSuccess = await bookingService
                                      .createBooking(
                                        userId: userId,
                                        roomId:
                                            roomResult?['id'], // Use UUID for Room_ID
                                        startDate: startDate,
                                        endDate: endDate,
                                        purpose: usage!,
                                        description: description,
                                        startTime: startTime,
                                        endTime: endTime,
                                      );

                                  if (isBookingSuccess != {}) {
                                    /* //! Update room status to 'reserved'
                          await Supabase.instance.client
                              .from('room')
                              .update({'status': 'reserved'})
                              .eq('id', roomUuid);
                              */
                                    handleSuccessNavigation(isBookingSuccess);
                                  }
                                } catch (e) {
                                  showErrorMessage(
                                    'Error creating booking: $e',
                                  );
                                }
                              } else {
                                showErrorMessage(
                                  'Please fill in all the details. Thank you!',
                                );
                              }
                            } catch (e) {
                              showErrorMessage(
                                'An error occurred. Please try again. $e',
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              } // ✅ Re-enable
                            }
                          },
                          child: Text(
                            'BOOK THE ROOM',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : NoConnectionPage(
                function: () {
                  checkingconnection();
                },
              ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[month];
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    AppDecorations.showCustomBottomSheet(context, message);
  }

  bool validateEmpthy(TextEditingController controller) {
    final input = controller.text.trim();
    return input.isEmpty;
  }

  void validateDes() {
    final error = validateEmpthy(desController);
    setState(() {
      _desEmpty = error;
    });
  }

  void validateDate() {
    final error = selectedRange == null;
    setState(() {
      _dateEmpty = error;
    });
  }

  void validateVenue() {
    final error = selectedVenue.isEmpty;
    setState(() {
      _venueEmpty = error;
    });
  }

  void showUnavailableDatetime(List<Map<String, dynamic>> message) {
    if (!mounted) return;
    unavailableDatetime(context, message);
    setState(() {
      _timeInvalid = true;
    });
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

  void handleSuccessNavigation(Map<String, dynamic> bookingDetail) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => SuccessfulPage(
              title: 'Booked Successfully!',
              description:
                  "We've received your booking and will review it shortly. Please wait for our confirmation.",
              buttonText: 'view booking',
              page: ViewBookingDetailPage(
                booking: bookingDetail,
                page: MyBookingPage(),
              ),
              //animationAsset: 'assets/success.json', // your Lottie file path
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
    String tempSelectedVenue = selectedVenue;

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
                                          () => selectedVenue = venue['name']!,
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
