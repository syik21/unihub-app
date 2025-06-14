import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    const double lineSpacing = 16;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "back to list", //! ADD the category
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      body: FutureBuilder(
        future: fetchAssetByCode("br L-012345"), // Todo: Change this to the code that receive from previous page
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No asset found'));
          } else {
            final asset = snapshot.data![0];
            final code = asset['code'].replaceAll('br', '').trim();
            final purchaseDate = formatTimestamp('${asset['purchased_date']}');
            final lastMaintenance = formatTimestamp(
              '${asset['last_maintenance']}',
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Asset Image
                  Image.asset(
                    'assets/laptop.png', // Todo: Replace with your asset image path. Get the image from supabase - Storage (asset-pic) Only JPG or PNG
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Asset ID
                  Text(
                    code,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: 1.5,
                      fontFamily: 'Nura', // or your custom font
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      lableText(context, "Category", 75, asset['category']),
                      const SizedBox(height: lineSpacing),
                      lableText(context, "Name", 106, asset['name']),
                      const SizedBox(height: lineSpacing),
                      lableText(context, "Location", 80, asset['category']),
                      const SizedBox(height: lineSpacing),
                      lableText(context, "Condition", 75, asset['condition']),
                      const SizedBox(height: lineSpacing),
                      lableText(context, "Order Date", 62, purchaseDate),
                      const SizedBox(height: lineSpacing),
                      lableText(context, "last service", 49, lastMaintenance),
                      const SizedBox(height: lineSpacing),
                      lableText(
                        context,
                        "Last Modified By",
                        19,
                        asset['user']['name'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Barcode
                  Column(
                    children: [
                      // You can use pretty_qr_code or barcode_widget package for real barcode
                      SizedBox(
                        height: 80,
                        child: Center(
                          child: Column(
                            children: [
                              // Todo: Replace with teh generated barcode
                              Image.asset(
                                'assets/barcode_sample.png',
                                height: 60,
                              ), // Placeholder
                              const SizedBox(height: 2),
                              Text(
                                code,
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
                      onPressed: () {
                        //! Implement download barcode
                      },
                      child: Text(
                        "DOWNLOAD BARCODE",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

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

  Future<List<Map<String, dynamic>>> fetchAssetByCode(String code) async {
    final data = await Supabase.instance.client
        .from('asset')
        .select('*, user(*)')
        .eq('code', code);
    debugPrint('$data');
    return data.cast<Map<String, dynamic>>();
  }

  String formatTimestamp(String timestamp) {
    final utcTime = DateTime.parse(timestamp);
    final localTime = utcTime.toLocal(); // convert from UTC to device timezone
    return DateFormat('dd-MM-yyyy hh:mm a').format(localTime);
  }
}
