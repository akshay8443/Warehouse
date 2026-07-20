import 'package:flutter/material.dart';
import 'dart:io';
class ProfileProvider extends ChangeNotifier {
  File? _profileImage;
  String? _profileImageUrl;
  File? get profileImage => _profileImage;
  String? get profileImageUrl => _profileImageUrl;
  void setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }
  void setProfileImageUrl(String? url) {
    _profileImageUrl = url;
    notifyListeners();
  }
}
