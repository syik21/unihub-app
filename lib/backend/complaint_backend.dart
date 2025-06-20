import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>> submitComplaintToSupabase(
  File? file,
  String userID,
  String roomID,
  dynamic assetID,
  String? type,
  String desc,
) async {
  if (file == null) {
    debugPrint('No image selected.');
    return {};
  }

  try {
    final supabase = Supabase.instance.client;
    final uniqueId = const Uuid().v4();
    final ext = p.extension(file.path); // get file extension
    final fileName = '$uniqueId$ext';

    final Uint8List fileBytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.path);

    const allowedTypes = ['image/jpg', 'image/jpeg', 'image/png'];

    if (!allowedTypes.contains(mimeType)) {
      debugPrint('Upload failed: Invalid file type: $mimeType');
      return {};
    }

    final storagePath = 'issues/$fileName';
    final response = await supabase.storage
        .from('image') // 🔁 Replace with your bucket name
        .uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType),
        );

    if (response.isNotEmpty) {
      debugPrint('Upload success! Path: $response');

      // ✅ Save image path to complaint table
      final complaintDetail =
          await supabase
              .from('complaint')
              .insert({
                'user_id': userID,
                'room_id': roomID,
                'asset_id': assetID,
                'type': type,
                'description': desc,
                'attachment': storagePath,
              })
              .select('id')
              .single();

      return complaintDetail;
    } else {
      debugPrint('Upload failed!');
      return {};
    }
  } catch (error) {
    debugPrint('Error submitting complaint: $error');
    return {};
  }
}

Future<Map<String, dynamic>?> searchExistComplaint(
  String roomID,
  String? assetID,
  String type,
) async {
  print(assetID != null);
  try {
    final query = Supabase.instance.client
        .from('complaint')
        .select()
        .eq('room_id', roomID)
        .eq('type', type)
        .eq('status', 'pending');

    if (assetID != null) {
      query.eq('asset_id', assetID);
    } else {
      query.filter('asset_id', 'is', null);
    }

    final response = await query.maybeSingle();

    return response; // will be null if not found
  } catch (error) {
    debugPrint('Error searching asset: $error');
    return null;
  }
}

Future<Map<String, dynamic>?> searchComplaintById(String complaintID) async {
  try {
    final response =
        await Supabase.instance.client
            .from('complaint')
            .select('*,room(*,map(*)),asset(*)')
            .eq('id', complaintID)
            .maybeSingle();

    if (response == null) return null;

    final attachmentPath = response['attachment'];
    if (attachmentPath != null && attachmentPath != "") {
      final imageUrl = Supabase.instance.client.storage
          .from('image')
          .getPublicUrl(attachmentPath);
      response['image_url'] = imageUrl;
    }

    return response;
  } catch (error) {
    debugPrint('Error searching complaint: $error');
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getAllComplaintByUserId(
  String userID,
) async {
  try {
    final response = Supabase.instance.client
        .from('complaint')
        .select('*,room(*)')
        .eq('user_id', userID);

    return response;
  } catch (error) {
    debugPrint('Error searching asset: $error');
    return null;
  }
}
