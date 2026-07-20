import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  String? selectedFilter;
  Map<String, bool> selectedOptions = {};
  RangeValues rentRange = const RangeValues(0, 10000);

  void selectFilter(String? filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void toggleOption(String option) {
    selectedOptions[option] = !(selectedOptions[option] ?? false);
    notifyListeners();
  }

  void setRentRange(RangeValues range) {
    rentRange = range;
    notifyListeners();
  }

  void clearFilters() {
    selectedFilter = null;
    selectedOptions.clear();
    rentRange = const RangeValues(0, 10000);
    notifyListeners();
  }

  void applyFilters() {
    notifyListeners();
  }
}
