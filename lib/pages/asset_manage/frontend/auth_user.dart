import 'package:flutter/material.dart';

class UserRoleProvider with ChangeNotifier {
  bool isManager;
  String username;
  String userId;

  UserRoleProvider({
    this.isManager = false,
    this.username = "kenji",
    this.userId = "434699c1-b362-4dc2-9c4d-76d52dd9b691", // <-- Hardcoded userId
  });

  void setManager(bool value) async {
    isManager = value;
    notifyListeners();
  }
}