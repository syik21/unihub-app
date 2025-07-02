import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userType;
  String? _userName;
  String? _userEmail;

  String? get userId => _userId;
  String? get userType => _userType;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  /// Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _userType = prefs.getString('userType');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  /// Save all user data
  Future<void> saveUserData({
    required String id,
    required String type,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userType', type);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    _userId = id;
    _userType = type;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  /// Update user type only
  Future<void> updateUserType(String newType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', newType);
    _userType = newType;
    notifyListeners();
  }

  /// Update user name only
  Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    _userName = newName;
    notifyListeners();
  }

  /// Update user email only
  Future<void> updateUserEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', newEmail);
    _userEmail = newEmail;
    notifyListeners();
  }

  /// Clear all user data (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userType');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    _userId = null;
    _userType = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}

Future<bool> validateUserPassword(
  String managerId,
  String inputPassword,
) async {
  final response =
      await Supabase.instance.client
          .from('user')
          .select('password')
          .eq('id', managerId)
          .single();

  final storedPassword = response['password'];

  // 🔐 If you store hashed passwords (recommended):
  //final inputHashed = sha256.convert(utf8.encode(inputPassword)).toString();

  return inputPassword == storedPassword;
}

Future<Map<String, dynamic>?> searchUserById(String? userID) async {
  try {
    final response =
        await Supabase.instance.client
            .from('user')
            .select()
            .eq('id', userID!)
            .maybeSingle();

    if (response == null) return null;

    final attachmentPath = response['picture'];
    if (attachmentPath != null && attachmentPath != "") {
      final imageUrl = Supabase.instance.client.storage
          .from('image')
          .getPublicUrl(attachmentPath);
      response['image_url'] = imageUrl;
    }

    return response;
  } catch (error) {
    debugPrint('Error searching user: $error');
    return null;
  }
}

Future<Map<String, dynamic>> updateUserPicture(
  File? file,
  String? userID,
) async {
  if (file == null || userID == null) {
    debugPrint('No image or user ID provided.');
    return {};
  }

  try {
    final supabase = Supabase.instance.client;

    // 🔎 Step 1: Fetch current user to get the existing picture path
    final userData =
        await supabase
            .from('user')
            .select('picture')
            .eq('id', userID)
            .maybeSingle();

    final previousPicPath = userData?['picture'];

    // 🆕 Step 2: Prepare new upload
    final uniqueId = const Uuid().v4();
    final ext = p.extension(file.path);
    final fileName = '$uniqueId$ext';
    final Uint8List fileBytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.path);

    const allowedTypes = ['image/jpg', 'image/jpeg', 'image/png'];
    if (!allowedTypes.contains(mimeType)) {
      debugPrint('Upload failed: Invalid file type: $mimeType');
      return {};
    }

    final storagePath = 'profilePic/$fileName';

    // ❌ Step 3: Delete previous image (if exists)
    if (previousPicPath != null && previousPicPath.toString().isNotEmpty) {
      await supabase.storage.from('image').remove([previousPicPath]);
      debugPrint('Previous picture deleted: $previousPicPath');
    }

    // 📤 Step 4: Upload new image
    final response = await supabase.storage
        .from('image')
        .uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType),
        );

    if (response.isNotEmpty) {
      debugPrint('Upload success! Path: $response');

      // 📝 Step 5: Update user table with new image path
      final updatedUser =
          await supabase
              .from('user')
              .update({'picture': storagePath})
              .eq('id', userID)
              .select('id')
              .single();

      return updatedUser;
    } else {
      debugPrint('Upload failed!');
      return {};
    }
  } catch (error) {
    debugPrint('Error updating profile picture: $error');
    return {};
  }
}
