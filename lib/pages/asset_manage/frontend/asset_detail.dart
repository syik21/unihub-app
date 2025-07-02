import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/pages/asset_manage/backend/asset_service.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class AssetDetailPage extends StatefulWidget {
  final String assetCode;
  const AssetDetailPage({super.key, required this.assetCode});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();

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
          style: Theme.of(context).textTheme.labelSmall,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: gap),
        Text(":", style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 20),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.labelSmall),
        ),
      ],
    );
  }
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final GlobalKey _barcodeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Asset Details",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      body: FutureBuilder(
        future: fetchAssetByCode(widget.assetCode),
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
            return const Center(child: Text('No asset found'));
          } else {
            final asset = snapshot.data![0];
            final code = asset['code'];
            final purchaseDate = formatTimestamp('${asset['purchased_date']}');
            final lastMaintenance = formatTimestamp(
              '${asset['last_maintenance']}',
            );
            final imageUrl = asset['image_url'];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (imageUrl != null)
                  GestureDetector(
                    onTap: () => _showImageDialog(imageUrl),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    code.replaceAll('br', '').trim(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nura',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.cardDecoration(context),
                  child: Column(
                    children: [
                      _detailTile(
                        Icons.category,
                        "Category",
                        asset['category'],
                      ),
                      _detailTile(Icons.label, "Name", asset['name']),
                      _detailTile(
                        Icons.location_on,
                        "Location",
                        asset['room']?['name'] ?? "-",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Condition",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 12),
                            _conditionChip(asset['condition']),
                          ],
                        ),
                      ),
                      _detailTile(
                        Icons.calendar_today,
                        "Order Date",
                        purchaseDate,
                      ),
                      _detailTile(Icons.build, "Last Service", lastMaintenance),
                      _detailTile(
                        Icons.person,
                        "Last Modified By",
                        asset['user']?['name'] ?? "-",
                      ),
                      const Divider(height: 32),
                      // Barcode
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            RepaintBoundary(
                              key: _barcodeKey,
                              child: BarcodeWidget(
                                color: Theme.of(context).colorScheme.tertiary,
                                barcode: Barcode.code128(),
                                data: asset['code'],
                                width: 220,
                                height: 60,
                                drawText: false,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              code.toString().replaceAll('br', '').trim(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 1.1,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _downloadBarcode(asset['code']),
                    child: Text(
                      "DOWNLOAD BARCODE",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () => _showEditDialog(asset),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        onPressed: () => _deleteAsset(asset['code']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14141E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: InteractiveViewer(
                          child: Image.network(imageUrl, fit: BoxFit.contain),
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

  Future<void> _downloadBarcode(String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary? boundary =
          _barcodeKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (!mounted) return;
      if (boundary == null) {
        AppDecorations.showTopSnackBar(
          context,
          'Barcode not rendered yet, try again.',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
        return;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (!mounted) return;
      if (byteData == null) {
        AppDecorations.showTopSnackBar(
          context,
          'Failed to generate barcode image.',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$code-barcode.png');
      await file.writeAsBytes(pngBytes);
      if (!mounted) return;
      AppDecorations.showTopSnackBar(
        context,
        'Barcode saved to ${file.path}',
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      AppDecorations.showTopSnackBar(
        context,
        'Failed to save/open barcode: $e',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssetByCode(String code) async {
    final data = await Supabase.instance.client
        .from('asset')
        .select('*, user(*), room(name)')
        .eq('code', code);
    final assets = data.cast<Map<String, dynamic>>();
    for (final asset in assets) {
      final imagePath = asset['image'];
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        asset['image_url'] = await getImageUrl(imagePath);
      } else {
        asset['image_url'] = null;
      }
    }
    return assets;
  }

  Future<void> _deleteAsset(String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Asset"),
            content: const Text("Are you sure you want to delete this asset?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    final success = await AssetService(
      Supabase.instance.client,
    ).deleteAssetByCode(code);
    if (!mounted) return;
    if (success) {
      AppDecorations.showTopSnackBar(
        context,
        "Asset deleted.",
        backgroundColor: Colors.green,
        icon: Icons.check_circle,
      );
      Navigator.pop(context, true); // Go back to list
    } else {
      AppDecorations.showTopSnackBar(
        context,
        "Failed to delete asset.",
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> asset) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => _EditAssetDialog(
            assetCode: asset['code'],
            initialCondition: asset['condition'],
            initialRoomName: asset['room']?['name'] ?? '',
            initialMaintenance:
                DateTime.tryParse(asset['last_maintenance'] ?? '') ??
                DateTime.now(),
          ),
    );
    if (!mounted) return;
    if (result == true) {
      setState(() {}); // Refresh page
    }
  }

  Widget _conditionChip(String condition) {
    Color color;
    Color bgColor;
    IconData icon;
    String label = condition;
    switch (condition.toLowerCase()) {
      case 'good':
        color = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        icon = Icons.check_circle;
        label = 'Good';
        break;
      case 'under maintenance':
        color = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        icon = Icons.build_circle;
        label = 'Under Maintenance';
        break;
      case 'damaged':
        color = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        icon = Icons.error;
        label = 'Damaged';
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade200;
        icon = Icons.help_outline;
    }
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditAssetDialog extends StatefulWidget {
  final String assetCode;
  final String initialCondition;
  final String initialRoomName;
  final DateTime initialMaintenance;
  const _EditAssetDialog({
    required this.assetCode,
    required this.initialCondition,
    required this.initialRoomName,
    required this.initialMaintenance,
  });

  @override
  State<_EditAssetDialog> createState() => _EditAssetDialogState();
}

class _EditAssetDialogState extends State<_EditAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  late String condition;
  late String roomName;
  late DateTime maintenanceDate;
  bool isLoading = false;
  final List<String> conditionOptions = [
    'good',
    'damaged',
    'under maintenance',
  ];

  @override
  void initState() {
    super.initState();
    condition = widget.initialCondition;
    roomName = widget.initialRoomName;
    maintenanceDate = widget.initialMaintenance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Asset"),
      content: StatefulBuilder(
        builder:
            (context, setState) => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      decoration: const InputDecoration(labelText: 'Condition'),
                    ),
                    TextFormField(
                      initialValue: roomName,
                      decoration: const InputDecoration(labelText: 'Room Name'),
                      onSaved: (v) => roomName = v ?? '',
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Enter room name' : null,
                    ),
                    ListTile(
                      title: Text(
                        'Last Maintenance: ${maintenanceDate.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: maintenanceDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => maintenanceDate = picked);
                        }
                      },
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
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
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() => isLoading = true);

                      final service = AssetService(Supabase.instance.client);
                      final titleRoomName = service.toTitleCase(
                        roomName.trim(),
                      );
                      final rooms = await Supabase.instance.client
                          .from('room')
                          .select('id')
                          .ilike('name', titleRoomName);
                      if (!mounted) return;
                      if (rooms.isEmpty) {
                        setState(() => isLoading = false);
                        if (!context.mounted) return;
                        AppDecorations.showTopSnackBar(
                          context,
                          'Room not found!',
                          backgroundColor: Colors.red,
                          icon: Icons.error,
                        );
                        return;
                      }
                      final roomId = rooms[0]['id'] as String;

                      final updateSuccess = await service.updateAssetByCode(
                        code: widget.assetCode,
                        condition: condition,
                        roomId: roomId,
                        lastMaintenance: maintenanceDate,
                      );
                      if (!context.mounted) return;
                      setState(() => isLoading = false);
                      Navigator.pop(context, updateSuccess);
                    }
                  },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
