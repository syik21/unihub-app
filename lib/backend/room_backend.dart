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

Future<Map<String, dynamic>?> incrementRoomPeople(String roomId) async {
  try {
    // Fetch current value and capacity
    final current =
        await Supabase.instance.client
            .from('room')
            .select('current_people, capacity')
            .eq('id', roomId)
            .maybeSingle();
    final currentPeople = (current?['current_people'] ?? 0) as int;
    final capacity = (current?['capacity'] ?? 0) as int;
    if (currentPeople >= capacity) {
      // Already at or above capacity, do not increment
      return await Supabase.instance.client
          .from('room')
          .select()
          .eq('id', roomId)
          .maybeSingle();
    }
    final response =
        await Supabase.instance.client
            .from('room')
            .update({'current_people': currentPeople + 1})
            .eq('id', roomId)
            .select()
            .maybeSingle();
    return response;
  } catch (error) {
    debugPrint('Error incrementing room people: $error');
    return null;
  }
}

Future<Map<String, dynamic>?> decrementRoomPeople(String roomId) async {
  try {
    // Fetch current value
    final current =
        await Supabase.instance.client
            .from('room')
            .select('current_people')
            .eq('id', roomId)
            .maybeSingle();
    final currentPeople = (current?['current_people'] ?? 0) as int;
    final response =
        await Supabase.instance.client
            .from('room')
            .update({
              'current_people': currentPeople > 0 ? currentPeople - 1 : 0,
            })
            .eq('id', roomId)
            .select()
            .maybeSingle();
    return response;
  } catch (error) {
    debugPrint('Error decrementing room people: $error');
    return null;
  }
}
