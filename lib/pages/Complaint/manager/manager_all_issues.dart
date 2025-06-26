import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/Complaint/manager/manager_issue_detail.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ManagerViewAllComplaintPage extends StatefulWidget {
  const ManagerViewAllComplaintPage({super.key});

  @override
  State<ManagerViewAllComplaintPage> createState() =>
      _UserViewAllComplaintPageState();
}

class _UserViewAllComplaintPageState
    extends State<ManagerViewAllComplaintPage> {
  List<Map<String, dynamic>>? allComplaints = [];
  List<Map<String, dynamic>>? filteredComplaints = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController complaintIdController = TextEditingController();
  TextEditingController userController = TextEditingController();
  bool isLoading = true;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    loadComplaints();
    checkingconnection();
  }

  DateTime? selectedDate;
  Set<String> selectedStatuses = {};
  String searchComplaintId = '';
  String searchUser = '';

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
                  await loadComplaints();
                  await checkingConnect();
                  filterComplaintDetail(
                    query: searchController.text,
                    selectedStatuses: selectedStatuses,
                    selectedDate: selectedDate,
                    complaintIdQuery: searchComplaintId,
                    userQuery: searchUser,
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
                          'Facility Issues',
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
                                onChanged: (val) {
                                  filterComplaintDetail(
                                    query: val,
                                    selectedStatuses: selectedStatuses,
                                    selectedDate: selectedDate,
                                    complaintIdQuery: searchComplaintId,
                                    userQuery: searchUser,
                                  );
                                },
                                cursorColor:
                                    Theme.of(context).colorScheme.secondary,
                                decoration: InputDecoration(
                                  hintText: 'SEARCH A complaint',
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
                            _buildStatusChip('solved', Colors.lightGreen),
                            _buildStatusChip('invalid', Colors.redAccent),
                            _buildStatusChip('ongoing', Colors.lightBlue),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'result: ${filteredComplaints?.length}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                : filteredComplaints!.isEmpty
                                ? const Center(
                                  child: Text("No complaints found"),
                                )
                                : ListView.builder(
                                  itemCount: filteredComplaints?.length,
                                  itemBuilder: (context, index) {
                                    final complaint =
                                        filteredComplaints![index];
                                    final title = complaint['type'];
                                    final status = complaint['status'];
                                    final location = complaint['room']['name'];
                                    final date = formatTimestamp(
                                      complaint['receive_date'],
                                    );
                                    return buildComplaintTile(
                                      context,
                                      title,
                                      status,
                                      location,
                                      date,
                                      complaint,
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
                    MaterialPageRoute(
                      builder: (_) => ManagerViewAllComplaintPage(),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> loadComplaints() async {
    try {
      final result = await getAllComplaint();
      if (mounted) {
        setState(() {
          allComplaints = result;
          filteredComplaints = result;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('error: $e');
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

  void filterComplaintDetail({
    String query = '',
    Set<String> selectedStatuses = const {},
    DateTime? selectedDate,
    String complaintIdQuery = '',
    String userQuery = '',
  }) {
    final q = query.toLowerCase();
    final cid = complaintIdQuery.toLowerCase();
    final uName = userQuery.toLowerCase();

    setState(() {
      filteredComplaints =
          allComplaints?.where((complaint) {
            final type = complaint['type']?.toString().toLowerCase() ?? '';
            final status = complaint['status']?.toString().toLowerCase() ?? '';
            final room =
                complaint['room']?['name']?.toString().toLowerCase() ?? '';
            final dateStr = complaint['receive_date'];
            final complaintId = complaint['id']?.toString().toLowerCase() ?? '';
            final username =
                complaint['user']?['name']?.toString().toLowerCase() ?? '';
            // Parse date
            DateTime? complaintDate;
            try {
              complaintDate = DateTime.parse(dateStr).toLocal();
            } catch (_) {}

            // Conditions
            final matchesQuery =
                type.startsWith(q) ||
                room.startsWith(q) ||
                status.startsWith(q);
            final matchesStatus =
                selectedStatuses.isEmpty || selectedStatuses.contains(status);
            final matchesDate =
                selectedDate == null ||
                (complaintDate != null &&
                    complaintDate.year == selectedDate.year &&
                    complaintDate.month == selectedDate.month &&
                    complaintDate.day == selectedDate.day);
            final matchesComplaintId =
                cid.isEmpty || complaintId.startsWith(cid);
            final matchesUser = uName.isEmpty || username.startsWith(uName);

            return matchesQuery &&
                matchesStatus &&
                matchesDate &&
                matchesComplaintId &&
                matchesUser;
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
                        '- Filter -',
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
                            searchUser = value.trim();
                          });
                          userController.text = searchUser;
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
                      'Complaint ID:',
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
                        controller: complaintIdController,
                        onChanged: (value) {
                          setState(() {
                            searchComplaintId = value.trim();
                          });
                          complaintIdController.text = searchComplaintId;
                        },
                        style: Theme.of(context).textTheme.labelSmall,
                        decoration: InputDecoration(
                          hintText: 'Enter a complaint ID...',
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

                    // 📅 Date Picker
                    Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 10),
                        const Text(
                          'Date Reported:',
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
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
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
                            complaintIdQuery: searchComplaintId,
                            userQuery: searchUser,
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
                          searchComplaintId = '';
                          searchUser = '';
                          setState(() {
                            complaintIdController.text = '';
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
      filterComplaintDetail(
        query: searchController.text,
        selectedStatuses: selectedStatuses,
        selectedDate: selectedDate,
        complaintIdQuery: searchComplaintId,
        userQuery: searchUser,
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
          filterComplaintDetail(
            query: searchController.text,
            selectedStatuses: selectedStatuses,
            selectedDate: selectedDate,
            complaintIdQuery: searchComplaintId,
            userQuery: searchUser,
          );
        });
      },
    );
  }
}

Widget buildComplaintTile(
  BuildContext context,
  String title,
  String status,
  String location,
  String date,
  Map<String, dynamic> complaintid,
) {
  // Decide color and icon based on status
  Color statusColor;
  IconData statusIcon;

  switch (status.toLowerCase()) {
    case 'pending':
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top;
      break;
    case 'solved':
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      break;
    case 'invalid':
      statusColor = Colors.redAccent;
      statusIcon = Icons.cancel;
      break;
    case 'ongoing':
      statusColor = Colors.lightBlue;
      statusIcon = Icons.work;
      break;
    default:
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
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
                      (context) => ManagerViewIssuesPage(
                        complaint: complaintid,
                        page: ManagerViewAllComplaintPage(),
                      ),
                )
                : MaterialPageRoute(
                  builder:
                      (context) => ManagerViewIssuesPage(
                        complaint: complaintid,
                        page: ManagerViewAllComplaintPage(),
                      ),
                ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('location: $location', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 4),
                    Text('reported at: $date', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'Status: ',
                        style: TextStyle(fontSize: 10),
                        children: [
                          TextSpan(
                            text: status, // your dynamic status
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor, // e.g. red, green, orange
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              Icon(Icons.arrow_right_rounded, size: 30),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
