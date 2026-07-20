import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Lisofy/Transportation/User/booking_details.dart';
import 'package:Lisofy/Transportation/User/location_screen.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:Lisofy/Transportation/common/provider/loader_notifier.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();
  String? _pickupAddress;
  String? _dropAddress;
  String? _errorMessage;
  String? distanceCalculated;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.7041, 77.1025),
    zoom: 14.5,
  );

  Future<void> _navigateToLocationScreen(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationScreen(),
      ),
    );
    if (!mounted) return;

    if (result != null && result is String) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result;
          _pickupAddress = result;
        } else {
          _dropController.text = result;
          _dropAddress = result;
        }
        _validateAddresses();
      });
    }
  }

  void _validateAddresses() {
    if (_pickupAddress != null && _dropAddress != null) {
      setState(() {
        _errorMessage = (_pickupAddress == _dropAddress)
            ? "Pickup and Drop locations cannot be the same!"
            : null;
      });
    }
  }

  Future<double?> getDistanceAddress(
      String pickupAddress, String dropAddress) async {
    const apiKey = 'AIzaSyDxbkZhKCXDGPdtOWxTPxFBg_tjAd3jsTk';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$pickupAddress&destinations=$dropAddress&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (kDebugMode) {
        print('Full API Response: $data');
      }

      if (data['status'] == 'REQUEST_DENIED') {
        debugPrint('API Error: ${data['error_message']}');
        Fluttertoast.showToast(
          msg:
              "Request denied: ${data['error_message'] ?? 'Invalid API key or setup'}",
          backgroundColor: Colors.red,
        );
        return null;
      }

      if (data['rows'].isNotEmpty && data['rows'][0]['elements'].isNotEmpty) {
        final distance =
            data['rows'][0]['elements'][0]['distance']['value'] / 1000;
        return distance;
      } else {
        Fluttertoast.showToast(
            msg: "No data in response!", backgroundColor: Colors.red);
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed to fetch distance: ${response.statusCode}",
        backgroundColor: Colors.red,
      );
    }
    return null;
  }

  void _checkAndProceed() async {
    final loaderNotifier = context.read<LoaderNotifier>();
    if (_pickupAddress != null &&
        _dropAddress != null &&
        _pickupAddress != _dropAddress) {
      loaderNotifier.showLoader();
      try {
        final distance =
            await getDistanceAddress(_pickupAddress!, _dropAddress!);
        if (kDebugMode) {
          print("Distance$distance");
        }
        if (!mounted) return;
        loaderNotifier.hideLoader();
        if (distance != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(
                pickUpAddress: _pickupAddress!,
                finalAddress: _dropAddress!,
                distance: distance.toString(),
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to calculate distance!",
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        loaderNotifier.hideLoader();
        Fluttertoast.showToast(
          msg: "Error fetching distance: $e",
          backgroundColor: Colors.red,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Pickup and Drop locations cannot be the same!",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => LoaderNotifier(),
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            title: "Transportation",
            onBackPressed: () => Navigator.pop(context),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                child: Column(
                  children: [
                    _buildAddressField(
                      controller: _pickupController,
                      hint: "Pickup Address",
                      icon: Icons.location_on,
                      iconColor: Colors.green,
                      onTap: () => _navigateToLocationScreen(true),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildAddressField(
                      controller: _dropController,
                      hint: "Drop Address",
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      onTap: () => _navigateToLocationScreen(false),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              if (_pickupAddress != null &&
                  _dropAddress != null &&
                  _pickupAddress != _dropAddress)
                Positioned(
                  bottom: screenHeight * 0.04,
                  left: screenWidth * 0.06,
                  right: screenWidth * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                    onPressed: _checkAndProceed,
                    child: const Text(
                      "CHECK FARE",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              Consumer<LoaderNotifier>(
                builder: (context, loaderNotifier, _) {
                  return loaderNotifier.isLoading
                      ? Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primary)),
                        )
                      : const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  controller.text.isEmpty ? hint : controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
