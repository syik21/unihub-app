import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xml/xml.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? rawSvg;
  List<Map<String, dynamic>> parsedRooms = [];

  @override
  void initState() {
    super.initState();
    loadSvg();
  }

  Future<void> loadSvg() async {
    final supabase = Supabase.instance.client;

    // Step 1: Get the SVG path from Supabase 'map' table
    final response =
        await supabase
            .from('map')
            .select('img_path')
            .eq('id', '90a5bee7-e8e5-440f-90df-66e0e665bc7d')
            .single();

    final filePath = response['img_path'] as String;

    // Step 2: Download the raw SVG content
    final svgResponse = await supabase.storage.from('image').download(filePath);
    final svgRawString = String.fromCharCodes(svgResponse);

    // Step 3: Parse <rect> elements
    parseSvgRooms(svgRawString);

    // Step 4: Save raw SVG to render
    setState(() {
      rawSvg = svgRawString;
    });
  }

  void parseSvgRooms(String svgRawString) {
    final doc = XmlDocument.parse(svgRawString);
    final rooms = doc.findAllElements('rect');

    parsedRooms =
        rooms.map((room) {
          final id = room.getAttribute('name') ?? 'Unnamed';
          final x = double.tryParse(room.getAttribute('x') ?? '0') ?? 0;
          final y = double.tryParse(room.getAttribute('y') ?? '0') ?? 0;
          final width =
              double.tryParse(room.getAttribute('width') ?? '40') ?? 40;
          final height =
              double.tryParse(room.getAttribute('height') ?? '40') ?? 40;

          return {'name': id, 'x': x, 'y': y, 'width': width, 'height': height};
        }).toList();

    print('Parsed Rooms: $parsedRooms'); // Debug print
  }

  void _showRoomDialog(BuildContext context, String roomName) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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

  final double originalSvgWidth = 440; // From your <svg width="440" ... />
  final double originalSvgHeight = 600;

  @override
  Widget build(BuildContext context) {
    if (rawSvg == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / originalSvgWidth;
        final scaleY = constraints.maxHeight / originalSvgHeight;
        print(
          "----------------------------------------------------- x: $scaleX , y: $scaleY",
        );

        return Center(
          child: Container(
            color: Colors.grey[300],
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: FittedBox(
                child: SizedBox(
                  width: originalSvgWidth,
                  height: originalSvgHeight,
                  child: Stack(
                    children: [
                      SvgPicture.string(
                        rawSvg!,
                        width: originalSvgWidth,
                        height: originalSvgHeight,
                        fit: BoxFit.fill,
                      ),
                      ...parsedRooms.map((room) {
                        return Positioned(
                          left: room['x'],
                          top: room['y'],
                          child: GestureDetector(
                            onTap: () => _showRoomDialog(context, room['name']),
                            child: Container(
                              width: room['width'],
                              height: room['height'],
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
