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
    const double lineSpacing = 16;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "back to list",
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
            final code = asset['code']; // don't modify!
            final purchaseDate = formatTimestamp('${asset['purchased_date']}');
            final lastMaintenance = formatTimestamp(
              '${asset['last_maintenance']}',
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Asset ID
                  Text(
                    code.replaceAll('br', '').trim(), // display as before
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: 1.5,
                      fontFamily: 'Nura',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      AssetDetailPage.lableText(
                        context,
                        "Category",
                        75,
                        asset['category'],
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "Name",
                        106,
                        asset['name'],
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "Location",
                        80,
                        asset['room']?['name'] ?? "-",
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "Condition",
                        75,
                        asset['condition'],
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "Order Date",
                        62,
                        purchaseDate,
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "last service",
                        49,
                        lastMaintenance,
                      ),
                      const SizedBox(height: lineSpacing),
                      AssetDetailPage.lableText(
                        context,
                        "Last Modified By",
                        19,
                        asset['user']?['name'] ?? "-",
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Barcode
                  Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Center(
                          child: Column(
                            children: [
                              // Barcode widget wrapped in RepaintBoundary for download
                              RepaintBoundary(
                                key: _barcodeKey,
                                child: BarcodeWidget(
                                  barcode: Barcode.code128(),
                                  data: asset['code'],
                                  width: 220,
                                  height: 60,
                                  drawText: false,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                code.replaceAll('br', '').trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Download Barcode Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
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
                  // Row for Edit and Delete (clickable)
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
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _downloadBarcode(String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary? boundary =
          _barcodeKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode not rendered yet, try again.')),
        );
        return;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate barcode image.')),
        );
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$code-barcode.png');
      await file.writeAsBytes(pngBytes);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Barcode saved to ${file.path}')));
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save/open barcode: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssetByCode(String code) async {
    final data = await Supabase.instance.client
        .from('asset')
        .select('*, user(*), room(name)')
        .eq('code', code); // don't modify!
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> _deleteAsset(String code) async {
    print("Deleting asset with code: '$code'"); // debug print
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
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Asset deleted.")));
      Navigator.pop(context, true); // Go back to list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete asset.")));
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
    if (result == true) {
      setState(() {}); // Refresh page
    }
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
                        if (picked != null)
                          setState(() => maintenanceDate = picked);
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
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: isLoading
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
                    if (rooms.isEmpty) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Room not found!')),
                      );
                      return;
                    }
                    final roomId = rooms[0]['id'] as String;

                    print("Updating asset with code: '${widget.assetCode}'"); // debug print
                    final updateSuccess = await service.updateAssetByCode(
                      code: widget.assetCode,
                      condition: condition,
                      roomId: roomId,
                      lastMaintenance: maintenanceDate,
                    );
                    setState(() => isLoading = false);
                    Navigator.pop(context, updateSuccess);
                  }
                },
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}