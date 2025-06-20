import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/Complaint/view_complaint_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class UserViewAllComplaintPage extends StatefulWidget {
  const UserViewAllComplaintPage({super.key});

  @override
  State<UserViewAllComplaintPage> createState() =>
      _UserViewAllComplaintPageState();
}

class _UserViewAllComplaintPageState extends State<UserViewAllComplaintPage> {
  List<Map<String, dynamic>>? allComplaints = [];
  List<Map<String, dynamic>>? filteredComplaints = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    loadComplaints();
    checkingconnection();
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
                        'My complaint',
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
                              onChanged: filterComplaint,
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
                    const SizedBox(height: 40),
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
                              ? const Center(child: Text("No complaints found"))
                              : ListView.builder(
                                itemCount: filteredComplaints?.length,
                                itemBuilder: (context, index) {
                                  final complaint = filteredComplaints![index];
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
              )
              : NoConnectionPage(
                function: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => UserViewAllComplaintPage(),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> loadComplaints() async {
    try {
      final result = await getAllComplaintByUserId(
        "c4dc1d3d-b2a8-4096-bc29-f3e945b47252",
      );
      if (mounted) {
        setState(() {
          allComplaints = result;
          filteredComplaints = result;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error here
    }
  }

  void filterComplaint(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredComplaints =
          allComplaints?.where((complaint) {
            final type = complaint['type']?.toLowerCase() ?? '';
            final room = complaint['room']?['name']?.toLowerCase() ?? '';
            return type.contains(q) || room.contains(q);
          }).toList();
    });
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
      filteredComplaints =
          allComplaints?.where((complaint) {
            final status = (complaint['status'] ?? '').toString().toLowerCase();
            final room =
                (complaint['room']?['name'] ?? '').toString().toLowerCase();
            final dateStr = complaint['receive_date'];
            DateTime? complaintDate;

            // Parse complaint date
            try {
              complaintDate = DateTime.parse(dateStr);
            } catch (_) {}

            final matchesQuery = status.contains(q) || room.contains(q);
            final matchesStatus =
                selectedStatuses.isEmpty || selectedStatuses.contains(status);
            final matchesDate =
                selectedDate == null ||
                (complaintDate != null &&
                    complaintDate.year == selectedDate.year &&
                    complaintDate.month == selectedDate.month &&
                    complaintDate.day == selectedDate.day);

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
                          activeColor: Colors.green,
                          title: const Text(
                            "Solved",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: selectedStatuses.contains("solved"),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStatuses.add("solved");
                              } else {
                                selectedStatuses.remove("solved");
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
                      ],
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
                      (context) => ViewComplaintPage(
                        complaint: complaintid,
                        page: UserViewAllComplaintPage(),
                      ),
                )
                : MaterialPageRoute(
                  builder:
                      (context) => ViewComplaintPage(
                        complaint: complaintid,
                        page: UserViewAllComplaintPage(),
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
                    Text(
                      'date reported: $date',
                      style: TextStyle(fontSize: 10),
                    ),
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
