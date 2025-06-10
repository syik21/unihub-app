import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class OnlineBookingPage extends StatefulWidget {
  const OnlineBookingPage({super.key});

  @override
  State<OnlineBookingPage> createState() => _OnlineBookingPageState();
}

class _OnlineBookingPageState extends State<OnlineBookingPage> {
  // Form fields

  // Dropdown options
  final List<String> usages = ['Event Meeting', 'Lecture', 'Other'];

  String? usage;
  DateTime date = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
  String description = '';
  DateTimeRange? selectedRange;
  String formatDate(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';
  String selectedVenue = '';

  final List<Map<String, String>> venues = [
    {
      'name': 'A-02-01',
      'block': 'Block A',
      'floor': '2',
      'type': 'Conference Room',
    },
    {
      'name': 'A-02-02',
      'block': 'Block A',
      'floor': '2',
      'type': 'Meeting Room',
    },
    {
      'name': 'Lecture Hall C',
      'block': 'Block A',
      'floor': '2',
      'type': 'Lecture Hall',
    },
    {
      'name': 'B-01-03',
      'block': 'Block B',
      'floor': '1',
      'type': 'Seminar Room',
    },
    {
      'name': 'B-01-07',
      'block': 'Block B',
      'floor': '1',
      'type': 'Discussion Room',
    },
    {
      'name': 'C-03-01',
      'block': 'Block C',
      'floor': '3',
      'type': 'Training Room',
    },
  ];

  @override
  void initState() {
    super.initState();
    usage = usages[0]; // ✅ Safe here
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
                            color: Theme.of(context).colorScheme.secondary,
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
                            Icons.expand_more,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          iconSize: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              //! Date & Time
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
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogTheme(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                colorScheme:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          onPrimary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
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
                                              ).colorScheme.primary,
                                        )
                                        : ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          onPrimary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onSurface: Colors.black,
                                          surface:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
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
                                  ? formatDate(selectedRange!.start) // One day booking
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
                      // Start Time Picker
                      onTap: () async {
                        final pickedStart = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          helpText: "Select Start Time",
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogTheme(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                colorScheme:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          onPrimary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          onSecondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onSurface: Colors.white,
                                          surface:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        )
                                        : ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                          onSecondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onPrimary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onSurface: Colors.black,
                                          surface:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                textTheme: TextTheme(
                                  titleMedium:
                                      Theme.of(context).textTheme.titleSmall,
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
                                      Theme.of(context).textTheme.labelSmall,
                                  bodyMedium:
                                      Theme.of(context).textTheme.labelSmall,
                                  bodySmall:
                                      Theme.of(context).textTheme.bodySmall,
                                  bodyLarge:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                                // You can also customize shape, button text, etc.
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedStart != null) {
                          final pickedEnd = await showTimePicker(
                            // End Time Picker
                            context: context,
                            initialTime: endTime,
                            helpText: "Select End Time",
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogTheme: DialogTheme(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ), // Background color
                                  colorScheme:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? ColorScheme.dark(
                                            primary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                            onPrimary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            secondary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                            onSecondary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            onSurface: Colors.white,
                                            surface:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          )
                                          : ColorScheme.light(
                                            primary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                            onPrimary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            secondary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                            onSecondary:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            onSurface: Colors.black,
                                            surface:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                  textTheme: TextTheme(
                                    titleMedium:
                                        Theme.of(context).textTheme.titleSmall,
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
                                        Theme.of(context).textTheme.labelSmall,
                                    bodyMedium:
                                        Theme.of(context).textTheme.labelSmall,
                                    bodySmall:
                                        Theme.of(context).textTheme.bodySmall,
                                    bodyLarge:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  // You can also customize shape, button text, etc.
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedEnd != null) {
                            //! REMEMBER TO VALIDATE THE TIME (EXAMPLE: 5pm-5pm, 5pm-5am is invalid)
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

              // Location
              Text(
                'WHERE IS IT?',
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
                      onTap: () => _showRoomSelectionDialog(context),
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
                                selectedVenue.isNotEmpty
                                    ? venues.firstWhere(
                                      (venue) => venue['name'] == selectedVenue,
                                    )['name']!
                                    : 'Select a room...',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color:
                                      selectedVenue.isEmpty
                                          ? Colors.grey
                                          : Theme.of(
                                            context,
                                          ).textTheme.labelMedium?.color,
                                ),
                              ),
                            ),
                            const Icon(Icons.expand_more),
                          ],
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
                  cursorColor: Theme.of(context).colorScheme.tertiary,
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
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    //! Handle booking logic here
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

  //! Venue Filter
  void _showRoomSelectionDialog(BuildContext context) {
    String tempSearchQuery = '';
    String tempSelectedVenue = selectedVenue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Map<String, String>> filteredVenues =
                venues.where((venue) {
                  if (tempSearchQuery.isEmpty) return true;
                  final name = venue['name']!.toLowerCase();
                  final block = venue['block']!.toLowerCase();
                  final floor = venue['floor']!.toLowerCase();
                  final type = venue['type']!.toLowerCase();
                  final query = tempSearchQuery.toLowerCase();

                  return name.startsWith(query) ||
                      block.startsWith(query) ||
                      floor.startsWith(query) ||
                      type.startsWith(query);
                }).toList();

            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.primary,
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
                        cursorColor: Theme.of(context).colorScheme.tertiary,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                                        '${venue['block']} • Floor ${venue['floor']} • ${venue['type']}',
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
