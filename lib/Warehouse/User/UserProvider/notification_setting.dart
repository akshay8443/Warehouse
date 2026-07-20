
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider with ChangeNotifier {
  bool _phoneNotifications = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String? _phone;
  String? _email;

  bool get phoneNotifications => _phoneNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  String? get phone => _phone;
  String? get email => _email;

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phoneNotifications = prefs.getBool('phoneNotifications') ?? true;
    _emailNotifications = prefs.getBool('emailNotifications') ?? true;
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _phone = prefs.getString('phone');
    _email = prefs.getString('email');
    if (kDebugMode) {
      print("email>>$_email");
    }
    if (_phone != null && _phone!.startsWith("+91")) {
      _phone = _phone!.substring(3);
    }
    notifyListeners();
  }
  void togglePhoneNotifications() async {
    _phoneNotifications = !_phoneNotifications;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('phoneNotifications', _phoneNotifications);
    notifyListeners();
  }
  void toggleEmailNotifications() async {
    _emailNotifications = !_emailNotifications;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('emailNotifications', _emailNotifications);
    notifyListeners();
  }
  void togglePushNotifications() async {
    _pushNotifications = !_pushNotifications;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('pushNotifications', _pushNotifications);
    notifyListeners();
  }
}