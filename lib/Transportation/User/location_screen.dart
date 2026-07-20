import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_loader.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:Lisofy/Transportation/common/provider/loader_notifier.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

const String googleApiKey = "AIzaSyDxbkZhKCXDGPdtOWxTPxFBg_tjAd3jsTk";

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  final TextEditingController _addressController = TextEditingController();
  List<Map<String, dynamic>> _placeSuggestions = [];
  bool _showConfirmButton = false;

  Future<List<Map<String, dynamic>>> fetchPlaceSuggestions(String input) async {
    const String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    final requestUrl =
        "$baseUrl?input=$input&key=$googleApiKey&components=country:in";
    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List predictions = data['predictions'] ?? [];
        return predictions
            .map((place) => {
                  "description": place['description'],
                  "place_id": place['place_id']
                })
            .toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    const String baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
    final requestUrl = "$baseUrl?latlng=$lat,$lng&key=$googleApiKey";
    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return "Unknown location";
  }

  Future<void> _getCurrentLocation() async {
    final loader = Provider.of<LoaderNotifier>(context, listen: false);
    loader.showLoader();
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      );
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      String address =
          await _getAddressFromLatLng(position.latitude, position.longitude);
      setState(() {
        _addressController.text = address;
        _showConfirmButton = true;
      });
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      loader.hideLoader();
    }
  }

  void _onPlaceSelected(String placeId, String description) async {
    setState(() {
      _addressController.text = description;
      _placeSuggestions = [];
      _showConfirmButton = true;
    });
  }

  void _confirmAddress() {
    if (_addressController.text.isNotEmpty) {
      Navigator.pop(context, _addressController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final loader = Provider.of<LoaderNotifier>(context);
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "TRANSPORTATION",
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        setState(() => _placeSuggestions = []);
                        return;
                      }
                      final suggestions = await fetchPlaceSuggestions(value);
                      setState(() {
                        _placeSuggestions = suggestions;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search for a location",
                      prefixIcon:
                          const Icon(Icons.search, color: AppTheme.primary),
                      suffixIcon: _addressController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _addressController.clear();
                                  _placeSuggestions = [];
                                  _showConfirmButton = false;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                    ),
                  ),
                  if (_placeSuggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _placeSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _placeSuggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on,
                                color: AppTheme.primary),
                            title: Text(suggestion["description"]),
                            onTap: () => _onPlaceSelected(
                                suggestion["place_id"],
                                suggestion["description"]),
                          );
                        },
                      ),
                    ),
                  TextButton.icon(
                    onPressed: loader.isLoading ? null : _getCurrentLocation,
                    icon:
                        const Icon(Icons.my_location, color: AppTheme.primary),
                    label: const Text("Use Current Location",
                        style: TextStyle(color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
            if (loader.isLoading)
              CustomProgressIndicator(
                color: AppTheme.primary,
                size: screenHeight * 0.065,
                text: "Loading...",
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              bottom:
                  _showConfirmButton ? screenWidth * 0.1 : -screenWidth * 0.3,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _showConfirmButton ? 1 : 0,
                child: ElevatedButton.icon(
                  onPressed: _confirmAddress,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Confirm Address",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
