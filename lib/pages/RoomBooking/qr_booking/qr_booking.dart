import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/backend/room_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrRoomBookingPage extends StatefulWidget {
  final Map<String, dynamic> room;
  const QrRoomBookingPage({super.key, required this.room});

  @override
  State<QrRoomBookingPage> createState() => _QrRoomBookingPageState();
}

class _QrRoomBookingPageState extends State<QrRoomBookingPage> {
  late Map<String, dynamic> room;
  bool isProcessing = false;
  bool hasEntered = false;

  @override
  void initState() {
    super.initState();
    room = Map<String, dynamic>.from(widget.room);
  }

  Future<void> _updateRoomPeople(bool increment) async {
    setState(() => isProcessing = true);
    final roomId = room['id'] as String;
    final prevStatus = room['status'] as String?;
    final updatedRoom =
        increment
            ? await incrementRoomPeople(roomId)
            : await decrementRoomPeople(roomId);
    if (updatedRoom != null) {
      final capacity = updatedRoom['capacity'] ?? 0;
      final newPeople = updatedRoom['current_people'] ?? 0;
      // Prevent entering if at capacity
      if (increment && newPeople > capacity) {
        setState(() => isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room is already at full capacity.')),
        );
        return;
      }
      // Handle status change logic
      if (increment && prevStatus == 'free') {
        // If entering a free room, set to occupied or full
        if (newPeople == capacity) {
          await _updateRoomStatus(roomId, 'full');
          updatedRoom['status'] = 'full';
        } else {
          await _updateRoomStatus(roomId, 'occupied');
          updatedRoom['status'] = 'occupied';
        }
      } else if (increment &&
          prevStatus == 'occupied' &&
          newPeople == capacity) {
        await _updateRoomStatus(roomId, 'full');
        updatedRoom['status'] = 'full';
      } else if (!increment && prevStatus == 'full' && newPeople < capacity) {
        // If exiting from full, set to occupied or free
        if (newPeople == 0) {
          await _updateRoomStatus(roomId, 'free');
          updatedRoom['status'] = 'free';
        } else {
          await _updateRoomStatus(roomId, 'occupied');
          updatedRoom['status'] = 'occupied';
        }
      } else if (!increment && prevStatus == 'occupied' && newPeople == 0) {
        await _updateRoomStatus(roomId, 'free');
        updatedRoom['status'] = 'free';
      }
      setState(() {
        room = Map<String, dynamic>.from(updatedRoom);
        hasEntered = increment;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update room occupancy.')),
      );
    }
    setState(() => isProcessing = false);
  }

  Future<void> _updateRoomStatus(String roomId, String status) async {
    try {
      await Supabase.instance.client
          .from('room')
          .update({'status': status})
          .eq('id', roomId);
    } catch (e) {
      debugPrint('Error updating room status: $e');
    }
  }

  Future<void> _showConfirmDialog(bool entering) async {
    final action = entering ? 'enter' : 'exit';
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to $action this room?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red[300], fontSize: 14),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes, $action',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await _updateRoomPeople(entering);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = room['map'] as Map<String, dynamic>?;
    final theme = Theme.of(context);
    final status = (room['status'] ?? '').toString();
    final currentPeople = room['current_people'] ?? 0;
    final capacity = room['capacity'] ?? 0;
    final canEnter =
        (status == 'free' || status == 'occupied' || status == 'full') &&
        (currentPeople < capacity);
    return PopScope(
      canPop: !hasEntered,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        appBar:
            hasEntered
                ? null
                : AppBar(
                  title: Text(
                    'Room Details',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  surfaceTintColor: Colors.transparent,
                ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                hasEntered
                    ? const SizedBox(height: 48)
                    : const SizedBox(height: 0),
                hasEntered
                    ? Text(
                      'You are currently at:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                    : Text(
                      'Quick Enter Room:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                const SizedBox(height: 32),
                Text(
                  room['name'] ?? '',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Type, Block, Floor Row
                _iconDetail(
                  icon: Icons.meeting_room_rounded,
                  label: room['type'] ?? '',
                ),
                if (map != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconDetail(
                        icon: Icons.apartment_rounded,
                        label: 'Block ${map['block'] ?? ''}',
                      ),
                      const SizedBox(width: 18),
                      _iconDetail(
                        icon: Icons.layers_rounded,
                        label: 'Floor ${map['floor']?.toString() ?? ''}',
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                // Card with details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: AppDecorations.cardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("status: "),
                          const SizedBox(width: 12),
                          _statusChip(status),
                        ],
                      ),
                      const Divider(height: 40),
                      Row(
                        children: [
                          _capacityBox(
                            label: 'Capacity',
                            value: room['capacity']?.toString() ?? '',
                            color: theme.colorScheme.primary,
                            icon: Icons.people_outline,
                          ),
                          const SizedBox(width: 16),
                          _capacityBox(
                            label: 'Current',
                            value: room['current_people']?.toString() ?? '',
                            color: theme.colorScheme.secondary.withAlpha(30),
                            icon: Icons.person,
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      _detailRow(
                        'Last Maintenance',
                        (room['last_maintenance'] ?? '')
                            .toString()
                            .split('T')
                            .first,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Enter/Exit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasEntered
                              ? theme.colorScheme.error
                              : theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      textStyle: theme.textTheme.displayLarge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        isProcessing || (!canEnter && !hasEntered)
                            ? null
                            : () => _showConfirmDialog(!hasEntered),
                    child:
                        isProcessing
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              hasEntered ? 'Exit Room' : 'Enter Room',
                              style: theme.textTheme.displayLarge,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconDetail({required IconData icon, required String label}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _capacityBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'free':
        color = Colors.green;
        break;
      case 'occupied':
        color = Colors.blue;
        break;
      case 'booked':
        color = Colors.orange;
        break;
      case 'scheduled':
        color = Colors.red;
        break;
      case 'full':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> decrementRoomPeople(String roomId) async {
    try {
      // Fetch current value
      final current =
          await Supabase.instance.client
              .from('room')
              .select('current_people')
              .eq('id', roomId)
              .maybeSingle();
      final currentPeople = (current?['current_people'] ?? 0) as int;
      final response =
          await Supabase.instance.client
              .from('room')
              .update({
                'current_people': currentPeople > 0 ? currentPeople - 1 : 0,
              })
              .eq('id', roomId)
              .select()
              .maybeSingle();
      return response;
    } catch (error) {
      debugPrint('Error decrementing room people: $error');
      return null;
    }
  }
}
