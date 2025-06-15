import 'package:flutter/material.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ControlDevicePage extends StatefulWidget {
  const ControlDevicePage({super.key});

  @override
  State<ControlDevicePage> createState() => _ControlDevicePageState();
}

class _ControlDevicePageState extends State<ControlDevicePage> {
  // Demo dropdown values
  String selectedBlock = 'Block A';
  String selectedFloor = '2';
  String selectedRoom = 'A-02-05';

  // Demo switch states
  bool lightOn = true;
  bool aircondOn = true;
  bool projectorOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
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
                  Text('BLOCK', style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: AppDecorations.cardDecoration(context),
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      value: selectedBlock,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                      items:
                          ['Block A', 'Block B', 'Block C']
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedBlock = val);
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
                  Text('FLOOR', style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: AppDecorations.cardDecoration(context),
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      value: selectedFloor,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                      items:
                          ['1', '2', '3', '4']
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedFloor = val);
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
                  Text('ROOM', style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: AppDecorations.cardDecoration(context),
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      value: selectedRoom,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                      items:
                          ['A-02-05', 'A-02-06', 'A-02-07']
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRoom = val);
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
              // Control cards
              Column(
                children: [
                  _DeviceCard(
                    icon: Icons.lightbulb_outline,
                    iconColor: Colors.amber,
                    title: 'LIGHT',
                    energy: '2.64 KWH',
                    units: '8 UNITS',
                    isOn: lightOn,
                    onChanged: (val) => setState(() => lightOn = val),
                    switchColor: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _DeviceCard(
                    icon: Icons.ac_unit,
                    iconColor: Colors.blue,
                    title: 'AIRCOND',
                    energy: '2.04 KWH',
                    units: '2 UNITS',
                    isOn: aircondOn,
                    onChanged: (val) => setState(() => aircondOn = val),
                    switchColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _DeviceCard(
                    icon: Icons.video_label,
                    iconColor: Theme.of(context).colorScheme.tertiary,
                    title: 'PROJECTOR',
                    energy: '0.24 KWH',
                    units: '1 UNITS',
                    isOn: projectorOn,
                    onChanged: (val) => setState(() => projectorOn = val),
                    switchColor: Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String energy;
  final String units;
  final bool isOn;
  final ValueChanged<bool> onChanged;
  final Color switchColor;

  const _DeviceCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.energy,
    required this.units,
    required this.isOn,
    required this.onChanged,
    required this.switchColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
      decoration: AppDecorations.cardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: MediaQuery.of(context).size.width * 0.1,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                  softWrap: true,
                ),
                const SizedBox(height: 10),
                Text(
                  energy,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  units,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color:
                            isOn
                                ? switchColor
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Switch(
                      value: isOn,
                      onChanged: onChanged,
                      activeColor: switchColor,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent; // ON state
                          }
                          return Colors.transparent; // OFF state
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
