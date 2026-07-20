import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class LocationProvider with ChangeNotifier {
  String _location = "Unknown";
  LatLng? _latLng;
  String get location => _location;
  LatLng? get latLng => _latLng;

  void updateLocation(String newLocation, LatLng newLatLng) {
    _location = newLocation;
    _latLng = newLatLng;
    notifyListeners();
  }
}
