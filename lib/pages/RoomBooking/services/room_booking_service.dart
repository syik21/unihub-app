import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomBookingService {
  final SupabaseClient _client = Supabase.instance.client;

  // Validate if the room exists and is available
  Future<bool> isRoomAvailable(String roomName) async {
    final response =
        await _client
            .from('room')
            .select('status')
            .eq('name', roomName)
            .maybeSingle();
    if (response == null) return false;
    return response['status'] == 'free';
  }

  // Check for overlapping bookings for the selected room
  Future<List<Map<String, dynamic>>> isBookingSlotAvailable({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final response = await _client
        .from('booking')
        .select()
        .eq('Room_ID', roomId)
        .neq('Status', 'rejected')
        .neq('Status', 'completed');

    final bookings = response as List;
    final List<Map<String, dynamic>> conflicts = [];

    for (final booking in bookings) {
      final DateTime bookedStartDate = DateTime.parse(booking['Start_date']);
      final DateTime bookedEndDate = DateTime.parse(booking['End_date']);

      final bool isDateOverlap =
          startDate.isBefore(bookedEndDate.add(Duration(days: 1))) &&
          endDate.isAfter(bookedStartDate.subtract(Duration(days: 1)));

      if (isDateOverlap) {
        final TimeOfDay bookedStartTime = _parseTime(booking['start_time']);
        final TimeOfDay bookedEndTime = _parseTime(booking['end_time']);

        final bool isTimeOverlap = _isTimeOverlap(
          startTime,
          endTime,
          bookedStartTime,
          bookedEndTime,
        );

        if (isTimeOverlap) {
          conflicts.add(booking); // add the full booking object
        }
      }
    }

    return conflicts; // empty list means no conflict
  }

  Future<List<Map<String, dynamic>>> isBookingSlotAvailableExpectThis({
    required String roomId,
    required String bookingId,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final response = await _client
        .from('booking')
        .select()
        .eq('Room_ID', roomId)
        .neq('Status', 'rejected')
        .neq('Status', 'completed')
        .neq('Booking_ID', bookingId);

    final bookings = response as List;
    final List<Map<String, dynamic>> conflicts = [];

    for (final booking in bookings) {
      final DateTime bookedStartDate = DateTime.parse(booking['Start_date']);
      final DateTime bookedEndDate = DateTime.parse(booking['End_date']);

      final bool isDateOverlap =
          startDate.isBefore(bookedEndDate.add(Duration(days: 1))) &&
          endDate.isAfter(bookedStartDate.subtract(Duration(days: 1)));

      if (isDateOverlap) {
        final TimeOfDay bookedStartTime = _parseTime(booking['start_time']);
        final TimeOfDay bookedEndTime = _parseTime(booking['end_time']);

        final bool isTimeOverlap = _isTimeOverlap(
          startTime,
          endTime,
          bookedStartTime,
          bookedEndTime,
        );

        if (isTimeOverlap) {
          conflicts.add(booking); // add the full booking object
        }
      }
    }

    return conflicts; // empty list means no conflict
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeOverlap(
    TimeOfDay start1,
    TimeOfDay end1,
    TimeOfDay start2,
    TimeOfDay end2,
  ) {
    final int start1Mins = start1.hour * 60 + start1.minute;
    final int end1Mins = end1.hour * 60 + end1.minute;
    final int start2Mins = start2.hour * 60 + start2.minute;
    final int end2Mins = end2.hour * 60 + end2.minute;

    return start1Mins < end2Mins && end1Mins > start2Mins;
  }

  // Create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
    required String purpose,
    required String description,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final bookingDetail =
        await _client
            .from('booking')
            .insert({
              'User_ID': userId,
              'Room_ID': roomId,
              'Start_date': startDate.toIso8601String().split('T')[0],
              'End_date': endDate.toIso8601String().split('T')[0],
              'Purpose': purpose,
              'Description': description,
              'Status': 'pending',
              'start_time':
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
              'end_time':
                  '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
            })
            .select('*,room(*,map(*)),user(*)')
            .single();
    if (bookingDetail.isNotEmpty) {
      return bookingDetail;
    }
    return {};
  }

  // Get all bookings for a user
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('booking')
          .select('*,room(*,map(*)),user(*)')
          .eq('User_ID', userId)
          .order('Start_date', ascending: true)
          .order('start_time', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserBookings() async {
    try {
      final response = await _client
          .from('booking')
          .select('*,room(*,map(*)),user(*)')
          .order('Start_date', ascending: true)
          .order('start_time', ascending: true);

      return response;
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

        final bookingStartMinutes =
            int.parse(bookingStartTime[0]) * 60 +
            int.parse(bookingStartTime[1]);
        final bookingEndMinutes =
            int.parse(bookingEndTime[0]) * 60 + int.parse(bookingEndTime[1]);

        // Check for time overlap
        if ((requestedStartMinutes >= bookingStartMinutes &&
                requestedStartMinutes < bookingEndMinutes) ||
            (requestedEndMinutes > bookingStartMinutes &&
                requestedEndMinutes <= bookingEndMinutes) ||
            (requestedStartMinutes <= bookingStartMinutes &&
                requestedEndMinutes >= bookingEndMinutes)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to check venue availability: $e');
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response =
          await _client
              .from('booking')
              .update({'Status': status})
              .eq('Booking_ID', bookingId)
              .select()
              .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Failed to fetch venue bookings: $e');
      return false;
    }
  }

  Future<bool> updateBookingDetail(
    String bookingId,
    String roomID,
    DateTime startDate,
    DateTime endDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    try {
      final response =
          await _client
              .from('booking')
              .update({
                'Room_ID': roomID,
                'Start_date': startDate.toIso8601String().split('T')[0],
                'End_date': endDate.toIso8601String().split('T')[0],
                'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
                'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
              })
              .eq('Booking_ID', bookingId)
              .select()
              .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Failed to fetch venue bookings: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getBookingsWithId(String bookingId) async {
    try {
      final response =
          await _client
              .from('booking')
              .select('*,user(*),room(*,map(*))')
              .eq('Booking_ID', bookingId)
              .single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }
}
