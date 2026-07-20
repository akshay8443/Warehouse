import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchLocationUser extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final int? initialDistance;
  final String? initialLoc;

  const SearchLocationUser({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialDistance,
    this.initialLoc,
  });

  @override
  State<SearchLocationUser> createState() => _SearchLocationUserState();
}

class _SearchLocationUserState extends State<SearchLocationUser> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _placeSuggestions = [];
  bool _isUserSelection = false;
  dynamic _selectedValue;
  late String loc;
  Map<String, double>? _selectedLocation;

  @override
  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = {
        "latitude": widget.initialLatitude!,
        "longitude": widget.initialLongitude!,
      };
    }
    _selectedValue = widget.initialDistance ?? 20;
    _controller.text = widget.initialLoc ?? '';
    _controller.addListener(() {
      if (!_isUserSelection && _controller.text.isNotEmpty) {
        _onSearchChanged(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String input) async {
    if (kDebugMode) {
      print("User input: $input");
    }
    if (input.isNotEmpty) {
      try {
        final suggestions = await fetchPlaceSuggestions(input);
        if (kDebugMode) {
          print("Fetched suggestions: $suggestions");
        }
        setState(() {
          _placeSuggestions = suggestions;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching suggestions: $e");
        }
      }
    } else {
      setState(() {
        _placeSuggestions = [];
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlaceSuggestions(String input) async {
    const String apiKey = "AIzaSyDxbkZhKCXDGPdtOWxTPxFBg_tjAd3jsTk";
    const String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    final requestUrl =
        "$baseUrl?input=$input&key=$apiKey&components=country:in";

    if (kDebugMode) {
      print("Request URL: $requestUrl");
    }
    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (kDebugMode) {
        print("API Response Code: ${response.statusCode}");
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print("API Response Body: ${response.body}");
        }
        List predictions = data['predictions'] ?? [];
        return predictions
            .map((place) => {
                  "description": place['description'],
                  "place_id": place['place_id']
                })
            .toList();
      } else {
        if (kDebugMode) {
          print(
              "Failed to fetch suggestions. Status Code: ${response.statusCode}");
        }
        throw Exception("Failed to fetch suggestions");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception during API call: $e");
      }
      return [];
    }
  }

  Future<Map<String, double>?> fetchPlaceDetails(String placeId) async {
    const String apiKey = "AIzaSyDxbkZhKCXDGPdtOWxTPxFBg_tjAd3jsTk";
    const String baseUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";
    final requestUrl = "$baseUrl?place_id=$placeId&key=$apiKey";
    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          double lat = location['lat'];
          double lng = location['lng'];
          return {"latitude": lat, "longitude": lng};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching place details: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    List<dynamic> values = [5, 10, 20, 40];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.primary,
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: AppTheme.primary,
                      height: screenHeight * 0.18,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.070,
                          left: screenWidth * 0.045,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_sharp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(0),
                            topRight: Radius.circular(screenWidth * 0.1),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.035),
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText:
                                          (widget.initialLoc ?? '').isNotEmpty
                                              ? widget.initialLoc
                                              : 'Search Location',
                                      label: Text(
                                        S.of(context).location,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      suffixIcon:
                                          (widget.initialLoc ?? '').isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear,
                                                      color: Colors.grey),
                                                  onPressed: () {
                                                    setState(() {
                                                      _controller.clear();
                                                    });
                                                  },
                                                )
                                              : null,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _placeSuggestions.length,
                                  itemBuilder: (context, index) {
                                    final suggestion = _placeSuggestions[index];
                                    return ListTile(
                                      title:
                                          Text(suggestion['description'] ?? ''),
                                      onTap: () async {
                                        setState(() {
                                          _isUserSelection = true;
                                          _controller.text =
                                              suggestion['description'] ?? '';
                                          _placeSuggestions = [];
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () {
                                          _isUserSelection = false;
                                        });
                                        String placeId = suggestion['place_id'];
                                        final coordinates =
                                            await fetchPlaceDetails(placeId);
                                        if (coordinates != null) {
                                          setState(() {
                                            _selectedLocation = coordinates;
                                            loc = suggestion['description'];
                                          });
                                          if (kDebugMode) {
                                            print(
                                                "Selected Place: ${suggestion['description']}");
                                          }
                                          if (kDebugMode) {
                                            print(
                                                "Latitude: ${coordinates['latitude']}, Longitude: ${coordinates['longitude']}");
                                          }
                                        } else {
                                          if (kDebugMode) {
                                            print(
                                                "Failed to fetch coordinates for ${suggestion['description']}");
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.07),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        S.of(context).radius_in_km,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16),
                                      )),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: values.map((value) {
                                    bool isSelected = _selectedValue == value;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedValue = value;
                                        });
                                        if (kDebugMode) {
                                          print("Selected: $value");
                                        }
                                      },
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.03),
                                        ),
                                        child: Container(
                                          width: screenWidth * 0.13,
                                          height: screenHeight * 0.05,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.black
                                                : const Color(0xffD9D9D9),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xff585858),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.03),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$value',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: screenWidth * 0.5,
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_selectedLocation != null && _selectedValue != null) {
                  Navigator.pop(context, {
                    "latitude": _selectedLocation!['latitude'],
                    "longitude": _selectedLocation!['longitude'],
                    "distance": _selectedValue,
                    "loc": loc,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                elevation: 5,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.01),
              ),
              child: Text(
                S.of(context).search,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          )
        ],
      ),
    );
  }
}
