import 'package:flutter/material.dart';
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
      (index) => {'name': 'LAPTOP', 'quantity': 1323},
    );
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ASSET INVENTORY',
                      style: TextStyle(
                        fontFamily: 'Nura',
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Toggle
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black,),
                    padding: EdgeInsets.all(10),
                    child:Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  selectedTab == 0
                                      ? Colors.white
                                      : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              'ASSET',
                              style: TextStyle(
                                fontFamily: 'Nura',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    selectedTab == 0
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  selectedTab == 1
                                      ? Colors.white
                                      : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              'SCANNER',
                              style: TextStyle(
                                fontFamily: 'Nura',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    selectedTab == 1
                                        ? Colors.black
                                        : Colors.white,
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
                    style: TextStyle(
                      fontFamily: 'Nura',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.search, color: Colors.black54),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'SEARCH AN ASSET',
                              hintStyle: TextStyle(
                                fontFamily: 'Nura',
                                fontWeight: FontWeight.w600,
                                color: Colors.black38,
                                fontSize: 14,
                                letterSpacing: 1.1,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.tune, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: assets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    decoration: AppDecorations.cardDecoration(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.computer, size: 40, color: Colors.black),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset['name'] as String,
                              style: TextStyle(
                                fontFamily: 'Nura',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'QUANTITY: ${asset['quantity']}',
                              style: TextStyle(
                                fontFamily: 'Nura',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black54,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
