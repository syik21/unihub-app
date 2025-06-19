import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>?> searchRoomByName(String room) async {
  try {
    final response =
        await Supabase.instance.client
            .from('room')
            .select()
            .eq('name', room)
            .maybeSingle(); // gets single row or null if not found

    return response; // will be null if not found
  } catch (error) {
    debugPrint('Error searching asset: $error');
    return null;
  }
}


Future<List<Map<String, dynamic>>> getAllRooms() async {
  try {
    final response = await Supabase.instance.client
        .from('room')
        .select('*, map(*)');

    return List<Map<String, dynamic>>.from(response);
  } catch (error) {
    debugPrint('Error getting rooms: $error');
    return [];
  }
}