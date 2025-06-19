import 'package:flutter/material.dart';

class UserRoleProvider with ChangeNotifier {
  bool isManager;
  String username;

  UserRoleProvider({
    this.isManager = false,
    this.username = "kenji",
  });

  void setManager(bool value) async {
    isManager = value;
    notifyListeners();
  }  // Update: Provider.of<UserRoleProvider>(context, listen: false).setManager(true);
}
