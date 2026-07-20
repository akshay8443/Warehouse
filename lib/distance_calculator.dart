import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
class DistanceCalculator {
  LatLng parseLatLng(String wHouseAddress) {
    final regex = RegExp(r'LatLng\(([^,]+), ([^)]+)\)');
    final match = regex.firstMatch(wHouseAddress);
    if (match != null) {
      double latitude = double.parse(match.group(1)!);
      double longitude = double.parse(match.group(2)!);
      return LatLng(latitude, longitude);
    } else {
      throw Exception("Invalid format for whose_address");
    }
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
    ),
    );
  }

  double calculateDistanceWithRandomBuffer(LatLng location1, LatLng location2) {
    double distance = Geolocator.distanceBetween(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    );

    // Generate a random buffer between 1km (1000m) and 3km (3000m)
    double randomBuffer = 1000 + Random().nextDouble() * (3000 - 1000);
    return distance + randomBuffer;
  }

  Future<double> getDistanceFromCurrentToWarehouse(String whouseAddress) async {
    LatLng warehouseLatLng = parseLatLng(whouseAddress);
    Position currentPosition = await getCurrentLocation();
    LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    // Generate a small random offset between -0.005 and 0.005
    double offset = (Random().nextDouble() * 0.01 - 0.005); // Range: [-0.005, 0.005]
    // Randomly decide whether to modify latitude or longitude
    if (Random().nextBool()) {
      warehouseLatLng = LatLng(warehouseLatLng.latitude + offset, warehouseLatLng.longitude);
    } else {
      warehouseLatLng = LatLng(warehouseLatLng.latitude, warehouseLatLng.longitude + offset);
    }

    return calculateDistanceWithRandomBuffer(currentLatLng, warehouseLatLng);
  }

  Future<String> getAddressFromLatLng(String latLngString) async {
    try {
      LatLng latLng = parseLatLng(latLngString);
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.subLocality}, ${place.locality},${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      } else {
        return "Address not found";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
