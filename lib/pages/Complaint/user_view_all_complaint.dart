import 'package:flutter/material.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class UserViewAllComplaintPage extends StatelessWidget {
  const UserViewAllComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: Padding(
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
                      cursorColor: Theme.of(context).colorScheme.secondary,
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
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          builder:
                              (context) => SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        textAlign: TextAlign.center,
                                        'filter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            'Close',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.displayMedium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
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
            const SizedBox(height: 60),
            FutureBuilder(
              future: getAllComplaintByUserId(
                "c4dc1d3d-b2a8-4096-bc29-f3e945b47252",
              ),
              builder: (context, snapshot) {
                print(
                  'data: ${snapshot.data} error: ${snapshot.hasError} errorD: ${snapshot.error} hasData: ${snapshot.hasData}',
                );
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  if (snapshot.data != null) {
                    return Expanded(
                      child: NoConnectionPage(
                        function: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserViewAllComplaintPage(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Center(child: Text('error!!!!!'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Expanded(
                    child: const Center(child: Text('No asset found')),
                  );
                } else {
                  final complaintList = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: complaintList.length,
                    itemBuilder: (context, index) {
                      final complaint = complaintList[index];
                      final title = complaint['type'];
                      final status = complaint['status'];
                      final location = complaint['room']['name'];
                      final date = formatTimestamp(complaint['receive_date']);
                      return buildComplaintTile(title, status, location, date);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildComplaintTile(
  String title,
  String status,
  String location,
  String date,
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
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      break;
    default:
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
  }

  return InkWell(
    onTap: () {},
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text('location: $location', style: TextStyle(fontSize: 10)),
                SizedBox(height: 4),
                Text('date reported: $date', style: TextStyle(fontSize: 10)),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Status: ',
                    style: TextStyle(fontSize: 10, color: Colors.black),
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
  );
}
