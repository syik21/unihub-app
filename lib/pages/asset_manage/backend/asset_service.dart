import 'package:supabase_flutter/supabase_flutter.dart';

class AssetService {
  final SupabaseClient client;
  AssetService(this.client);

  String getPrefix(String category) {
    final cat = category.trim().toLowerCase();
    if (cat == 'network') return 'br ntk-';
    if (cat == 'device') return 'br dv-';
    if (cat == 'lighting') return 'br lgh-';
    if (cat == 'hvac') return 'br ac-';
    return 'br oth-';
  }

  Future<String> generateNextCode(String category) async {
    final prefix = getPrefix(category);

    final data = await client
        .from('asset')
        .select('code')
        .like('code', '$prefix%')
        .order('code', ascending: false)
        .limit(1);

    int maxNum = 0;
    if (data is List && data.isNotEmpty) {
      final lastCode = data[0]['code'] as String;
      final codeNumStr = lastCode.replaceFirst(prefix, '');
      if (RegExp(r'^\d+$').hasMatch(codeNumStr)) {
        maxNum = int.parse(codeNumStr);
      }
    }
    final newNum = maxNum + 1;
    final newCode = '$prefix${newNum.toString().padLeft(8, '0')}';
    return newCode;
  }

  String toTitleCase(String input) {
    return input.replaceAllMapped(RegExp(r'\b\w'), (match) => match.group(0)!.toUpperCase());
  }

  Future<bool> addAsset({
    required String userId,
    required String roomId,
    required String name,
    required String category,
    required String type,
    required String condition,
    String? image,
    required DateTime purchasedDate,
    required DateTime lastMaintenance,
  }) async {
    if (userId.isEmpty || roomId.isEmpty) return false;

    final normalizedItemName = name.trim().toLowerCase();

    for (int attempt = 0; attempt < 3; attempt++) {
      final code = await generateNextCode(category);
      try {
        final insertRes = await client.from('asset').insert({
          'user_id': userId,
          'room_id': roomId,
          'name': normalizedItemName,
          'category': category,
          'type': type,
          'condition': condition,
          'image': (image == null || image.trim().isEmpty) ? null : image,
          'purchased_date': purchasedDate.toUtc().toIso8601String(),
          'last_maintenance': lastMaintenance.toUtc().toIso8601String(),
          'code': code,
        }).select();
        if (insertRes != null) return true;
      } catch (e) {
        if (e.toString().contains('duplicate key value')) {
          continue;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  Future<List<String>> fetchCategoryOptions() async {
    final data = await client.from('asset').select('category');
    return (data as List).map((e) => e['category'] as String).toSet().toList();
  }

  Future<List<Map<String, dynamic>>> fetchAssetCategoriesWithCount() async {
    final data = await client.from('asset').select('category, type');
    final Map<String, Map<String, dynamic>> categoryMap = {};
    for (final item in data as List) {
      final key = '${item['category']}|${item['type']}';
      if (!categoryMap.containsKey(key)) {
        categoryMap[key] = {
          'category': item['category'],
          'type': item['type'],
          'quantity': 1,
        };
      } else {
        categoryMap[key]!['quantity'] += 1;
      }
    }
    return categoryMap.values.toList();
  }

  Future<Map<String, dynamic>?> fetchAssetByCode(String code) async {
    final data = await client
        .from('asset')
        .select('*, user(*), room(name)')
        .eq('code', code)
        .maybeSingle();
    return data;
  }

  /// Delete asset by unique code (not name)
  Future<bool> deleteAssetByCode(String code) async {
    print("deleteAssetByCode called with code: '$code'"); // debug print
    try {
      final res = await client
          .from('asset')
          .delete()
          .eq('code', code)
          .select();
      print("deleteAssetByCode result: $res"); // debug print
      return res is List && res.isNotEmpty;
    } catch (e) {
      print('[AssetService] deleteAssetByCode error: $e');
      return false;
    }
  }

  /// Update asset by unique code (not name)
  Future<bool> updateAssetByCode({
    required String code,
    String? condition,
    String? roomId,
    DateTime? lastMaintenance,
  }) async {
    print("updateAssetByCode called with code: '$code'"); // debug print
    try {
      final updateData = <String, dynamic>{};
      if (condition != null) updateData['condition'] = condition;
      if (roomId != null) updateData['room_id'] = roomId;
      if (lastMaintenance != null) {
        updateData['last_maintenance'] = lastMaintenance.toUtc().toIso8601String();
      }
      if (updateData.isEmpty) return false;
      final res = await client
          .from('asset')
          .update(updateData)
          .eq('code', code)
          .select();
      print("updateAssetByCode result: $res"); // debug print
      return res is List && res.isNotEmpty;
    } catch (e) {
      print('[AssetService] updateAssetByCode error: $e');
      return false;
    }
  }
}
