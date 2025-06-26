import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Add a new asset to the 'asset' table in Supabase.
/// Returns true if successful, false otherwise.
Future<bool> addAsset({
  required String assetId, // uuid
  required String userId,  // uuid
  required String roomId,  // uuid
  required String name,
  required String code,    // barcode ID (unique)
  required String category,
  required String condition,
  required String image,
  required String type,
  required DateTime purchasedDate,
  required DateTime lastMaintenance,
}) async {
  try {
    final response = await Supabase.instance.client.from('asset').insert({
      'asset_id': assetId,
      'user_id': userId,
      'room_id': roomId,
      'name': name,
      'code': code,
      'category': category,
      'condition': condition,
      'image': image,
      'type': type,
      'purchased_date': purchasedDate.toIso8601String(),
      'last_maintenance': lastMaintenance.toIso8601String(),
    });
    return response.error == null;
  } catch (error) {
    debugPrint('Error adding asset: $error');
    return false;
  }
}

/// Search asset by barcode (code)
Future<Map<String, dynamic>?> searchAssetByBarcode(String barcode) async {
  try {
    final response = await Supabase.instance.client
        .from('asset')
        .select()
        .eq('code', barcode)
        .maybeSingle();
    return response;
  } catch (error) {
    debugPrint('Error searching asset: $error');
    return null;
  }
}

/// Fetch all assets
Future<List<Map<String, dynamic>>> fetchAllAssets() async {
  try {
    final response = await Supabase.instance.client
        .from('asset')
        .select();
    return (response as List).cast<Map<String, dynamic>>();
  } catch (error) {
    debugPrint('Error fetching all assets: $error');
    return [];
  }
}

/// Generate asset code based on category and last number
/// Example: network -> br ntk-00000001
Future<String> generateAssetCode(String category) async {
  String prefix;
  switch (category.toLowerCase()) {
    case 'network':
      prefix = 'br ntk-';
      break;
    case 'device':
      prefix = 'br dv-';
      break;
    case 'lighting':
      prefix = 'br lgh-';
      break;
    case 'hvac':
      prefix = 'br hvac-';
      break;
    default:
      prefix = 'br unk-'; // unknown
  }

  // Get the last inserted code for this category
  final response = await Supabase.instance.client
      .from('asset')
      .select('code')
      .ilike('code', '$prefix%')
      .order('code', ascending: false)
      .limit(1);
  int newNumber = 1;
  if (response is List && response.isNotEmpty) {
    final lastCode = response[0]['code'] as String;
    final match = RegExp(r'(\d+)$').firstMatch(lastCode);
    if (match != null) {
      newNumber = int.parse(match.group(1)!) + 1;
    }
  }
  final code = '$prefix${newNumber.toString().padLeft(8, '0')}';
  return code;
}