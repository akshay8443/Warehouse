import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  LocationSelectionScreenState createState() => LocationSelectionScreenState();
}

class LocationSelectionScreenState extends State<LocationSelectionScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  final TextEditingController addressController = TextEditingController();
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    addressController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      Position position = await _determinePosition();
      if (!mounted) return;

      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        currentLocation = location;
        isLoadingLocation = false;
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(location));
      await _getAddressFromLatLng(location);
      if (!mounted) return;
      locationProvider.updateLocation(addressController.text, location);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      if (!mounted) return;
      setState(() {
        isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placeMarks.isNotEmpty) {
        Placemark place = placeMarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        if (!mounted) return;
        setState(() {
          addressController.text = address;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _selectAddress() async {
    String address = addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address.')),
      );
      return;
    }
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        if (!mounted) return;
        final location = LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          currentLocation = location;
        });
        mapController?.animateCamera(CameraUpdate.newLatLng(location));
        locationProvider.updateLocation(address, location);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error selecting address: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find this address.')),
      );
    }
  }

  void _returnLocation() {
    if (currentLocation != null) {
      LocationData locationData =
          LocationData(currentLocation!, addressController.text);
      Navigator.pop(context, locationData);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: AppTheme.primary,
            ),
            onPressed: _returnLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                        if (currentLocation != null) {
                          mapController?.animateCamera(
                            CameraUpdate.newLatLng(currentLocation!),
                          );
                        }
                      },
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(28.596634, 77.404570),
                        zoom: 14,
                      ),
                      markers: currentLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('currentLocation'),
                                position: currentLocation!,
                              )
                            }
                          : {},
                      onTap: (position) {
                        setState(() {
                          currentLocation = position;
                        });
                        _getAddressFromLatLng(position);
                      },
                    ),
                    if (isLoadingLocation)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                              labelText: 'Enter Address',
                              border: InputBorder.none,
                              hintText: 'Type your address here',
                              hintStyle: TextStyle(fontSize: 12)),
                          style: const TextStyle(
                            color: AppTheme.primary, // Text color
                            fontSize: 10, // Font size
                            fontWeight: FontWeight.w700,
                          ),
                          onSubmitted: (_) => _selectAddress(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _selectAddress,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 6.0, horizontal: 24.0), // Text color
                elevation: 5,
              ),
              child: const Text(
                'Get Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationData {
  final LatLng latLng;
  final String address;
  LocationData(this.latLng, this.address);
}

class ElevatedCard extends StatelessWidget {
  final Widget child;

  const ElevatedCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
