import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomBookingService {
  final SupabaseClient _client = Supabase.instance.client;

  // Validate if the room exists and is available
  Future<bool> isRoomAvailable(String roomName) async {
    final response = await _client
        .from('room')
        .select('status')
        .eq('name', roomName)
        .maybeSingle();
    if (response == null) return false;
    return response['status'] == 'free';
  }

  // Check for overlapping bookings for the selected room
  Future<bool> isBookingSlotAvailable({
    required String roomId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    final response = await _client
        .from('booking')
        .select('Booking_ID')
        .eq('Room_ID', roomId)
        .or('Start_datetime.lt.${endDateTime.toIso8601String()},End_datetime.gt.${startDateTime.toIso8601String()}')
        .neq('Status', 'rejected');
    return (response as List).isEmpty;
  }

  // Create a new booking
  Future<void> createBooking({
    required String userId,
    required String roomId,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String purpose,
    required String description,
  }) async {
    await _client.from('booking').insert({
      'User_ID': userId,
      'Room_ID': roomId,
      'Start_datetime': startDateTime.toIso8601String(),
      'End_datetime': endDateTime.toIso8601String(),
      'Purpose': purpose,
      'Description': description,
      'Status': 'pending',
    });
  }

  // Get all bookings for a user
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('room_bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  // Get all bookings for a venue
  Future<List<Map<String, dynamic>>> getVenueBookings(String venue) async {
    try {
      final response = await _client
          .from('room_bookings')
          .select()
          .eq('venue', venue)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch venue bookings: $e');
    }
  }

  // Check if a venue is available for a specific time slot
  Future<bool> isVenueAvailable({
    required String venue,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      final response = await _client
          .from('room_bookings')
          .select()
          .eq('venue', venue)
          .eq('start_date', date.toIso8601String())
          .eq('status', 'approved');

      final bookings = List<Map<String, dynamic>>.from(response);
      
      // Convert booking times to minutes for easier comparison
      final requestedStartMinutes = startTime.hour * 60 + startTime.minute;
      final requestedEndMinutes = endTime.hour * 60 + endTime.minute;

      for (var booking in bookings) {
        final bookingStartTime = booking['start_time'].toString().split(':');
        final bookingEndTime = booking['end_time'].toString().split(':');
        
        final bookingStartMinutes = int.parse(bookingStartTime[0]) * 60 + int.parse(bookingStartTime[1]);
        final bookingEndMinutes = int.parse(bookingEndTime[0]) * 60 + int.parse(bookingEndTime[1]);

        // Check for time overlap
        if ((requestedStartMinutes >= bookingStartMinutes && requestedStartMinutes < bookingEndMinutes) ||
            (requestedEndMinutes > bookingStartMinutes && requestedEndMinutes <= bookingEndMinutes) ||
            (requestedStartMinutes <= bookingStartMinutes && requestedEndMinutes >= bookingEndMinutes)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to check venue availability: $e');
    }
  }
} 