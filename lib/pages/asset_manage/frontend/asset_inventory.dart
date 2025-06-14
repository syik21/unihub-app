import 'package:flutter/material.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_category.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class AssetInventory extends StatefulWidget {
  const AssetInventory({super.key});

  @override
  State<AssetInventory> createState() => AssetInventoryState();
}

class AssetInventoryState extends State<AssetInventory> {
  int selectedTab = 0; // 0: Asset, 1: Scanner

  @override
  Widget build(BuildContext context) {
    final assets = List.generate(
      7,
      (index) => {'category': 'LAPTOP', 'quantity': 1323, 'type': 'Electronic device',},
    );
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
                                color:
                                    selectedTab == 0
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
                                  color:
                                      selectedTab == 0
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
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
                                color:
                                    selectedTab == 1
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
                                  color:
                                      selectedTab == 1
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
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
                          child: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Expanded(
                          child: TextField(
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.tune,
                            color: Theme.of(context).colorScheme.tertiary,
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
              child: ListView.separated(
                itemCount: assets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedAssetCategories(),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 30, right: 30, bottom: 11,top: 7),
                      decoration: AppDecorations.cardDecoration(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.computer, size: 40, color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset['category'] as String,
                                style: Theme.of(context).textTheme.headlineMedium
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Type: ${asset['type']}',
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
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
