import 'package:flutter/material.dart';

class OnlineBookingPage extends StatefulWidget {
  const OnlineBookingPage({super.key});

  @override
  State<OnlineBookingPage> createState() => _OnlineBookingPageState();
}

class _OnlineBookingPageState extends State<OnlineBookingPage> {
  // Form fields
  String usage = 'Event Meeting';
  DateTime date = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
  String block = 'Block A';
  String floor = '2';
  String room = 'A-02-05';
  String description = '';

  // Dropdown options
  final List<String> usages = ['Event Meeting', 'Lecture', 'Other'];
  final List<String> blocks = ['Block A', 'Block B', 'Block C'];
  final List<String> floors = ['1', '2', '3'];
  final List<String> rooms = ['A-02-05', 'A-02-06', 'A-02-07'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cancel and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "CANCEL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "ROOM BOOKING",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 32),

              // Usage Dropdown
              const Text(
                'WHAT IS THE USAGE?',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, // or a fixed width
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[100],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: DropdownMenu<String>(
                    initialSelection: usage,
                    onSelected: (val) => setState(() => usage = val!),
                    dropdownMenuEntries:
                        usages
                            .map(
                              (u) =>
                                  DropdownMenuEntry<String>(value: u, label: u),
                            )
                            .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Date & Time
              const Text(
                'WHEN IS THE BOOKING?',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'DATE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${date.day} ${_monthName(date.month)} ${date.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  const Text(
                    'TIME',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final pickedStart = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        final pickedEnd = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (pickedStart != null && pickedEnd != null) {
                          setState(() {
                            startTime = pickedStart;
                            endTime = pickedEnd;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Location
              const Text(
                'WHERE IS IT?',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.apartment, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'BLOCK',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: block,
                        items:
                            blocks
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(
                                      b,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => block = val!),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.layers, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'FLOOR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: floor,
                        items:
                            floors
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      f,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => floor = val!),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.meeting_room, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'ROOM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: room,
                        items:
                            rooms
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => room = val!),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Description
              const Text(
                'DESCRIPTION',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                ),
                child: TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'WRITE SOMETHING...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (val) => setState(() => description = val),
                ),
              ),
              const SizedBox(height: 32),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Handle booking logic here
                  },
                  child: const Text(
                    'BOOK THE ROOM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
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
    return '${hour}:${t.minute.toString().padLeft(2, '0')}$period';
  }
}
