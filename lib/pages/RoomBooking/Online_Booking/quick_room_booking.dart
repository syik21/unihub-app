import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class QuickRoomBookingPage extends StatefulWidget {
  final String roomName;
  final String roomType;
  final String roomUuid;
  const QuickRoomBookingPage({
    super.key,
    required this.roomName,
    required this.roomType,
    required this.roomUuid,
  });

  @override
  State<QuickRoomBookingPage> createState() => _QuickRoomBookingPageState();
}

class _QuickRoomBookingPageState extends State<QuickRoomBookingPage> {
  final List<String> usages = [
    'Event Meeting',
    'Lecture',
    'Lab',
    'Discussion',
    'Other',
  ];
  String? usage;
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
  String description = '';
  DateTimeRange? selectedRange;
  String formatDate(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';

  @override
  void initState() {
    super.initState();
    usage = usages[0];
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "QUICK ROOM BOOKING",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 32),
              // Room details
              Text('ROOM NAME', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: AppDecorations.cardDecoration(context),
                child: Text(
                  widget.roomName,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text('ROOM TYPE', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: AppDecorations.cardDecoration(context),
                child: Text(
                  widget.roomType,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 28),
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
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              );
                            }).toList(),
                        onChanged: (val) => setState(() => usage = val!),
                        buttonStyleData: ButtonStyleData(
                          height: 60,
                          width: constraints.maxWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: AppDecorations.cardDecoration(context),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          elevation: 4,
                          offset: const Offset(0, 4),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.black.withAlpha(25);
                              }
                              return null;
                            },
                          ),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              // Date & Time
              Text(
                'WHEN IS THE BOOKING?',
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
                          initialDateRange:
                              selectedRange ??
                              DateTimeRange(
                                start: DateTime.now(),
                                end: DateTime.now(),
                              ),
                          helpText: 'CHOOSE BOOKING DATE RANGE',
                        );
                        if (picked != null) {
                          setState(() {
                            selectedRange = picked;
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
                          selectedRange != null
                              ? selectedRange!.start == selectedRange!.end
                                  ? formatDate(selectedRange!.start)
                                  : '${formatDate(selectedRange!.start)} - ${formatDate(selectedRange!.end)}'
                              : 'SELECT DATE RANGE',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color:
                                selectedRange != null
                                    ? Theme.of(
                                      context,
                                    ).textTheme.labelMedium?.color
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 28),
                  const SizedBox(width: 8),
                  Text('TIME', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final pickedStart = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          helpText: "Select Start Time",
                        );
                        if (pickedStart != null) {
                          final pickedEnd = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                            helpText: "Select End Time",
                          );
                          if (pickedEnd != null) {
                            setState(() {
                              startTime = pickedStart;
                              endTime = pickedEnd;
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
                          '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Description
              Text(
                'DESCRIPTION',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: AppDecorations.cardDecoration(context),
                child: TextFormField(
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  style: Theme.of(context).textTheme.bodySmall,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'WRITE SOMETHING...',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      fontFamily: 'Nura',
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  onChanged: (val) => setState(() => description = val),
                ),
              ),
              const SizedBox(height: 32),
              // Book Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedRange == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                      return;
                    }
                    // Time validator: prevent same start and end time on the same day
                    if (selectedRange!.start == selectedRange!.end &&
                        startTime.hour == endTime.hour &&
                        startTime.minute == endTime.minute) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Start and end time cannot be the same on the same day.',
                          ),
                        ),
                      );
                      return;
                    }
                    final bookingService = RoomBookingService();
                    final userId = '434699c1-b362-4dc2-9c4d-76d52dd9b691';
                    final startDateTime = DateTime(
                      selectedRange!.start.year,
                      selectedRange!.start.month,
                      selectedRange!.start.day,
                      startTime.hour,
                      startTime.minute,
                    );
                    final endDateTime = DateTime(
                      selectedRange!.end.year,
                      selectedRange!.end.month,
                      selectedRange!.end.day,
                      endTime.hour,
                      endTime.minute,
                    );
                    // Check slot availability
                    final slotUnavailable = await bookingService
                        .isBookingSlotAvailable(
                          roomId: widget.roomUuid,
                          startDate: startDateTime,
                          endDate: endDateTime,
                          startTime: startTime,
                          endTime: endTime,
                        );
                    if (!mounted) return;
                    if (slotUnavailable.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selected time slot is already booked'),
                        ),
                      );
                      return;
                    }
                    try {
                      await bookingService.createBooking(
                        userId: userId,
                        roomId: widget.roomUuid,
                        startDate: startDateTime,
                        endDate: endDateTime,
                        purpose: usage!,
                        description: description,
                        startTime:
                            startTime, //! do we need this? -----------------------------------------------------------------------------------------------------------
                        endTime: endTime,
                      );
                      await Supabase.instance.client
                          .from('room')
                          .update({'status': 'reserved'})
                          .eq('id', widget.roomUuid);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Booking request submitted successfully',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating booking: $e')),
                      );
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

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${t.minute.toString().padLeft(2, '0')}$period';
  }
}
