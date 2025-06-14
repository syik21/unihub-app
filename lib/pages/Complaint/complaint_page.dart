import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  // Form fields

  // Dropdown options
  final List<String> usages = ['Broken Asset', 'Leakage', 'Other'];

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
                  "report an issue",
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
                            const Icon(Icons.search),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Scan Barcode
              Text(
                'enter or SCAN THE ASSET BARCODE',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Barcode Icon and Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 28,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "code",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Barcode TextField
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 20,
                      ),
                      decoration: AppDecorations.cardDecoration(context),
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        //controller: barcodeController,
                        style: Theme.of(context).textTheme.labelMedium,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'asset code...',
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Scan Button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed:
                          () {}, // Todo - open the sacnner to scan the code
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        elevation: 4,
                      ),
                      child: Text(
                        "SCAN",
                        style: TextStyle(
                          fontFamily: 'Nura',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 1.1,
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
              const SizedBox(height: 28),

              Text('Attachment', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap:
                    () {}, // Todo - make a function to attach an image from device
                child: Container(
                  padding: EdgeInsets.all(30),
                  width: double.infinity,
                  decoration: AppDecorations.cardDecoration(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "UPLOAD AN IMAGE",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Nura',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                  onPressed: () {
                    //! Handle sumbit issues logic here
                  },
                  child: Text(
                    'submit issue',
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
