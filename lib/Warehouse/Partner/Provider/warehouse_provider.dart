import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class WarehouseProvider with ChangeNotifier {
  final Map<String, bool> _warehouseStatus = {};
  Map<String, bool> get warehouseStatus => _warehouseStatus;
  void initializeStatus(String warehouseId, bool status) {
    _warehouseStatus[warehouseId] = status;
  }

  Future<void> updateWarehouseStatus(String warehouseId, bool status) async {
    final url = Uri.parse(
        'https://xpacesphere.com/api/Wherehousedt/UpdIsAvailable');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Id': warehouseId,
          'isavailable': status?1:0
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Warehouse status updated successfully');
        }
        _warehouseStatus[warehouseId] = status;
         notifyListeners();
      } else {
        if (kDebugMode) {
          print('Failed to update warehouse status: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating warehouse status: $e');
      }
    }
  }
}

