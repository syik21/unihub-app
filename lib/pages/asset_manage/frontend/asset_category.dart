import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_detail.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/pages/asset_manage/backend/asset_service.dart';
import 'package:unihub/pages/user-profile/auth_user.dart'; // <-- Make sure to import for Provider
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SelectedAssetCategories extends StatefulWidget {
  final String category;
  const SelectedAssetCategories({super.key, required this.category});

  @override
  State<SelectedAssetCategories> createState() =>
      _SelectedAssetCategoriesState();
}

class _SelectedAssetCategoriesState extends State<SelectedAssetCategories> {
  List<Map<String, dynamic>> assets = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() => isLoading = true);
    final data = await Supabase.instance.client
        .from('asset')
        .select('*, room(name)')
        .eq('category', widget.category);
    setState(() {
      assets = (data as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  void _searchAssets(String value) {
    setState(() {
      searchQuery = value.trim().toLowerCase();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.sort_by_alpha),
                  title: Text('Sort by Name'),
                  onTap: () {
                    setState(() {
                      assets.sort(
                        (a, b) => (a['name'] as String).compareTo(
                          b['name'] as String,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.numbers),
                  title: Text('Sort by Code'),
                  onTap: () {
                    setState(() {
                      assets.sort(
                        (a, b) => (a['code'] as String).compareTo(
                          b['code'] as String,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _goToAddAsset() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddAssetDialog(initialCategory: widget.category),
    );
    if (result == true) {
      _fetchAssets();
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

  @override
  Widget build(BuildContext context) {
    final filteredAssets =
        assets.where((asset) {
          if (searchQuery.isEmpty) return true;
          return (asset['name'] as String).toLowerCase().contains(
                searchQuery,
              ) ||
              (asset['code'] as String).toLowerCase().contains(searchQuery);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Back to inventory",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
          await checkingConnect();
          if (isConnected) {
            await _fetchAssets();
            setState(() {});
          }
        },
        child:
            !isConnected
                ? NoConnectionPage(
                  function: () async {
                    await checkingConnect();
                    if (isConnected) {
                      await _fetchAssets();
                      setState(() {});
                    }
                  },
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.category.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: AppDecorations.cardDecoration(context),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: _searchAssets,
                                cursorColor:
                                    Theme.of(context).colorScheme.secondary,
                                decoration: InputDecoration(
                                  hintText: 'SEARCH AN ASSET',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.tune,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                onPressed: _showSortOptions,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Result count
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "RESULT: ${filteredAssets.length}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Asset List
                      Expanded(
                        child:
                            isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : filteredAssets.isEmpty
                                ? const Center(
                                  child: Text('No asset in this category.'),
                                )
                                : ListView.separated(
                                  itemCount: filteredAssets.length,
                                  separatorBuilder:
                                      (_, _) => const SizedBox(height: 0),
                                  itemBuilder: (context, index) {
                                    final asset = filteredAssets[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => AssetDetailPage(
                                                  assetCode: asset['code'],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          bottom: 11,
                                          top: 7,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration:
                                            AppDecorations.cardDecoration(
                                              context,
                                            ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.computer,
                                              size: 30,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                            ),
                                            const SizedBox(width: 18),
                                            // Asset details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    asset['code']
                                                            ?.toString()
                                                            .replaceAll(
                                                              "br",
                                                              "",
                                                            )
                                                            .trim() ??
                                                        "",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    asset['name'] ?? "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "LOCATION  :  ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      Text(
                                                        asset['room']?['name'] ??
                                                            '-',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "CONDITION :  ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      Text(
                                                        asset['condition'] ??
                                                            "-",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 12,
                                                          color:
                                                              asset['condition'] ==
                                                                      "good"
                                                                  ? Colors.green
                                                                  : (asset['condition'] ==
                                                                          "maintenance"
                                                                      ? Colors
                                                                          .orange
                                                                      : Colors
                                                                          .red),
                                                          letterSpacing: 1.1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // More icon
                                            Icon(
                                              Icons.more_vert,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      // Floating Add Button
                      Center(
                        child: GestureDetector(
                          onTap: _goToAddAsset,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                              size: 36,
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

// AddAssetDialog widget with initialCategory support
class AddAssetDialog extends StatefulWidget {
  final String? initialCategory;
  const AddAssetDialog({super.key, this.initialCategory});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String category = '';
  String type = 'electronic';
  String condition = 'good';
  String roomName = '';
  File? pickedImage;
  String? uploadedImagePath;
  DateTime purchasedDate = DateTime.now();
  DateTime lastMaintenance = DateTime.now();
  bool isLoading = false;
  List<String> categoryOptions = [];
  List<String> typeOptions = ['electronic', 'physical'];
  List<String> conditionOptions = ['good', 'damaged', 'under maintenance'];
  final ImagePicker _picker = ImagePicker();
  String? selectedRoomId;
  String? selectedRoomName;
  bool roomEmpty = false;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoryOptions();
  }

  Future<void> _fetchCategoryOptions() async {
    final service = AssetService(Supabase.instance.client);
    final fetched = await service.fetchCategoryOptions();
    setState(() {
      categoryOptions = fetched;
      if (widget.initialCategory != null &&
          fetched.contains(widget.initialCategory)) {
        category = widget.initialCategory!;
      } else if (fetched.isNotEmpty) {
        category = fetched.first;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await file.readAsBytes();
      final response = await Supabase.instance.client.storage
          .from('image')
          .uploadBinary('asset/$fileName', bytes);
      if (response.isNotEmpty) {
        return 'asset/$fileName';
      }
    } catch (e) {
      AppDecorations.showTopSnackBar(
        context,
        'Failed to upload image',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Asset'),
      content: StatefulBuilder(
        builder:
            (context, setState) => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onSaved: (v) => name = v ?? '',
                      validator:
                          (v) => v == null || v.isEmpty ? "Enter name" : null,
                    ),
                    DropdownButtonFormField<String>(
                      value:
                          categoryOptions.contains(category) ? category : null,
                      items:
                          categoryOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged:
                          widget.initialCategory == null
                              ? (v) => setState(() => category = v ?? category)
                              : null,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? "Select category" : null,
                      disabledHint:
                          widget.initialCategory != null
                              ? Text(widget.initialCategory!)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROOM',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final room = await _showRoomSelectionDialog(
                              context,
                            );
                            if (room != null) {
                              setState(() {
                                selectedRoomId = room['id'];
                                selectedRoomName = room['name'];
                                roomEmpty = false;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: AppDecorations.cardDecoration(
                              context,
                            ).copyWith(
                              color:
                                  roomEmpty
                                      ? Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.red[100]
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary
                                      : Theme.of(context).colorScheme.primary,
                              border: Border.all(
                                color:
                                    roomEmpty
                                        ? Colors.red.withAlpha(100)
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedRoomName?.isNotEmpty == true
                                        ? selectedRoomName!
                                        : 'Select a room...',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium?.copyWith(
                                      color:
                                          selectedRoomName == null
                                              ? roomEmpty
                                                  ? Colors.red[300]
                                                  : Colors.grey
                                              : Theme.of(
                                                context,
                                              ).textTheme.labelMedium?.color,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.search),
                              ],
                            ),
                          ),
                        ),
                        if (roomEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3, left: 10),
                            child: Text(
                              'Please select a room',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontFamily: "Nura",
                              ),
                            ),
                          ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: type,
                      items:
                          typeOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => type = v ?? type),
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                    DropdownButtonFormField<String>(
                      value: condition,
                      items:
                          conditionOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged:
                          (v) => setState(() => condition = v ?? condition),
                      decoration: InputDecoration(labelText: 'Condition'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder:
                                    (context) => SimpleDialog(
                                      title: const Text('Select Image Source'),
                                      children: [
                                        SimpleDialogOption(
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                                'camera',
                                              ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.photo_camera),
                                              SizedBox(width: 8),
                                              Text('Camera'),
                                            ],
                                          ),
                                        ),
                                        SimpleDialogOption(
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                                'gallery',
                                              ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.photo_library),
                                              SizedBox(width: 8),
                                              Text('Gallery'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (result == 'camera') {
                                await _pickImage(ImageSource.camera);
                              } else if (result == 'gallery') {
                                await _pickImage(ImageSource.gallery);
                              }
                              setState(() => _imageError = false);
                            },
                            child:
                                pickedImage != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        pickedImage!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color:
                                            _imageError
                                                ? Colors.red[100]
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            _imageError
                                                ? Border.all(
                                                  color: Colors.red,
                                                  width: 2,
                                                )
                                                : null,
                                      ),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                    ),
                          ),
                          if (_imageError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Please select an image',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Purchased Date: ${purchasedDate.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: purchasedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => purchasedDate = picked);
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Last Maintenance: ${lastMaintenance.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: lastMaintenance,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => lastMaintenance = picked);
                      },
                    ),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() => isLoading = true);
                      // For roomId lookup
                      final rooms = await Supabase.instance.client
                          .from('room')
                          .select('id')
                          .ilike('name', selectedRoomName!);
                      if (rooms.isEmpty) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Room not found!')),
                        );
                        return;
                      }
                      final roomId = rooms[0]['id'] as String;
                      // --------- FIX: use Provider for userId ---------
                      final userId =
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).userId;
                      if (userId == null) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'User not found! Please log in again.',
                            ),
                          ),
                        );
                        return;
                      }
                      String? imagePath;
                      if (pickedImage == null) {
                        setState(() {
                          _imageError = true;
                          isLoading = false;
                        });
                        AppDecorations.showTopSnackBar(
                          context,
                          'Please select an image.',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                        return;
                      } else {
                        setState(() => _imageError = false);
                        imagePath = await _uploadImage(pickedImage!);
                        if (imagePath == null) {
                          setState(() => isLoading = false);
                          return;
                        }
                      }
                      final service = AssetService(Supabase.instance.client);
                      final success = await service.addAsset(
                        userId: userId,
                        roomId: roomId,
                        name: name,
                        category: category,
                        type: type,
                        condition: condition,
                        image: imagePath,
                        purchasedDate: purchasedDate,
                        lastMaintenance: lastMaintenance,
                      );
                      setState(() => isLoading = false);
                      if (success) {
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add asset!')),
                        );
                      }
                    }
                  },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showRoomSelectionDialog(
    BuildContext context,
  ) async {
    final rooms = await Supabase.instance.client
        .from('room')
        .select('id, name')
        .order('name');
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String search = '';
        List<Map<String, dynamic>> filteredRooms = List.from(rooms);
        return StatefulBuilder(
          builder:
              (context, setState) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select a Room',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search room...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  search = value.trim().toLowerCase();
                                  filteredRooms =
                                      rooms
                                          .where(
                                            (room) => (room['name'] as String)
                                                .toLowerCase()
                                                .contains(search),
                                          )
                                          .toList();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child:
                            filteredRooms.isEmpty
                                ? Center(child: Text('No rooms found.'))
                                : ListView.separated(
                                  itemCount: filteredRooms.length,
                                  separatorBuilder:
                                      (_, __) => Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final room = filteredRooms[index];
                                    return ListTile(
                                      title: Text(room['name']),
                                      onTap: () => Navigator.pop(context, room),
                                    );
                                  },
                                ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
