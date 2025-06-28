import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:crypto/crypto.dart';

class UserRoleProvider with ChangeNotifier {
  bool isManager;
  String username;
  String userId;

  UserRoleProvider({
    this.isManager = false,
    this.username = "kenji",
    this.userId = "434699c1-b362-4dc2-9c4d-76d52dd9b691",
  });

  void setManager(bool value) async {
    isManager = value;
    notifyListeners();
  }  // Update: Provider.of<UserRoleProvider>(context, listen: false).setManager(true);
}

Future<bool> validateUserPassword(String managerId, String inputPassword) async {
  final response = await Supabase.instance.client
      .from('user')
      .select('password')
      .eq('id', managerId)
      .single();

  final storedPassword = response['password'];

  // 🔐 If you store hashed passwords (recommended):
  //final inputHashed = sha256.convert(utf8.encode(inputPassword)).toString();

  return inputPassword == storedPassword;
}
