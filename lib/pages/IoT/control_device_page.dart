import 'package:flutter/material.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/IoT/iot_backend.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class Device {
  final String id;
  final String name;
  bool isOn;

  Device({required this.id, required this.name, required this.isOn});
}

class ControlDevicePage extends StatefulWidget {
  const ControlDevicePage({super.key});

  @override
  State<ControlDevicePage> createState() => _ControlDevicePageState();
}

class _ControlDevicePageState extends State<ControlDevicePage> {
  final IotBackend _iotBackend = IotBackend();

  String? selectedBlock;
  String? selectedFloor;
  String? selectedRoom;

  List<String> blocks = [];
  List<String> floors = [];
  List<String> rooms = [];

  List<Device> devices = [];

  bool isLoadingBlocks = false;
  bool isLoadingFloors = false;
  bool isLoadingRooms = false;
  bool isLoadingDevices = false;

  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    checkingconnection();
    _fetchBlocks();
  }

  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }

  Future<void> _fetchBlocks() async {
    setState(() => isLoadingBlocks = true);
    try {
      final fetchedBlocks = await _iotBackend.getBlocks();
      if (mounted) {
        setState(() => blocks = fetchedBlocks);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching blocks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingBlocks = false);
      }
    }
  }

  Future<void> _fetchFloors(String block) async {
    setState(() => isLoadingFloors = true);
    try {
      final fetchedFloors = await _iotBackend.getFloors(block);
      if (mounted) {
        setState(() => floors = fetchedFloors);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching floors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingFloors = false);
      }
    }
  }

  Future<void> _fetchRooms(String block, String floor) async {
    setState(() => isLoadingRooms = true);
    try {
      final fetchedRooms = await _iotBackend.getRooms(block, floor);
      if (mounted) {
        setState(() => rooms = fetchedRooms);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching rooms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingRooms = false);
      }
    }
  }

  Future<void> _fetchDevices(String room) async {
    setState(() => isLoadingDevices = true);
    try {
      final fetchedDevices = await _iotBackend.getDevicesInRoom(room);
      if (mounted) {
        setState(() => devices = fetchedDevices);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching devices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingDevices = false);
      }
    }
  }

  Future<void> _updateDeviceStatus(Device device, bool newState) async {
    final originalState = device.isOn;
    setState(() {
      device.isOn = newState;
    });

    try {
      await _iotBackend.updateDeviceStatus(device.id, newState);
    } catch (e) {
      setState(() {
        device.isOn = originalState;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating device: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body:
          isConnected
              ? SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Device controller",
                          style: Theme.of(context).textTheme.headlineLarge,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'TARGET LOCATION',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.apartment,
                            size: 22,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BLOCK',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: AppDecorations.cardDecoration(context),
                            child: DropdownButton<String>(
                              dropdownColor:
                                  Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              value: selectedBlock,
                              hint:
                                  isLoadingBlocks
                                      ? const Text('Loading...')
                                      : const Text('Select Block'),
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              style: Theme.of(context).textTheme.labelMedium,
                              items:
                                  blocks
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b,
                                          child: Text(b),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedBlock = val;
                                    selectedFloor = null;
                                    selectedRoom = null;
                                    floors = [];
                                    rooms = [];
                                    devices = [];
                                  });
                                  _fetchFloors(val);
                                  checkingconnection();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.layers,
                            size: 22,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FLOOR',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: AppDecorations.cardDecoration(context),
                            child: DropdownButton<String>(
                              dropdownColor:
                                  Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              value: selectedFloor,
                              hint:
                                  isLoadingFloors
                                      ? const Text('Loading...')
                                      : const Text('Select Floor'),
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              style: Theme.of(context).textTheme.labelMedium,
                              items:
                                  floors
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  selectedBlock == null
                                      ? null
                                      : (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedFloor = val;
                                            selectedRoom = null;
                                            rooms = [];
                                            devices = [];
                                          });
                                          _fetchRooms(selectedBlock!, val);
                                          checkingconnection();
                                        }
                                      },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room,
                            size: 22,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ROOM',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: AppDecorations.cardDecoration(context),
                            child: DropdownButton<String>(
                              dropdownColor:
                                  Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              value: selectedRoom,
                              hint:
                                  isLoadingRooms
                                      ? const Text('Loading...')
                                      : const Text('Select Room'),
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              style: Theme.of(context).textTheme.labelMedium,
                              items:
                                  rooms
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  selectedFloor == null
                                      ? null
                                      : (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedRoom = val;
                                            devices = [];
                                          });
                                          _fetchDevices(val);
                                          checkingconnection();
                                        }
                                      },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'CONTROL SIGNAL',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildDeviceGrid(),
                      ),
                    ],
                  ),
                ),
              )
              : NoConnectionPage(
                function: () {
                  checkingconnection();
                  setState(() {});
                },
              ),
    );
  }

  Widget _buildDeviceGrid() {
    if (isLoadingDevices) {
      return const Center(
        key: ValueKey('loading'),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (selectedRoom == null) {
      return Container(
        key: const ValueKey('waiting'),
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: Text('Please select a location to see devices.'),
        ),
      );
    }

    if (devices.isEmpty) {
      return Container(
        key: ValueKey(selectedRoom), // Animate when room changes
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(child: Text('No devices found in this room.')),
      );
    }

    return GridView.builder(
      key: ValueKey(selectedRoom),
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1 / 1.2,
      ),
      itemBuilder: (context, index) {
        final device = devices[index];
        IconData icon;
        Color color;
        final deviceNameUpper = device.name.toUpperCase();

        if (deviceNameUpper.contains('LIGHT')) {
          icon = device.isOn ? Icons.lightbulb : Icons.lightbulb_outline;
          color = Colors.amber;
        } else if (deviceNameUpper.contains('AIRCON') ||
            deviceNameUpper.contains('HVAC')) {
          icon = Icons.ac_unit; // Snowflake icon for HVAC
          color = Colors.red.shade400;
        } else if (deviceNameUpper.contains('NETWORK')) {
          icon = device.isOn ? Icons.dns : Icons.dns_outlined;
          color = Colors.blue.shade400;
        } else if (deviceNameUpper.contains('PROJECTOR')) {
          icon =
              device.isOn
                  ? Icons.personal_video
                  : Icons.personal_video_outlined;
          color = Colors.deepPurpleAccent;
        } else if (deviceNameUpper.contains('DEVICE')) {
          icon = device.isOn ? Icons.print : Icons.print_outlined;
          color = Colors.purple.shade300;
        } else {
          icon = Icons.help_outline;
          color = Colors.grey;
        }

        return _DeviceCard(
          icon: icon,
          title: device.name,
          isOn: device.isOn,
          onChanged: (val) {
            _updateDeviceStatus(device, val);
            checkingconnection();
          },
          switchColor: color,
        );
      },
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isOn;
  final ValueChanged<bool> onChanged;
  final Color switchColor;

  const _DeviceCard({
    required this.icon,
    required this.title,
    required this.isOn,
    required this.onChanged,
    required this.switchColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: AppDecorations.cardDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color:
                    isOn ? switchColor : Theme.of(context).colorScheme.tertiary,
                size: 32,
              ),
              Transform.scale(
                scale: 0.8,
                alignment: Alignment.topRight,
                child: Switch(
                  value: isOn,
                  onChanged: onChanged,
                  activeColor: switchColor,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                  trackOutlineColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isOn
                          ? switchColor
                          : Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
