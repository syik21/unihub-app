import 'package:supabase_flutter/supabase_flutter.dart';
import 'asset_model.dart';

class AssetService {
  final SupabaseClient _supabase;
  static const String _tableName = 'assets'; // adjust table name as needed

  AssetService(this._supabase);

  // Generate unique barcode based on category
  String generateBarcode(String category) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
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
        throw Exception('Invalid category');
    }

    // Generate a unique 7-digit number
    final uniqueNumber = timestamp % 10000000;
    return '$prefix${uniqueNumber.toString().padLeft(7, '0')}';
  }

  // Add new asset
  Future<Asset> addAsset({
    required String userId,
    required String roomId,
    required String name,
    required String category,
    required String condition,
    String? image,
    required DateTime purchasedDate,
    required DateTime lastMaintenance,
    required String type,
  }) async {
    final code = generateBarcode(category);
    
    final asset = Asset(
      userId: userId,
      roomId: roomId,
      name: name,
      code: code,
      category: category,
      condition: condition,
      image: image,
      purchasedDate: purchasedDate,
      lastMaintenance: lastMaintenance,
      type: type,
    );

    final response = await _supabase
        .from(_tableName)
        .insert(asset.toJson())
        .select()
        .single();

    return Asset.fromJson(response);
  }

  // Find asset by barcode
  Future<Asset?> findAssetByBarcode(String barcode) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('code', barcode)
        .single();

    return response != null ? Asset.fromJson(response) : null;
  }

  // Get all assets
  Future<List<Asset>> getAllAssets() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);

    return response.map((json) => Asset.fromJson(json)).toList();
  }
}