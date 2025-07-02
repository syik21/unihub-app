import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/other/error_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUsers(),
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
          return NoConnectionPage(
            function: () {
              setState(() {});
            },
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        } else {
          final users = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Stack(
                  children: [
                    // Floorplan SVG
                    SvgPicture.asset(
                      'assets/floorplan.svg',
                      width: 1000,
                      height: 1000,
                      fit: BoxFit.contain,
                    ),

                    // Room marker: Lab A
                    Positioned(
                      left: 300,
                      top: 150,
                      child: GestureDetector(
                        onTap: () => _showRoomDialog(context, "Lab A"),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),

                    // Room marker: Office B
                    Positioned(
                      left: 600,
                      top: 450,
                      child: GestureDetector(
                        onTap: () => _showRoomDialog(context, "Office B"),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),

                    // Room marker: Meeting Room
                    Positioned(
                      left: 450,
                      top: 700,
                      child: GestureDetector(
                        onTap: () => _showRoomDialog(context, "Meeting Room"),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await Supabase.instance.client.from('user').select();
    debugPrint('$response');
    return response;
  }
  void _showRoomDialog(BuildContext context, String roomName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(roomName),
        content: Text("You tapped on $roomName."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
  
}
