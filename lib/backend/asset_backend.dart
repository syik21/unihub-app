import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>?> searchAssetByBarcode(String barcode) async {
  try {
    final response =
        await Supabase.instance.client
            .from('asset')
            .select()
            .eq('code', barcode)
            .maybeSingle(); // gets single row or null if not found

    return response; // will be null if not found
  } catch (error) {
    debugPrint('Error searching asset: $error');
    return null;
  }
}
