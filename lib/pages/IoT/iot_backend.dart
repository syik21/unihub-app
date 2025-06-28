import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/pages/IoT/control_device_page.dart';

class IotBackend {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> getBlocks() async {
    final response = await _client.from('device_location_view').select('block');

    final blocks =
        (response as List)
            .map((item) => item['block'] as String)
            .toSet()
            .toList();
    return blocks;
  }

  Future<List<String>> getFloors(String block) async {
    final response = await _client
        .from('device_location_view')
        .select('floor')
        .eq('block', block);

    final floors =
        (response as List)
            .map((item) => item['floor'].toString())
            .toSet()
            .toList();
    return floors;
  }

  Future<List<String>> getRooms(String block, String floor) async {
    final response = await _client
        .from('device_location_view')
        .select('room_name')
        .eq('block', block)
        .eq('floor', int.parse(floor));

    final rooms =
        (response as List)
            .map((item) => item['room_name'] as String)
            .toSet()
            .toList();
    return rooms;
  }

  Future<List<Device>> getDevicesInRoom(String roomName) async {
    final response = await _client
        .from('device_location_view')
        .select('device_id, control_status, asset_name')
        .eq('room_name', roomName);

    return (response as List)
        .map(
          (item) => Device(
            id: item['device_id'].toString(),
            name: item['asset_name'] as String,
            isOn: item['control_status'].toString().toLowerCase() == 'on',
          ),
        )
        .toList();
  }

  Future<void> updateDeviceStatus(String deviceId, bool newState) async {
    final statusText = newState ? 'on' : 'off';
    final response =
        await _client
            .from('device')
            .update({'control_status': statusText})
            .eq('id', deviceId)
            .select();

    if (response.isEmpty) {
      throw Exception(
        'Failed to update device. Device ID not found or RLS policy prevented update.',
      );
    }
  }
}
