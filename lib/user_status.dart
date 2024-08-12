//provider로 앱 전체에서 전역으로 다룰 수 있는 클래스

import 'package:flutter/material.dart';

class UserStatus with ChangeNotifier {
  bool _loginCheck = false;
  String _username = '';
  String _email = '';
  String _imageIcon = '';

  bool get loginCheck => _loginCheck;
  String get username => _username;
  String get email => _email;
  String get imageIcon => _imageIcon;

  void updateLoginStatus(bool status) {
    _loginCheck = status;
    notifyListeners(); // 상태가 변경되면 리스너에게 알림
  }

  void updateUsername(String name) {
    _username = name;
    notifyListeners();
  }

  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void updateImageIcon(String imageIcon) {
    _imageIcon = imageIcon;
    notifyListeners();
  }
}
