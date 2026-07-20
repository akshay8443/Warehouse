import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/Warehouse/User/user_shortlisted_intrested.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProvider with ChangeNotifier {
  final String baseUrl = "https://xpacesphere.com/api/Wherehousedt";
  final Map<int, bool> _shortlistedWarehouses = {};
  bool isShortlisted(int warehouseId) =>
      _shortlistedWarehouses[warehouseId] ?? false;
  Future<void> fetchShortlistStatus(int warehouseId, String phoneNumber) async {
    try {
      final url =
          "$baseUrl/GetSortlist_warehouse?_mobile=$phoneNumber&Id=$warehouseId";
      if (kDebugMode) {
        print("Iddd$warehouseId");
      }
      final response = await http.get(Uri.parse(url));
      if (kDebugMode) {
        print("URL: $url");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print("Response Data: $data");
        }
        if (data['status'] == 200 &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          final type = data['data'][0]['type'];
          if (type == "Shortlisted") {
            _shortlistedWarehouses[warehouseId] = true;
          } else {
            _shortlistedWarehouses[warehouseId] = false;
          }
        } else {
          _shortlistedWarehouses[warehouseId] = false;
        }
        notifyListeners();
      } else {
        throw Exception("Failed to fetch shortlist status");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching shortlist status: $e");
      }
    }
  }

  Future<void> toggleWarehouse(
      int warehouseId, String phoneNumber, BuildContext context,
      {bool isUndo = false}) async {
    final isCurrentlyShortlisted = _shortlistedWarehouses[warehouseId] ?? false;
    try {
      if (kDebugMode) {
        print(
            "Toggling warehouse: $warehouseId, Phone: $phoneNumber, Undo: $isUndo");
      }
      if (!isUndo) {
        final url = "$baseUrl/Sortlist_warehouse";
        final body = json.encode({
          "mobile": phoneNumber,
          "Warehouse_uid": warehouseId.toString(),
          "Type": "Shortlisted"
        });
        final headers = {"Content-Type": "application/json"};
        if (kDebugMode) {
          print("URL: $url");
        }
        if (kDebugMode) {
          print("Request Body: $body");
        }
        if (kDebugMode) {
          print("Headers: $headers");
        }
        final response =
            await http.post(Uri.parse(url), body: body, headers: headers);
        if (kDebugMode) {
          print("Response Status Code: ${response.statusCode}");
        }
        if (kDebugMode) {
          print("Response Body: ${response.body}");
        }
        if (response.statusCode != 200 ||
            json.decode(response.body)['status'] != 200) {
          if (kDebugMode) {
            print("Response code for shortlist: ${response.body}");
          }
          throw Exception("Failed to toggle shortlist status");
        }
      }

      _shortlistedWarehouses[warehouseId] = !isCurrentlyShortlisted;
      notifyListeners();
      if (!context.mounted) return;
      if (!isCurrentlyShortlisted && !isUndo) {
        if (kDebugMode) {
          print("Warehouse added to shortlist");
        }
        showCustomSnackBar(
          context,
          message: "Added to shortlist",
          actionLabel: "View",
          action: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserShortListedInterested()));
          },
        );
      } else if (isCurrentlyShortlisted && !isUndo) {
        if (kDebugMode) {
          print("Warehouse removed from shortlist");
        }
        showCustomSnackBar(
          context,
          message: "Removed from shortlist",
          actionLabel: "Undo",
          action: () {
            // Undo removal
            toggleWarehouse(warehouseId, phoneNumber, context, isUndo: true);
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling shortlist: $e");
      }
    }
  }

  void showCustomSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? action,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      action: actionLabel != null && action != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: action,
              textColor: actionLabel.toLowerCase() == "view"
                  ? Colors.greenAccent
                  : Colors.red,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.primary.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
