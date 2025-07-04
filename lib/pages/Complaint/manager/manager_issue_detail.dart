import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ManagerViewIssuesPage extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final Widget page;
  const ManagerViewIssuesPage({
    super.key,
    required this.complaint,
    required this.page,
  });

  @override
  State<ManagerViewIssuesPage> createState() => _ManagerViewIssuesPageState();

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
          style: Theme.of(context).textTheme.bodyMedium,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: gap),
        Text(":", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 20),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ManagerViewIssuesPageState extends State<ManagerViewIssuesPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents auto pop
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.page),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Back to My Complaint",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => widget.page));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Complaint',
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
        body: FutureBuilder(
          future: searchComplaintById(
            widget.complaint['id'],
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
                            (context) => ManagerViewIssuesPage(
                              complaint: widget.complaint,
                              page: widget.page,
                            ),
                      ),
                    );
                  },
                );
              }
              return Center(child: Text('error!!!!!'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No complaint found'));
            } else {
              final complaintDetail = snapshot.data!;
              final image = complaintDetail['image_url'];
              final complaintID = complaintDetail['id'];
              final assetID = complaintDetail['asset_id'];
              final title = complaintDetail['type'];
              final desc = complaintDetail['description'];
              final status = complaintDetail['status'];
              final date = formatTimestamp(complaintDetail['receive_date']);
              final location = complaintDetail['room']['name'];
              final roomType = complaintDetail['room']['type'];
              final roomBlock = complaintDetail['room']['map']['block'];
              final roomFloor = complaintDetail['room']['map']['floor'];
              final assetCode =
                  assetID != null
                      ? complaintDetail['asset']['code']
                          .toString()
                          .replaceAll('br', '')
                          .trim()
                      : '';
              final assetName =
                  assetID != null ? complaintDetail['asset']['name'] : '';
              final assetCategory =
                  assetID != null ? complaintDetail['asset']['category'] : '';
              final user = complaintDetail['user']['name'];
              final userId = complaintDetail['user']['id'];
              final userEmail = complaintDetail['user']['email'];

              Color boxColor;

              switch (status.toLowerCase()) {
                case 'pending':
                  boxColor = Colors.orange;
                  break;
                case 'solved':
                  boxColor = Colors.green;
                  break;
                case 'invalid':
                  boxColor = Colors.redAccent;
                  break;
                case 'ongoing':
                  boxColor = Colors.lightBlue;
                  break;
                default:
                  boxColor = Colors.grey;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                            ),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF14141E),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  image,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              child: Image.network(
                                image,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: boxColor,
                                ),
                              ),
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status, // your dynamic status
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: boxColor, // e.g. red, green, orange
                            ),
                          ),
                          const SizedBox(width: 10),
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: boxColor,
                                ),
                              ),
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: boxColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: boxColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Complaint Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'Complaint ID',
                                    34,
                                    complaintID,
                                  ),
                                  const SizedBox(height: 10),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'Date Reported',
                                    20,
                                    date,
                                  ),
                                  const SizedBox(height: 10),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'Description',
                                    41,
                                    desc,
                                  ),
                                  const SizedBox(height: 40),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Locate At',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SvgPicture.asset(
                                        'asset/icon/more_page/location_more_icon.svg',
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'room',
                                    85,
                                    location,
                                  ),
                                  const SizedBox(height: 8),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'type',
                                    88.5,
                                    roomType,
                                  ),
                                  const SizedBox(height: 8),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'block',
                                    81,
                                    roomBlock,
                                  ),
                                  const SizedBox(height: 8),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'Floor',
                                    82,
                                    roomFloor,
                                  ),

                                  if (assetID != null)
                                    Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'asset info',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            SvgPicture.asset(
                                              'asset/icon/more_page/location_more_icon.svg',
                                              height: 16,
                                              colorFilter: ColorFilter.mode(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ManagerViewIssuesPage.lableText(
                                          context,
                                          'code',
                                          88.5,
                                          assetCode,
                                        ),
                                        const SizedBox(height: 8),
                                        ManagerViewIssuesPage.lableText(
                                          context,
                                          'name',
                                          85,
                                          assetName,
                                        ),
                                        const SizedBox(height: 8),
                                        ManagerViewIssuesPage.lableText(
                                          context,
                                          'category',
                                          56,
                                          assetCategory,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 40),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Reported By',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.person, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'name',
                                    85.5,
                                    user,
                                  ),
                                  const SizedBox(height: 8),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'email',
                                    83,
                                    userEmail,
                                  ),
                                  const SizedBox(height: 8),
                                  ManagerViewIssuesPage.lableText(
                                    context,
                                    'user Id',
                                    73.5,
                                    userId,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
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
                            onPressed: () async {
                              await showModalBottomSheet(
                                backgroundColor: Theme.of(context).primaryColor,
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) {
                                  return ComplaintStatusSelector(
                                    currentStatus: status,
                                    onStatusSelected: (selectedStatus) async {
                                      // Close bottom sheet
                                      final success =
                                          await updateComplaintStatus(
                                            complaintID,
                                            selectedStatus,
                                          );
                                      if (success) {
                                        _showSuccessMessage(
                                          'Status updated successfully',
                                        );
                                        setState(() {});
                                      } else {
                                        _showErrorMessage(
                                          'Failed to update complaint status',
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                'change status',
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

  void _showSuccessMessage(String message) {
    AppDecorations.showCustomSnackBar(
      context,
      message,
      Colors.green.shade100,
      Duration(seconds: 3),
      icon: Icons.check_circle,
      iconColor: Colors.green.shade800,
    );
  }

  

  void _showErrorMessage(String message) {
    AppDecorations.showCustomSnackBar(
      context,
      message,
      Colors.red.shade100,
      Duration(seconds: 3),
      icon: Icons.cancel_outlined,
      iconColor: Colors.red.shade800,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          icon: Icon(Icons.password_rounded),
          title: const Text("Delete this issue"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                "Enter your password to confirm deletion.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Theme.of(context).colorScheme.secondary,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 14),),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("Delete", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),),
              onPressed:
                  () => _handleDeleteComplaint(
                    context: context,
                    passwordController: passwordController,
                    managerId:
                        Provider.of<UserProvider>(context).userId, //! manager id here -----------------------------------------------------------------------------------------
                    complaintId: widget.complaint['id'],
                    nextPage: widget.page,
                  ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteComplaint({
    required BuildContext context,
    required TextEditingController passwordController,
    required String? managerId,
    required String complaintId,
    required Widget nextPage,
  }) async {
    final enteredPassword = passwordController.text.trim();

    // Store navigator & messenger early to use safely after unmount
    final navigator = Navigator.of(context);

    final isValid = await validateUserPassword(managerId, enteredPassword);

    navigator.pop(); // Close password dialog regardless

    if (isValid) {
      // Show loading
      if (!context.mounted) return;
      AppDecorations.showLoadingDialog(context, message: "Deleting complaint...");

      await deleteComplaint(complaintId);

      navigator.pop(); // Close loading dialog

      _showSuccessMessage('Complaint deleted successfully');

      navigator.pushReplacement(MaterialPageRoute(builder: (_) => nextPage));
    } else {
      _showErrorMessage('Invalid password');
    }
  }
}

class ComplaintStatusSelector extends StatefulWidget {
  final void Function(String) onStatusSelected;
  final String currentStatus;

  const ComplaintStatusSelector({
    super.key,
    required this.onStatusSelected,
    required this.currentStatus,
  });

  @override
  State<ComplaintStatusSelector> createState() =>
      _ComplaintStatusSelectorState();
}

class _ComplaintStatusSelectorState extends State<ComplaintStatusSelector> {
  late String
  selectedStatus; // use `late` since it's initialized in `initState`

  final List<Map<String, dynamic>> statusOptions = [
    {
      'label': 'solved',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    {
      'label': 'invalid',
      'icon': Icons.cancel_outlined,
      'color': Colors.redAccent,
    },
    {'label': 'ongoing', 'icon': Icons.sync_alt, 'color': Colors.lightBlue},
    {'label': 'pending', 'icon': Icons.access_time, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatus; // 🔹 initialize selected
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Complaint Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            /// Status Chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  statusOptions.map((option) {
                    final isSelected = selectedStatus == option['label'];
                    final Color bgColor =
                        isSelected
                            ? option['color']
                            : Theme.of(context).colorScheme.primary;
                    final Color textColor =
                        isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.tertiary;
                    final IconData iconData = option['icon'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = option['label'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                isSelected
                                    ? option['color']
                                    : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: option['color'].withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData, color: textColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              option['label'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            /// Confirm / Cancel Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.withAlpha(100),
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(
                      'Confirm',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed:
                        (selectedStatus != widget.currentStatus)
                            ? () {
                              Navigator.pop(context);
                              widget.onStatusSelected(selectedStatus);
                            }
                            : null, // disable if not changed
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
