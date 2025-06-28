import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_detail.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:unihub/pages/asset_manage/backend/asset_service.dart';
import 'package:unihub/pages/user-profile/auth_user.dart'; // <-- Make sure to import for Provider

class SelectedAssetCategories extends StatefulWidget {
  final String category;
  const SelectedAssetCategories({super.key, required this.category});

  @override
  State<SelectedAssetCategories> createState() => _SelectedAssetCategoriesState();
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
                  assets.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.numbers),
              title: Text('Sort by Code'),
              onTap: () {
                setState(() {
                  assets.sort((a, b) => (a['code'] as String).compareTo(b['code'] as String));
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

  @override
  Widget build(BuildContext context) {
    final filteredAssets = assets.where((asset) {
      if (searchQuery.isEmpty) return true;
      return (asset['name'] as String).toLowerCase().contains(searchQuery)
          || (asset['code'] as String).toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Back to inventory",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      body: Padding(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAssets.isEmpty
                    ? const Center(child: Text('No asset in this category.'))
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
                                  builder: (context) =>
                                    AssetDetailPage(assetCode: asset['code']),
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
                              decoration: AppDecorations.cardDecoration(context),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.computer,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                  const SizedBox(width: 18),
                                  // Asset details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          asset['code'] ?? "",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          asset['name'] ?? "",
                                          style: Theme.of(context).textTheme.bodyMedium
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text(
                                              "LOCATION  :  ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              asset['room']?['name'] ?? '-',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
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
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              asset['condition'] ?? "-",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: asset['condition'] == "good"
                                                    ? Colors.green
                                                    : (asset['condition'] == "maintenance"
                                                      ? Colors.orange
                                                      : Colors.red),
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
                                    color: Theme.of(context).colorScheme.tertiary,
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
          ],
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
      if (widget.initialCategory != null && fetched.contains(widget.initialCategory)) {
        category = widget.initialCategory!;
      } else if (fetched.isNotEmpty) {
        category = fetched.first;
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
                  onChanged: widget.initialCategory == null
                      ? (v) => setState(() => category = v ?? category)
                      : null,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (v) => v == null || v.isEmpty ? "Select category" : null,
                  disabledHint: widget.initialCategory != null
                      ? Text(widget.initialCategory!)
                      : null,
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
                    // For roomId lookup
                    final rooms = await Supabase.instance.client
                        .from('room')
                        .select('id')
                        .ilike('name', roomName);
                    if (rooms.isEmpty) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Room not found!')));
                      return;
                    }
                    final roomId = rooms[0]['id'] as String;
                    // --------- FIX: use Provider for userId ---------
                    final userId = Provider.of<UserRoleProvider>(context, listen: false).userId;
                    if (userId.isEmpty) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not found! Please log in again.')),
                      );
                      return;
                    }
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