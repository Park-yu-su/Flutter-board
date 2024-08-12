import 'package:flutter/material.dart';

class UserStatus with ChangeNotifier {
  bool _loginCheck = false;
  String _username = '';

  bool get loginCheck => _loginCheck;
  String get username => _username;

  void updateLoginStatus(bool status) {
    _loginCheck = status;
    notifyListeners(); // 상태가 변경되면 리스너에게 알림
  }

  void updateUsername(String name) {
    _username = name;
    notifyListeners();
  }
}
