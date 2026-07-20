import 'package:flutter/cupertino.dart';
class SortingProvider with ChangeNotifier {
  String _selectedSortOption = '';
  String get selectedSortOption => _selectedSortOption;
  set selectedSortOption(String option) {
    _selectedSortOption = option;
    notifyListeners();
  }
}
