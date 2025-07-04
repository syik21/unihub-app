import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/asset_manage/backend/asset_service.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_category.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_detail.dart';
import 'package:unihub/pages/user-profile/auth_user.dart'; // <-- Import your provider
import 'package:unihub/theme/custom/app_decoration.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:unihub/pages/scanner/scan_camera_section.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unihub/pages/main/scan_page.dart' show ScanMode;

class AssetInventory extends StatefulWidget {
  const AssetInventory({super.key});

  @override
  State<AssetInventory> createState() => AssetInventoryState();
}

class AssetInventoryState extends State<AssetInventory> {
  int selectedTab = 0; // 0: Asset, 1: Scanner
  List<Map<String, dynamic>> assets = [];
  bool isLoading = true;
  String searchQuery = '';
  final ValueNotifier<ScanMode> scanMode = ValueNotifier(ScanMode.barcode);
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );

  @override
  void initState() {
    super.initState();
    _fetchAssets();
    checkingconnection();
  }

  Future<void> _fetchAssets() async {
    setState(() => isLoading = true);
    final fetchedAssets =
        await AssetService(
          Supabase.instance.client,
        ).fetchAssetCategoriesWithCount();
    setState(() {
      assets = fetchedAssets;
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
                        (a, b) => (a['category'] as String).compareTo(
                          b['category'] as String,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.numbers),
                  title: Text('Sort by Quantity'),
                  onTap: () {
                    setState(() {
                      assets.sort(
                        (a, b) => (b['quantity'] as int).compareTo(
                          a['quantity'] as int,
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

  void _goToAddAsset() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddAssetDialog(),
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
          return (asset['category'] as String).toLowerCase().contains(
            searchQuery,
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
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
        child: SafeArea(
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
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'ASSET INVENTORY',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Toggle
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => selectedTab = 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              selectedTab == 0
                                                  ? Theme.of(
                                                    context,
                                                  ).primaryColor
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'ASSET',
                                          style: TextStyle(
                                            fontFamily: 'Nura',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color:
                                                selectedTab == 0
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                    : Theme.of(
                                                      context,
                                                    ).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => selectedTab = 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              selectedTab == 1
                                                  ? Theme.of(
                                                    context,
                                                  ).primaryColor
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'SCANNER',
                                          style: TextStyle(
                                            fontFamily: 'Nura',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color:
                                                selectedTab == 1
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                    : Theme.of(
                                                      context,
                                                    ).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedTab == 0) ...[
                        // Asset content
                        Container(
                          margin: const EdgeInsets.all(24),
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
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  onPressed: _showSortOptions,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              isLoading
                                  ? Center(
                                    child: CircularProgressIndicator(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : Colors.grey[300],
                                    ),
                                  )
                                  : filteredAssets.isEmpty
                                  ? const Center(
                                    child: Text('No assets found.'),
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
                                                  (context) =>
                                                      SelectedAssetCategories(
                                                        category:
                                                            asset['category'],
                                                      ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 30,
                                            right: 30,
                                            bottom: 11,
                                            top: 7,
                                          ),
                                          decoration:
                                              AppDecorations.cardDecoration(
                                                context,
                                              ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                _getCategoryIcon(
                                                  asset['category'] as String,
                                                ),
                                                size: 40,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                              ),
                                              const SizedBox(width: 24),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    asset['category'] as String,
                                                    style:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'Type: ${asset['type'] ?? "-"}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                  Text(
                                                    'QUANTITY: ${asset['quantity']}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ],
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
                        const SizedBox(height: 20),
                      ] else ...[
                        // Scanner content
                        const SizedBox(height: 20),
                        Text(
                          "Search asset",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Place a asset barcode in the area to find its details.",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: ScanCameraSection(
                              controller: scannerController,
                              mode: scanMode,
                              qrFunction: (value) async {},
                              brFunction: handleBrScan,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      iconColor: Colors.white,
    );
  }

  Future<void> handleBrScan(String value) async {
    AppDecorations.showLoadingDialog(context, message: "Checking Barcode...");
    await checkingConnect();
    if (!mounted) return;
    if (!isConnected) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorMessage("No connection");
      return;
    }
    final assetList = await Supabase.instance.client
        .from('asset')
        .select()
        .eq('code', value)
        .limit(1);
    if (!mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (assetList.isEmpty) {
      if (mounted) {
        AppDecorations.showTopSnackBar(
          context,
          'Asset not found for barcode: $value',
          backgroundColor: Colors.red,
          icon: Icons.error,
          iconColor: Colors.white,
        );
      }
      return;
    }

    final asset = assetList[0];
    if (asset['condition'] != 'good') {
      if (mounted) {
        AppDecorations.showTopSnackBar(
          context,
          'Asset is not in good condition: ${asset['condition']}',
          backgroundColor: Colors.orange,
          icon: Icons.warning,
          iconColor: Colors.white,
        );
      }
      // Optionally: return here if you don't want to allow navigation
      // return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailPage(assetCode: value),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('computer') ||
        lower.contains('laptop') ||
        lower.contains('pc')) {
      return Icons.computer;
    } else if (lower.contains('printer')) {
      return Icons.print;
    } else if (lower.contains('projector')) {
      return Icons.videocam;
    } else if (lower.contains('chair') || lower.contains('seat')) {
      return Icons.chair;
    } else if (lower.contains('table') || lower.contains('desk')) {
      return Icons.table_bar;
    } else if (lower.contains('monitor') || lower.contains('display')) {
      return Icons.tv;
    } else if (lower.contains('router') || lower.contains('network')) {
      return Icons.router;
    } else if (lower.contains('phone')) {
      return Icons.phone_android;
    } else if (lower.contains('camera')) {
      return Icons.photo_camera;
    } else if (lower.contains('light') || lower.contains('lamp')) {
      return Icons.lightbulb;
    } else if (lower.contains('board') || lower.contains('whiteboard')) {
      return Icons.border_color;
    } else if (lower.contains('fan')) {
      return Icons.toys;
    } else if (lower.contains('aircon') || lower.contains('ac')) {
      return Icons.ac_unit;
    } else if (lower.contains('scanner')) {
      return Icons.document_scanner;
    } else if (lower.contains('speaker')) {
      return Icons.speaker;
    } else if (lower.contains('mic') || lower.contains('microphone')) {
      return Icons.mic;
    } else if (lower.contains('lock')) {
      return Icons.lock;
    } else if (lower.contains('cabinet')) {
      return Icons.kitchen;
    } else if (lower.contains('key')) {
      return Icons.vpn_key;
    } else {
      return Icons.devices_other;
    }
  }
}

class AddAssetDialog extends StatefulWidget {
  const AddAssetDialog({super.key});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String category = '';
  String? newCategory;
  String type = 'electronic';
  String condition = 'good';
  String roomName = '';
  String? selectedRoomId;
  String? selectedRoomName;
  bool roomEmpty = false;
  File? pickedImage;
  String? uploadedImagePath;
  DateTime purchasedDate = DateTime.now();
  DateTime lastMaintenance = DateTime.now();
  bool isLoading = false;
  List<String> categoryOptions = [];
  List<String> typeOptions = ['electronic', 'furniture'];
  List<String> conditionOptions = ['good', 'maintenance'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategoryOptions();
  }

  Future<void> _fetchCategoryOptions() async {
    final service = AssetService(Supabase.instance.client);
    final fetched = await service.fetchCategoryOptions();
    setState(() {
      categoryOptions = [...fetched, 'Add new category'];
      if (categoryOptions.isNotEmpty) {
        category = categoryOptions.first;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      final fileBytes = await file.length(); // size in bytes
      final fileExtension = picked.path.split('.').last.toLowerCase();
      if (!mounted) return;

      // ✅ Validate file type
      if (fileExtension != 'jpg' &&
          fileExtension != 'jpeg' &&
          fileExtension != 'png') {
        _showErrorMessage("Only JPG and PNG images are allowed.");
        return;
      }

      // ✅ Validate file size (max 50MB)
      const maxFileSize = 50 * 1024 * 1024; // 50MB in bytes
      if (fileBytes > maxFileSize) {
        _showErrorMessage("Image must be 50MB or smaller.");
        return;
      }

      // ✅ Valid image: update UI
      setState(() {
        pickedImage = file;
      });
    }
  }

  void _showErrorMessage(String message) {
    AppDecorations.showTopSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
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
      _showErrorMessage('Failed to upload image');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isAddingNewCategory = category == 'Add new category';
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'ADD New ASSET',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ), // When focused
                    ),
                  ),
                  onSaved: (v) => name = v?.toLowerCase() ?? '',
                  validator:
                      (v) => v == null || v.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: Theme.of(context).textTheme.bodyLarge,
                  value: categoryOptions.contains(category) ? category : null,
                  items: [
                    ...categoryOptions.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      category = v ?? category;
                      if (category != 'Add new category') newCategory = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ), // When focused
                    ),
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? "Select category" : null,
                ),
                if (isAddingNewCategory)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'New Category',
                        labelStyle: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          ), // When focused
                        ),
                      ),
                      onChanged: (v) => newCategory = v.toLowerCase(),
                      onSaved: (v) => newCategory = v?.toLowerCase(),
                      validator:
                          (v) =>
                              isAddingNewCategory && (v == null || v.isEmpty)
                                  ? "Enter new category"
                                  : null,
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: Theme.of(context).textTheme.bodyLarge,
                  value: type,
                  items:
                      typeOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ), // When focused
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: Theme.of(context).textTheme.bodyLarge,
                  value: condition,
                  items:
                      conditionOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => condition = v ?? condition),
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ), // When focused
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROOM',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final room = await _showRoomSelectionDialog(context);
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
                                      : Theme.of(context).colorScheme.primary
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
                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder:
                            (context) => SimpleDialog(
                              backgroundColor: Theme.of(context).primaryColor,
                              title: Text(
                                'Select Image Source',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              children: [
                                SimpleDialogOption(
                                  onPressed:
                                      () => Navigator.pop(context, 'camera'),
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
                                      () => Navigator.pop(context, 'gallery'),
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
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Purchased Date: ${purchasedDate.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: purchasedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => purchasedDate = picked);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Last Maintenance: ${lastMaintenance.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: lastMaintenance,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => lastMaintenance = picked);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please fill in all required fields.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  _formKey.currentState!.save();
                                  if (name.trim().isEmpty) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please enter a name.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (category.isEmpty) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please select a category.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (isAddingNewCategory &&
                                      (newCategory == null ||
                                          newCategory!.trim().isEmpty)) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please enter a new category.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (type.isEmpty) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please select a type.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (condition.isEmpty) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please select a condition.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (selectedRoomId == null) {
                                    setState(() => roomEmpty = true);
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please select a room.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  if (pickedImage == null) {
                                    AppDecorations.showTopSnackBar(
                                      context,
                                      'Please select an image.',
                                      backgroundColor: Colors.red,
                                      icon: Icons.error,
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);
                                  final roomId = selectedRoomId!;
                                  final userId =
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      ).userId;
                                  String finalCategory =
                                      isAddingNewCategory &&
                                              newCategory != null &&
                                              newCategory!.isNotEmpty
                                          ? newCategory!.trim()
                                          : category;
                                  String? imagePath;
                                  if (pickedImage != null) {
                                    imagePath = await _uploadImage(
                                      pickedImage!,
                                    );
                                    if (imagePath == null) {
                                      setState(() => isLoading = false);
                                      return;
                                    }
                                  }
                                  final service = AssetService(
                                    Supabase.instance.client,
                                  );
                                  final success = await service.addAsset(
                                    userId: userId,
                                    roomId: roomId,
                                    name: name.toLowerCase(),
                                    category: finalCategory.toLowerCase(),
                                    type: type.toLowerCase(),
                                    condition: condition.toLowerCase(),
                                    image: imagePath,
                                    purchasedDate: purchasedDate,
                                    lastMaintenance: lastMaintenance,
                                  );
                                  setState(() => isLoading = false);
                                  if (success) {
                                    if (context.mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  } else {
                                    _showErrorMessage('Failed to add asset!');
                                  }
                                },
                        child: Text(
                          'Add',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select a Room',
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search room...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 2,
                                  ), // When focused
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
                                      (_, val) => Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final room = filteredRooms[index];
                                    return ListTile(
                                      title: Text(
                                        room['name'],
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                      ),
                                      onTap: () => Navigator.pop(context, room),
                                    );
                                  },
                                ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }
}
