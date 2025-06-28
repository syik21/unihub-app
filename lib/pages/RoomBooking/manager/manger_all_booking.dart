import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/RoomBooking/manager/manger_booking_detail.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/main.dart';

class ManagerViewBookingPage extends StatefulWidget {
  const ManagerViewBookingPage({super.key});

  @override
  State<ManagerViewBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<ManagerViewBookingPage>
    with RouteAware {
  final bookingService = RoomBookingService();
  List<Map<String, dynamic>>? allbooking = [];
  List<Map<String, dynamic>>? filteredBookings = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController bookingIdController = TextEditingController();
  TextEditingController userController = TextEditingController();
  bool isLoading = true;
  bool isConnected = true;
  late FocusNode searchFocusNode;

  @override
  void initState() {
    super.initState();
    loadBooking();
    checkingconnection();
    searchController.clear();
    searchFocusNode = FocusNode();
  }

  @override
  void didPopNext() {
    // Called when returning back to this page
    searchFocusNode.unfocus(); // <-- This will unfocus the TextField
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    bookingIdController.dispose();
    userController.dispose();
    super.dispose();
  }

  DateTime? selectedDate;
  Set<String> selectedStatuses = {};
  String searchBookingId = '';
  String searchUserId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body:
          isConnected
              ? RefreshIndicator(
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await loadBooking();
                  await checkingConnect();
                  filterCombinedBooking(
                    query: searchController.text,
                    selectedStatuses: selectedStatuses,
                    selectedDate: selectedDate,
                    bookingIdQuery: searchBookingId,
                    userQuery: searchUserId,
                  );
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Booking Requests',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                focusNode: searchFocusNode,
                                onChanged: (value) {
                                  filterCombinedBooking(
                                    query: value,
                                    selectedStatuses: selectedStatuses,
                                    selectedDate: selectedDate,
                                    bookingIdQuery: searchBookingId,
                                    userQuery: searchUserId,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                          spacing:
                              20, // horizontal spacing between status items
                          runSpacing: 8, // vertical spacing when wrapped
                          children: [
                            _buildStatusChip('pending', Colors.orange),
                            _buildStatusChip('approved', Colors.lightGreen),
                            _buildStatusChip('ongoing', Colors.lightBlue),
                            _buildStatusChip('rejected', Colors.redAccent),
                            _buildStatusChip('ended', Colors.grey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'result: ${filteredBookings?.length}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                ? const Center(
                                  child: Text("No complaints found"),
                                )
                                : ListView.builder(
                                  itemCount: filteredBookings?.length,
                                  itemBuilder: (context, index) {
                                    final bookingDetail =
                                        filteredBookings![index];
                                    final title = bookingDetail['Purpose'];
                                    final status = bookingDetail['Status'];
                                    final startDate =
                                        bookingDetail['Start_date'];
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

                                    final username =
                                        bookingDetail['user']['name'];
                                    return BookingTile(
                                      title: title,
                                      status: status,
                                      startDate: startDate,
                                      endDate: endDate,
                                      startTime: startTime,
                                      endTime: endTime,
                                      location: location,
                                      block: block,
                                      floor: floor,
                                      username: username,
                                      booking: bookingDetail,
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              )
              : NoConnectionPage(
                function: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => ManagerViewBookingPage()),
                  );
                },
              ),
    );
  }

  Future<void> loadBooking() async {
    try {
      final result = await bookingService.getAllUserBookings();
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

  Future<void> checkingConnect() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  void filterCombinedBooking({
    String query = '',
    Set<String> selectedStatuses = const {},
    DateTime? selectedDate,
    String bookingIdQuery = '',
    String userQuery = '',
  }) {
    final q = query.toLowerCase();
    final uid = bookingIdQuery.toLowerCase();
    final userUid = userQuery.toLowerCase();

    setState(() {
      filteredBookings =
          allbooking?.where((booking) {
            // Prepare data
            final status = booking['Status']?.toString().toLowerCase() ?? '';
            final type = booking['Purpose']?.toString().toLowerCase() ?? '';
            final room =
                booking['room']?['name']?.toString().toLowerCase() ?? '';
            final bookingId =
                booking['Booking_ID']?.toString().toLowerCase() ?? '';
            final username =
                booking['user']?['name'].toString().toLowerCase() ?? '';

            final startStr = booking['Start_date'];
            final endStr = booking['End_date'];
            DateTime? startDate, endDate;

            try {
              startDate = DateTime.parse(startStr).toLocal();
              endDate = DateTime.parse(endStr).toLocal();
            } catch (_) {}

            // Filter rules
            final matchesQuery = type.startsWith(q) || room.startsWith(q);
            final matchesStatus =
                selectedStatuses.isEmpty || selectedStatuses.contains(status);
            final matchesDate =
                selectedDate == null ||
                (startDate != null &&
                    endDate != null &&
                    !selectedDate.isBefore(startDate) &&
                    !selectedDate.isAfter(endDate));
            final matchesBookingId = uid.isEmpty || bookingId.startsWith(uid);
            final matchesUserId =
                username.isEmpty || username.startsWith(userUid);

            return matchesQuery &&
                matchesStatus &&
                matchesDate &&
                matchesBookingId &&
                matchesUserId;
          }).toList();
    });
  }

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
                        '-- Filter --',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Username:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48, // Set a consistent height for alignment
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:
                            Theme.of(context).brightness == Brightness.light
                                ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                                : [],
                      ),
                      alignment:
                          Alignment
                              .center, // Ensures child content is centered vertically
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.tertiary,
                        controller: userController,
                        onChanged: (value) {
                          setState(() {
                            searchUserId = value.trim();
                          });
                          userController.text = searchUserId;
                        },
                        style: Theme.of(context).textTheme.labelSmall,
                        decoration: InputDecoration(
                          hintText: 'Enter username...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          isCollapsed:
                              true, // Keeps padding tighter and centered
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical:
                                14, // Adjust this for better vertical alignment
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Booking ID:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48, // Set a consistent height for alignment
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:
                            Theme.of(context).brightness == Brightness.light
                                ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                                : [],
                      ),
                      alignment:
                          Alignment
                              .center, // Ensures child content is centered vertically
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.tertiary,
                        controller: bookingIdController,
                        onChanged: (value) {
                          setState(() {
                            searchBookingId = value.trim();
                          });
                          bookingIdController.text = searchBookingId;
                        },
                        style: Theme.of(context).textTheme.labelSmall,
                        decoration: InputDecoration(
                          hintText: 'Enter a booking ID...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          isCollapsed:
                              true, // Keeps padding tighter and centered
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical:
                                14, // Adjust this for better vertical alignment
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

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
                                vertical: 20,
                              ),
                              decoration: AppDecorations.cardDecoration(
                                context,
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
                          filterCombinedBooking(
                            query: searchController.text,
                            selectedStatuses: selectedStatuses,
                            selectedDate: selectedDate,
                            bookingIdQuery: searchBookingId,
                            userQuery: searchUserId,
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
                          searchBookingId = '';
                          searchUserId = '';
                          setState(() {
                            bookingIdController.text = '';
                            userController.text = '';
                          });
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
      filterCombinedBooking(
        query: searchController.text,
        selectedStatuses: selectedStatuses,
        selectedDate: selectedDate,
        bookingIdQuery: searchBookingId,
        userQuery: searchUserId,
      );
    });
  }

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = selectedStatuses.contains(label);

    return ChoiceChip(
      checkmarkColor: Colors.white,
      label: Text(
        label, // Capitalize
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withAlpha(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (selected) {
        setState(() {
          selected
              ? selectedStatuses.add(label)
              : selectedStatuses.remove(label);
          filterCombinedBooking(
            query: searchController.text,
            selectedStatuses: selectedStatuses,
            selectedDate: selectedDate,
            bookingIdQuery: searchBookingId,
            userQuery: searchUserId,
          );
        });
      },
    );
  }
}

class BookingTile extends StatefulWidget {
  final String title;
  final String status;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String location;
  final String block;
  final String floor;
  final String username;
  final Map<String, dynamic> booking;

  const BookingTile({
    super.key,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.block,
    required this.floor,
    required this.username,
    required this.booking,
  });

  @override
  State<BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends State<BookingTile>
    with TickerProviderStateMixin {
  bool expanded = false;

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.lightGreen;
      case 'ongoing':
        return Colors.lightBlue;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr).toLocal();
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main info row
            Row(
              children: [
                // Date
                Column(
                  children: [
                    Text(
                      formatDate(widget.startDate),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    if (widget.startDate != widget.endDate) ...[
                      const Icon(Icons.arrow_drop_down_rounded, size: 32),
                      Text(
                        formatDate(widget.endDate),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 24),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.startTime} - ${widget.endTime}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.location} (Block ${widget.block}, Floor ${widget.floor})',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(widget.status).withAlpha(30),
                    border: Border.all(color: getStatusColor(widget.status)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                      color: getStatusColor(widget.status),
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ),

                // Expand toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      expanded ? 'Hide details' : 'Show details',
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.blue
                                : Color(0xFFB5FD06),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.blue
                              : Color(0xFFB5FD06),
                    ),
                  ],
                ),
              ],
            ),

            // Details Section
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  expanded
                      ? Column(
                        children: [
                          const Divider(height: 40),
                          detailRow(
                            'Booking ID: ',
                            widget.booking['Booking_ID'],
                          ),
                          detailRow('Booked By: ', widget.username),
                          detailRow(
                            'Description: ',
                            widget.booking['Description'],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                      )
                                      : ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFB5FD06),
                                        foregroundColor: Color(0xFF14141E),
                                      ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ManagerBookingDetailPage(
                                          booking: widget.booking,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_right_rounded,
                                size: 30,
                              ),
                              label: Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  fontWeight:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: MediaQuery.of(context).size.width * 0.025,
            ),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width * 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
