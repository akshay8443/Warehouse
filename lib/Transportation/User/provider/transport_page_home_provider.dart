import 'package:flutter/cupertino.dart';

class TransportPageHomeProvider with ChangeNotifier {
  String? _selectedContainer;
  String? _expandedContainer;

  String? get selectedContainer => _selectedContainer;
  String? get expandedContainer => _expandedContainer;

  void selectContainer(String title) {
    if (_expandedContainer == title) {
      _expandedContainer = null;
      _selectedContainer = title;
    } else {
      _selectedContainer = title;
    }
    notifyListeners();
  }

  void toggleExpand(String title) {
    _expandedContainer = _expandedContainer == title ? null : title;
    notifyListeners();
  }
}