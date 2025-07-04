import 'package:flutter/material.dart';
import 'package:unihub/backend/room_backend.dart';
import 'package:unihub/pages/RoomBooking/my_booking_page.dart';
import 'package:unihub/other/successful_page.dart';
import 'package:unihub/pages/RoomBooking/services/room_booking_service.dart';
import 'package:provider/provider.dart';
import 'package:unihub/pages/user-profile/auth_user.dart';
import 'package:unihub/backend/function.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class MapVenueDetailPage extends StatefulWidget {
  final String roomName;
  const MapVenueDetailPage({super.key, required this.roomName});

  @override
  State<MapVenueDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<MapVenueDetailPage> {
  late Future<Map<String, dynamic>?> _roomFuture;

  @override
  void initState() {
    super.initState();
    // Assign a default value to avoid LateInitializationError
    _roomFuture = Future.value(null);
    initData();
  }

  void initData() async {
    await checkingConnect();
    if (isConnected) {
      setState(() {
        _roomFuture = searchRoomByName(widget.roomName);
      });
    }
  }

  bool isConnected = true;
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

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icons.cancel_rounded,
      iconColor: Colors.white,
    );
  }

  void _showSucessMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      iconColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _roomFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading room details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }
          final room = snapshot.data;
          if (room == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_pin, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Venue not found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('No details available for "${widget.roomName}".'),
                ],
              ),
            );
          }

          // Extract details
          final name = room['name'] ?? '-';
          final type = room['type'] ?? '-';
          final capacity = room['capacity']?.toString() ?? '-';
          final currentPeople = room['current_people']?.toString() ?? '-';
          final status = (room['status'] ?? '-').toString().toLowerCase();
          Color statusColor;
          IconData statusIcon;
          switch (status) {
            case 'free':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              break;
            case 'occupied':
              statusColor = Colors.blue;
              statusIcon = Icons.co_present;
              break;
            case 'booked':
              statusColor = Colors.orange;
              statusIcon = Icons.event;
              break;
            case 'scheduled':
              statusColor = Colors.orange;
              statusIcon = Icons.alarm;
              break;
            case 'maintenance':
              statusColor = Colors.redAccent;
              statusIcon = Icons.build_circle_rounded;
              break;
            case 'full':
              statusColor = Colors.redAccent;
              statusIcon = Icons.block;
              break;
            default:
              statusColor = Colors.grey;
              statusIcon = Icons.help_outline;
          }
          final lastMaintenance =
              room['last_maintenance'] != null
                  ? (room['last_maintenance'].toString().split('T').first)
                  : '-';
          final map = room['map'] ?? {};
          final block = map['block']?.toString() ?? '-';
          final floor = map['floor']?.toString() ?? '-';

          final userType = Provider.of<UserProvider>(context).userType;
          final isManager = userType == 'manager';
          final isMaintenance = status == 'maintenance';
          final canSetMaintenance =
              isManager &&
              (status == 'free' || status == 'occupied' || status == 'full');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Chip(
                  label: Text(type.toString().toUpperCase()),
                  avatar: Icon(
                    Icons.category,
                    size: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoCard(
                      icon: Icons.person,
                      label: 'Capacity',
                      value: capacity,
                      color: Colors.blueAccent,
                    ),
                    _InfoCard(
                      icon: Icons.people,
                      label: 'Current',
                      value: currentPeople,
                      color: Colors.blueAccent,
                    ),
                    _InfoCard(
                      icon: statusIcon,
                      label: 'Status',
                      value: status.toUpperCase(),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Last Maintenance:',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lastMaintenance,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.apartment_rounded,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Block:',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              block,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.layers_rounded,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Floor:',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              floor,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!isMaintenance)
                  canSetMaintenance
                      ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.build_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            'room maintenance',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await checkingConnect();
                            if (!isConnected) {
                              _showErrorMessage(
                                "no connection! Can't do Anything",
                              );
                              return;
                            }
                            final passwordController = TextEditingController();
                            bool isError = false;
                            bool isLoading = false;
                            final userProvider = Provider.of<UserProvider>(
                              context,
                              listen: false,
                            );
                            bool? confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text(
                                        'Confirm Maintenance',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Enter your password to set this room to maintenance:',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 16),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              textSelectionTheme:
                                                  const TextSelectionThemeData(
                                                    // <-- Highlight background color
                                                    cursorColor: Color(
                                                      0xFF14141E,
                                                    ), // <-- Cursor color
                                                    selectionHandleColor: Color(
                                                      0xFF14141E,
                                                    ), // <-- Handle color
                                                  ),
                                            ),
                                            child: TextField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                labelText: 'Manager Password',
                                                labelStyle: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.secondary,
                                                ),
                                                errorText:
                                                    isError
                                                        ? 'Incorrect password'
                                                        : null,
                                              ),
                                              onChanged: (_) {
                                                if (isError) {
                                                  setState(
                                                    () => isError = false,
                                                  );
                                                }
                                                ;
                                              },
                                              onSubmitted:
                                                  (_) =>
                                                      FocusScope.of(
                                                        context,
                                                      ).unfocus(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.red[300],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              isLoading
                                                  ? null
                                                  : () async {
                                                    await checkingConnect();
                                                    if (!isConnected) {
                                                      _showErrorMessage(
                                                        "no connection! Can't do Anything",
                                                      );
                                                      return;
                                                    }
                                                    setState(
                                                      () => isLoading = true,
                                                    );
                                                    final ok =
                                                        await validateUserPassword(
                                                          userProvider.userId,
                                                          passwordController
                                                              .text,
                                                        );
                                                    setState(
                                                      () => isLoading = false,
                                                    );
                                                    if (ok) {
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      );
                                                    } else {
                                                      setState(
                                                        () => isError = true,
                                                      );
                                                    }
                                                  },
                                          child:
                                              isLoading
                                                  ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : Text(
                                                    'Confirm',
                                                    style:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displayMedium,
                                                  ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            if (confirmed == true) {
                              final supabase = Supabase.instance.client;
                              await supabase
                                  .from('room')
                                  .update({
                                    'status': 'maintenance',
                                    'current_people': 0,
                                  })
                                  .eq('id', room['id']);
                              if (mounted) {
                                _showSucessMessage('Room set to maintenance.');
                                setState(() {
                                  _roomFuture = searchRoomByName(
                                    widget.roomName,
                                  );
                                });
                              }
                            }
                          },
                        ),
                      )
                      : (!isManager && type != 'library' && type != 'cafeteria')
                      ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.event_available_rounded),
                          label: Text(
                            'Book this Room',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await checkingConnect();
                            if (!isConnected) {
                              _showErrorMessage(
                                "no connection! Can't do Anything",
                              );
                              return;
                            }
                            final result = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => _QuickBookingDialog(room: room),
                            );
                            if (result == true && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SuccessfulPage(
                                        title: 'Booking Successful!',
                                        description:
                                            'Your booking for ${room['name']} has been submitted.',
                                        buttonText: 'View My Bookings',
                                        page: const MyBookingPage(),
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
                if (isMaintenance && isManager)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        'Maintenance Done',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await checkingConnect();
                        if (!isConnected) {
                          _showErrorMessage("no connection! Can't do Anything");
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Confirm Maintenance Done'),
                                content: const Text(
                                  'Set this room status to free?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      'Confirm',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.displayMedium,
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          final supabase = Supabase.instance.client;
                          await supabase
                              .from('room')
                              .update({'status': 'free'})
                              .eq('id', room['id']);
                          if (mounted) {
                            _showSucessMessage('Room status set to free.');

                            setState(() {
                              _roomFuture = searchRoomByName(widget.roomName);
                            });
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBookingDialog extends StatefulWidget {
  final Map<String, dynamic> room;
  const _QuickBookingDialog({required this.room});

  @override
  State<_QuickBookingDialog> createState() => _QuickBookingDialogState();
}

class _QuickBookingDialogState extends State<_QuickBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> usages = [
    'meeting',
    'event purpose',
    'lecture',
    'lab',
    'discussion',
    'other',
  ];
  String? usage;
  DateTimeRange? selectedRange;
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController desController = TextEditingController();
  bool _desEmpty = false;
  bool _dateEmpty = false;
  bool _timeInvalid = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    usage = usages[0];
  }

  bool isConnected = true;
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

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.redAccent,
      icon: Icons.cancel_rounded,
      iconColor: Colors.white,
    );
  }

  String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Book ${widget.room['name']}',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usage Dropdown
              DropdownButtonFormField<String>(
                style: Theme.of(context).textTheme.labelLarge,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: usage,
                items:
                    usages
                        .map(
                          (u) => DropdownMenuItem<String>(
                            value: u,
                            child: Text(u),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => usage = val!),
                decoration: InputDecoration(
                  labelText: 'Usage',
                  labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  prefixIcon: Icon(Icons.event_note),
                ),
              ),
              const SizedBox(height: 16),
              // Date Range Picker
              InkWell(
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
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dialogTheme: DialogThemeData(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          colorScheme:
                              Theme.of(context).brightness == Brightness.dark
                                  ? ColorScheme.dark(
                                    primary:
                                        Theme.of(context).colorScheme.secondary,
                                    onPrimary: Theme.of(context).primaryColor,
                                    secondary: Color.fromARGB(60, 181, 253, 6),
                                    onSurface: Colors.white,
                                    surface: Theme.of(context).primaryColor,
                                  )
                                  : ColorScheme.light(
                                    primary:
                                        Theme.of(context).colorScheme.secondary,
                                    onPrimary: Theme.of(context).primaryColor,
                                    onSurface: Colors.black,
                                    surface: Theme.of(context).primaryColor,
                                    secondary: Colors.grey.withAlpha(100),
                                  ),
                          textTheme: TextTheme(
                            labelLarge: Theme.of(context).textTheme.labelSmall,
                            titleSmall: Theme.of(context).textTheme.labelSmall,
                            titleLarge:
                                Theme.of(context).textTheme.headlineLarge,
                            labelMedium: Theme.of(context).textTheme.labelSmall,
                            bodyMedium: Theme.of(context).textTheme.bodyLarge,
                            headlineLarge:
                                Theme.of(context).textTheme.headlineLarge,
                            bodyLarge: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => selectedRange = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date Range',
                    labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    prefixIcon: const Icon(Icons.date_range),
                    errorText: _dateEmpty ? 'Please select a date range' : null,
                  ),
                  child: Text(
                    selectedRange != null
                        ? selectedRange!.start == selectedRange!.end
                            ? formatDate(selectedRange!.start)
                            : '${formatDate(selectedRange!.start)} - ${formatDate(selectedRange!.end)}'
                        : 'Select date range',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Time Picker
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogThemeData(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                colorScheme:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onSecondary:
                                              Theme.of(context).primaryColor,
                                          onSurface: Colors.white,
                                          surface:
                                              Theme.of(context).primaryColor,
                                        )
                                        : ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onSecondary:
                                              Theme.of(context).primaryColor,
                                          onSurface: Colors.black,
                                          surface:
                                              Theme.of(context).primaryColor,
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
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() => startTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogThemeData(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                colorScheme:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onSecondary:
                                              Theme.of(context).primaryColor,
                                          onSurface: Colors.white,
                                          surface:
                                              Theme.of(context).primaryColor,
                                        )
                                        : ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onPrimary:
                                              Theme.of(context).primaryColor,
                                          secondary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          onSecondary:
                                              Theme.of(context).primaryColor,
                                          onSurface: Colors.black,
                                          surface:
                                              Theme.of(context).primaryColor,
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
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() => endTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_timeInvalid)
                const Padding(
                  padding: EdgeInsets.only(top: 3, left: 5),
                  child: Text(
                    'Invalid time or slot unavailable.',
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ),
              const SizedBox(height: 16),
              // Description
              Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: const TextSelectionThemeData(
                    // <-- Highlight background color
                    cursorColor: Color(0xFF14141E), // <-- Cursor color
                    selectionHandleColor: Color(0xFF14141E), // <-- Handle color
                  ),
                ),
                child: TextFormField(
                  controller: desController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    prefixIcon: const Icon(Icons.description),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    errorText: _desEmpty ? 'Please describe the purpose' : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: Colors.red[300])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              _isSubmitting
                  ? null
                  : () async {
                    await checkingConnect();
                    if (!isConnected) {
                      _showErrorMessage("no connection! Can't do Anything");
                      return;
                    }
                    // Validation
                    setState(() {
                      _desEmpty = desController.text.trim().isEmpty;
                      _dateEmpty = selectedRange == null;
                    });
                    if (_desEmpty || _dateEmpty) return;
                    // Time validation
                    DateTime now = DateTime.now();
                    final startDate = DateTime(
                      selectedRange!.start.year,
                      selectedRange!.start.month,
                      selectedRange!.start.day,
                    );

                    final startDateTime = DateTime(
                      0,
                      0,
                      0,
                      startTime.hour,
                      startTime.minute,
                    );
                    final endDateTime = DateTime(
                      0,
                      0,
                      0,
                      endTime.hour,
                      endTime.minute,
                    );
                    final diff = endDateTime.difference(startDateTime);
                    if (diff.inMinutes <= 0 ||
                        diff.inMinutes < 60 ||
                        diff.inHours > 24) {
                      setState(() => _timeInvalid = true);
                      return;
                    }
                    if (startDate.isAtSameMomentAs(
                      DateTime(now.year, now.month, now.day),
                    )) {
                      if (startDateTime.isBefore(now)) {
                        _showErrorMessage("You can't select a past time.");
                        setState(() {
                          _timeInvalid = true;
                        });
                        return;
                      }
                    }
                    setState(() => _isSubmitting = true);
                    // Check slot availability
                    final service = RoomBookingService();
                    final slotUnavailable = await service
                        .isBookingSlotAvailable(
                          roomId: widget.room['id'],
                          startDate: selectedRange!.start,
                          endDate: selectedRange!.end,
                          startTime: startTime,
                          endTime: endTime,
                        );
                    if (slotUnavailable.isNotEmpty) {
                      showUnavailableDatetime(slotUnavailable);
                      setState(() => _isSubmitting = false);
                      return;
                    }
                    // Create booking
                    final booking = await service.createBooking(
                      userId: userId,
                      roomId: widget.room['id'],
                      startDate: selectedRange!.start,
                      endDate: selectedRange!.end,
                      purpose: usage!,
                      description: desController.text,
                      startTime: startTime,
                      endTime: endTime,
                    );
                    setState(() => _isSubmitting = false);
                    if (booking.isNotEmpty) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking failed.')),
                      );
                    }
                  },
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(
                    'Book',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
        ),
      ],
    );
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
      shape: const RoundedRectangleBorder(
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
                      return Text(
                        '• $startDate > $endDate  (Time: $startTime - $endTime)',
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
}

// Add this helper function (stub for now, replace with real check if available)
