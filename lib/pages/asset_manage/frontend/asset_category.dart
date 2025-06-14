import 'package:flutter/material.dart';
import 'package:unihub/pages/asset_manage/frontend/asset_detail.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class SelectedAssetCategories extends StatelessWidget {
  const SelectedAssetCategories({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "back to inventory",
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
                'Laptop',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 24),
            // Title
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
                    child: Icon(
                      Icons.tune,
                      color: Theme.of(context).colorScheme.tertiary,
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
                "RESULT: 100000",
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
              child: ListView.separated(
                itemCount: 5, // Replace with your asset count
                separatorBuilder: (_, __) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  // Example data
                  final assetStatus =
                      [
                        {'text': 'GOOD', 'color': Colors.green},
                        {'text': 'MAINTENANCE', 'color': Colors.orange},
                        {'text': 'BROKEN', 'color': Colors.red},
                        {'text': 'GOOD', 'color': Colors.green},
                        {'text': 'GOOD', 'color': Colors.green},
                      ][index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetDetailPage(),
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
                                  "L00213151",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "ACER NITRO 15",
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
                                      "A-03-05",
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
                                      assetStatus['text'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: assetStatus['color'] as Color,
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
          ],
        ),
      ),
    );
  }
}
