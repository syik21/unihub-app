import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/main/map_room_detail_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:xml/xml.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? rawSvg;
  List<Map<String, dynamic>> parsedRooms = [];

  // Block/floor navigation state
  bool showingBlock = false;
  String? currentBlock;
  List<Map<String, dynamic>> blockFloors = [];
  int selectedFloorIndex = 0;
  bool isBlockLoading = false;
  String? mainSvg;
  List<Map<String, dynamic>> mainParsedRooms = [];

  // Search state
  String searchQuery = '';
  String? highlightedRoomName;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    await checkingConnect();
    if (isConnected) {
      loadSvg();
    }
  }

  Future<void> loadSvg() async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase
            .from('map')
            .select('img_path')
            .eq('id', '90a5bee7-e8e5-440f-90df-66e0e665bc7d')
            .single();
    final filePath = response['img_path'] as String;
    final svgResponse = await supabase.storage.from('image').download(filePath);
    final svgRawString = String.fromCharCodes(svgResponse);
    parseSvgRooms(svgRawString);
    setState(() {
      rawSvg = svgRawString;
      mainSvg = svgRawString;
      mainParsedRooms = List<Map<String, dynamic>>.from(parsedRooms);
      showingBlock = false;
      currentBlock = null;
      blockFloors = [];
      selectedFloorIndex = 0;
    });
  }

  Future<void> loadBlockFloors(String block) async {
    setState(() {
      isBlockLoading = true;
      blockFloors = [];
      selectedFloorIndex = 0;
    });
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('map')
        .select('floor, img_path')
        .eq('block', block)
        .order('floor', ascending: true);
    final floors = List<Map<String, dynamic>>.from(response);
    if (floors.isNotEmpty) {
      final svgResponse = await supabase.storage
          .from('image')
          .download(floors[0]['img_path']);
      final svgString = String.fromCharCodes(svgResponse);
      setState(() {
        rawSvg = svgString;
        blockFloors = floors;
        selectedFloorIndex = 0;
        showingBlock = true;
        currentBlock = block;
        isBlockLoading = false;
      });
      parseSvgRooms(svgString);
    } else {
      setState(() {
        blockFloors = [];
        rawSvg = null;
        parsedRooms = [];
        showingBlock = true;
        currentBlock = block;
        isBlockLoading = false;
      });
    }
  }

  Future<void> switchBlockFloor(int idx) async {
    if (idx < 0 || idx >= blockFloors.length) return;
    setState(() {
      isBlockLoading = true;
    });
    final supabase = Supabase.instance.client;
    final svgResponse = await supabase.storage
        .from('image')
        .download(blockFloors[idx]['img_path']);
    final svgString = String.fromCharCodes(svgResponse);
    setState(() {
      rawSvg = svgString;
      selectedFloorIndex = idx;
      isBlockLoading = false;
    });
    parseSvgRooms(svgString);
  }

  void handleRoomTap(Map<String, dynamic> room) {
    final name = room['name'].toString().toLowerCase();
    if (name.startsWith('block')) {
      final block = room['name'].toString().split(' ').last.toUpperCase();
      loadBlockFloors(block);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapVenueDetailPage(roomName: room['name']),
        ),
      );
    }
  }

  void backToMainMap() {
    setState(() {
      rawSvg = mainSvg;
      parsedRooms = List<Map<String, dynamic>>.from(mainParsedRooms);
      showingBlock = false;
      currentBlock = null;
      blockFloors = [];
      selectedFloorIndex = 0;
    });
  }

  void parseSvgRooms(String svgRawString) {
    final doc = XmlDocument.parse(svgRawString);

    // Find all <rect> elements with type="touchable"
    final rooms = doc.findAllElements('rect').where((rect) {
      return rect.getAttribute('type') == 'touchable';
    });

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
  }

  final double originalSvgWidth = 440; // From your <svg width="440" ... />
  final double originalSvgHeight = 600;
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

  @override
  Widget build(BuildContext context) {
    final isLoading = rawSvg == null || isBlockLoading;
    return !isConnected
        ? NoConnectionPage(
          function: () async {
            await checkingConnect();
            if (isConnected) {
              loadSvg();
            }
            setState(() {});
          },
        )
        : LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              appBar: AppBar(
                actions: [
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            selectionHandleColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(100),
                          child: TextField(
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            controller: searchController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Search a location...',
                              hintStyle: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withAlpha(100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              suffixIcon:
                                  searchQuery.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() {
                                            searchQuery = '';
                                            highlightedRoomName = null;
                                          });
                                        },
                                      )
                                      : null,
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.primary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val.trim();
                                if (searchQuery.isEmpty) {
                                  highlightedRoomName = null;
                                } else {
                                  // Find the first room that matches (case-insensitive)
                                  final Map<String, dynamic> found = parsedRooms
                                      .firstWhere(
                                        (room) => room['name']
                                            .toString()
                                            .toLowerCase()
                                            .trim()
                                            .startsWith(
                                              searchQuery.toLowerCase(),
                                            ),
                                        orElse: () => <String, Object>{},
                                      );
                                  highlightedRoomName =
                                      found.isNotEmpty ? found['name'] : null;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton:
                  showingBlock && blockFloors.isNotEmpty
                      ? FloatingActionButton.extended(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).primaryColor,
                        heroTag: 'floor_nav',
                        icon: const Icon(Icons.layers),
                        label: Text(
                          'Floor ${blockFloors[selectedFloorIndex]['floor']}',
                        ),
                        onPressed: () async {
                          final selected = await showModalBottomSheet<int>(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min, // <- This makes the sheet wrap its content
                                  children: List.generate(
                                    blockFloors.length,
                                    (idx) => ListTile(
                                      title: Text(
                                        'Floor ${blockFloors[idx]['floor']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      selected: idx == selectedFloorIndex,
                                      selectedColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.blueAccent
                                              : Color(0xFFB5FD06),
                                      onTap: () async {
                                        await checkingConnect();
                                        if (!isConnected) {
                                          _showErrorMessage(
                                            "No connection! Can't do anything.",
                                          );
                                          return;
                                        }
                                        if (!context.mounted) return;
                                        Navigator.pop(context, idx);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          if (selected != null &&
                              selected != selectedFloorIndex) {
                            await switchBlockFloor(selected);
                          }
                          setState(() => isBlockLoading = false);
                        },
                      )
                      : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 0.5,
                      maxScale: 7.0,
                      child: FittedBox(
                        child: SizedBox(
                          width: originalSvgWidth,
                          height: constraints.maxHeight,
                          child: Center(
                            child: Stack(
                              children: [
                                if (rawSvg != null)
                                  SvgPicture.string(
                                    rawSvg!,
                                    width: originalSvgWidth,
                                    height: originalSvgHeight,
                                    fit: BoxFit.fill,
                                  ),
                                ...parsedRooms.map((room) {
                                  final isHighlighted =
                                      highlightedRoomName != null &&
                                      room['name'].toString().toLowerCase() ==
                                          highlightedRoomName!.toLowerCase();
                                  return Positioned(
                                    left: room['x'],
                                    top: room['y'],
                                    child: GestureDetector(
                                      onTap: () async {
                                        await checkingConnect();
                                        if (!isConnected) {
                                          _showErrorMessage(
                                            "no connection! Can't do Anything",
                                          );
                                          return;
                                        }
                                        handleRoomTap(room);
                                      },
                                      child: Container(
                                        width: room['width'],
                                        height: room['height'],
                                        decoration: BoxDecoration(
                                          color:
                                              isHighlighted
                                                  ? Colors.yellow.withAlpha(120)
                                                  : Colors.transparent,
                                          border:
                                              isHighlighted
                                                  ? Border.all(
                                                    color: Colors.orange,
                                                    width: 3,
                                                  )
                                                  : null,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showingBlock)
                    Positioned(
                      left: 16,
                      top: 32 + MediaQuery.of(context).padding.top,
                      child: FloatingActionButton(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).primaryColor,
                        heroTag: 'back_main_map',
                        mini: true,
                        onPressed: backToMainMap,
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color:
                            showingBlock ? Colors.black26 : Colors.transparent,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
  }
}
