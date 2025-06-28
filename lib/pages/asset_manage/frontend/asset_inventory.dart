import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/pages/asset_manage/backend/asset_service.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_category.dart';
import 'package:unihub/pages/user-profile/auth_user.dart'; // <-- Import your provider
import 'package:unihub/theme/custom/app_decoration.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() => isLoading = true);
    final fetchedAssets =
        await AssetService(Supabase.instance.client).fetchAssetCategoriesWithCount();
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sort_by_alpha),
              title: Text('Sort by Name'),
              onTap: () {
                setState(() {
                  assets.sort((a, b) => (a['category'] as String).compareTo(b['category'] as String));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.numbers),
              title: Text('Sort by Quantity'),
              onTap: () {
                setState(() {
                  assets.sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
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

  @override
  Widget build(BuildContext context) {
    final filteredAssets = assets.where((asset) {
      if (searchQuery.isEmpty) return true;
      return (asset['category'] as String).toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ASSET INVENTORY',
                      style: Theme.of(context).textTheme.headlineLarge,
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
                            onTap: () => setState(() => selectedTab = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Text(
                                'ASSET',
                                style: TextStyle(
                                  fontFamily: 'Nura',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: selectedTab == 0
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Text(
                                'SCANNER',
                                style: TextStyle(
                                  fontFamily: 'Nura',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: selectedTab == 1
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // All Asset label
                  Text(
                    'ALL ASSET',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    decoration: AppDecorations.cardDecoration(context),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.search, color: Theme.of(context).colorScheme.tertiary),
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: _searchAssets,
                            cursorColor: Theme.of(context).colorScheme.secondary,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: IconButton(
                            icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.tertiary),
                            onPressed: _showSortOptions,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAssets.isEmpty
                      ? const Center(child: Text('No assets found.'))
                      : ListView.separated(
                          itemCount: filteredAssets.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            final asset = filteredAssets[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectedAssetCategories(
                                      category: asset['category'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 30, right: 30, bottom: 11, top: 7),
                                decoration: AppDecorations.cardDecoration(context),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.computer, size: 40, color: Theme.of(context).colorScheme.tertiary),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          asset['category'] as String,
                                          style: Theme.of(context).textTheme.headlineMedium,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Type: ${asset['type'] ?? "-"}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                        ),
                                        Text(
                                          'QUANTITY: ${asset['quantity']}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
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
  String type = 'electronic';
  String condition = 'good';
  String roomName = '';
  String? image;
  DateTime purchasedDate = DateTime.now();
  DateTime lastMaintenance = DateTime.now();
  bool isLoading = false;
  List<String> categoryOptions = [];
  List<String> typeOptions = ['electronic', 'physical'];
  List<String> conditionOptions = ['good', 'damaged', 'under maintenance'];

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
      if (categoryOptions.isNotEmpty) {
        category = categoryOptions.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Asset'),
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (v) => name = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
                ),
                DropdownButtonFormField<String>(
                  value: categoryOptions.contains(category) ? category : null,
                  items: categoryOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => category = v ?? category),
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (v) => v == null || v.isEmpty ? "Select category" : null,
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  items: typeOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                DropdownButtonFormField<String>(
                  value: condition,
                  items: conditionOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => condition = v ?? condition),
                  decoration: InputDecoration(labelText: 'Condition'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Room Name'),
                  onSaved: (v) => roomName = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? "Enter room name" : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Image URL (optional)'),
                  onSaved: (v) => image = v,
                ),
                ListTile(
                  title: Text('Purchased Date: ${purchasedDate.toLocal().toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: purchasedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => purchasedDate = picked);
                  },
                ),
                ListTile(
                  title: Text('Last Maintenance: ${lastMaintenance.toLocal().toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: lastMaintenance,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => lastMaintenance = picked);
                  },
                ),
                if (isLoading) Padding(
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
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() => isLoading = true);
                    print('[AddAssetDialog] Looking up roomId for roomName="$roomName"');
                    final rooms = await Supabase.instance.client
                        .from('room')
                        .select('id')
                        .ilike('name', roomName);
                    print('[AddAssetDialog] Room lookup result: $rooms');
                    if (rooms.isEmpty) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Room not found!')));
                      return;
                    }
                    final roomId = rooms[0]['id'] as String;

                    // ---- USE PROVIDER FOR USERID ----
                    final userId = Provider.of<UserRoleProvider>(context, listen: false).userId;
                    print('[AddAssetDialog] userId=$userId, roomId=$roomId');
                    final service = AssetService(Supabase.instance.client);
                    final success = await service.addAsset(
                      userId: userId,
                      roomId: roomId,
                      name: name,
                      category: category,
                      type: type,
                      condition: condition,
                      image: image,
                      purchasedDate: purchasedDate,
                      lastMaintenance: lastMaintenance,
                    );
                    print('[AddAssetDialog] addAsset result: $success');
                    setState(() => isLoading = false);
                    if (success) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add asset!')));
                    }
                  }
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}