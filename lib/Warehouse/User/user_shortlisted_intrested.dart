import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/Warehouse/User/interested_warehouse_details_screen.dart';
import 'package:Lisofy/Warehouse/User/models/short_list_model.dart';
import 'package:Lisofy/Warehouse/User/models/interested_data_model.dart';
import 'package:Lisofy/distance_calculator.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class UserShortListedInterested extends StatefulWidget {
  const UserShortListedInterested({super.key});
  @override
  State<UserShortListedInterested> createState() =>
      _UserShortListedInterestedState();
}

class _UserShortListedInterestedState extends State<UserShortListedInterested> {
  bool isShortlisted = true;
  List<InterestedModel> interestedWarehouses = [];
  List<ShortListModel> shortlistedWarehouses = [];
  bool isLoading = true;
  String phone = "";
  @override
  void initState() {
    super.initState();
    fetchShortlistedWarehouses();

    ///Interested data
    fetchWarehouses();
  }

  /// Fetch data from API and filter based on type
  Future<void> fetchWarehouses() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      phone = pref.getString("phone") ?? '';
      if (phone.startsWith("+91")) {
        phone = phone.substring(3);
      }
      if (kDebugMode) {
        print("Phone is $phone");
      }
      final String apiUrl =
          "https://xpacesphere.com/api/Wherehousedt/Intrest_warehousedata?mobile=$phone";
      if (kDebugMode) {
        print("Constructed API URL: $apiUrl");
      }
      final response = await http.get(Uri.parse(apiUrl));
      if (kDebugMode) {
        print("HTTP Status Code: ${response.statusCode}");
      }
      if (kDebugMode) {
        print("API Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("API hit successful");
        }

        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (kDebugMode) {
          print("Decoded JSON Response: $jsonResponse");
        }

        if (jsonResponse['status'] == 200) {
          List<dynamic> data = jsonResponse['data'] ?? [];
          if (kDebugMode) {
            print("Extracted Data List: $data");
          }
          List<InterestedModel> interested = [];
          for (var item in data) {
            try {
              InterestedModel warehouse = InterestedModel.fromJson(item);
              if (warehouse.type == 'Interested') {
                interested.add(warehouse);
              } else if (warehouse.type == 'Shortlisted') {}
            } catch (e) {
              if (kDebugMode) {
                print("Error parsing warehouse data: $e");
              }
            }
          }
          if (!mounted) return;
          setState(() {
            interestedWarehouses = interested;
            isLoading = false;
          });

          if (kDebugMode) {
            print("Interested Warehouses: $interested");
          }
        } else {
          if (kDebugMode) {
            print("Error: ${jsonResponse['message']}");
          }
          throw Exception(jsonResponse['message']);
        }
      } else {
        if (kDebugMode) {
          print(
              "Error: Failed to load data with status ${response.statusCode}");
        }
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception occurred: $e");
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  ///ShortlistData
  Future<void> fetchShortlistedWarehouses() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      phone = pref.getString("phone") ?? '';
      if (phone.startsWith("+91")) {
        phone = phone.substring(3);
      }
      if (kDebugMode) {
        print("Phone is $phone");
      }
      final String apiUrl =
          "https://xpacesphere.com/api/Wherehousedt/GetSortlist_warehouse?_mobile=$phone";
      if (kDebugMode) {
        print("Constructed API URL: $apiUrl");
      }
      final response = await http.get(Uri.parse(apiUrl));
      if (kDebugMode) {
        print("HTTP Status Code: ${response.statusCode}");
      }
      if (kDebugMode) {
        print("API Response Body: ${response.body}");
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("API hit successful");
        }
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (kDebugMode) {
          print("Decoded JSON Response: $jsonResponse");
        }
        if (jsonResponse['status'] == 200) {
          List<dynamic> data = jsonResponse['data'] ?? [];
          if (kDebugMode) {
            print("Extracted Data List: $data");
          }
          List<ShortListModel> shortlisted = [];
          for (var item in data) {
            try {
              if (kDebugMode) {
                print("Parsing item: $item");
              }
              ShortListModel warehouse = ShortListModel.fromJson(item);
              shortlisted.add(warehouse);
            } catch (e) {
              if (kDebugMode) {
                print("Error parsing warehouse data: $e");
              }
            }
          }
          if (!mounted) return;
          setState(() {
            shortlistedWarehouses = shortlisted;
            isLoading = false;
          });
          if (kDebugMode) {
            print("Shortlisted Warehouses: $shortlisted");
          }
        } else {
          if (kDebugMode) {
            print("Error: ${jsonResponse['message']}");
          }
          throw Exception(jsonResponse['message']);
        }
      } else {
        if (kDebugMode) {
          print(
              "Error: Failed to load data with status ${response.statusCode}");
        }
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception occurred: $e");
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (isShortlisted) {
      await fetchShortlistedWarehouses();
    } else {
      await fetchWarehouses();
    }
  }

  DistanceCalculator distanceCalculator = DistanceCalculator();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                      ),
                      height: screenHeight * 0.18,
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.065,
                            left: screenWidth * 0.045,
                            right: screenWidth * 0.028,
                            bottom: screenWidth * 0.17,
                          ),
                          child: Container(
                            //height: screenHeight*0.09,
                            width: screenWidth * 0.465,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isShortlisted = true;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: screenWidth * 0.227,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isShortlisted
                                          ? AppTheme.primary
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      S.of(context).shortlisted,
                                      style: TextStyle(
                                        color: isShortlisted
                                            ? Colors.white
                                            : AppTheme.primary,
                                        fontSize: 12, // Smaller font size
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isShortlisted = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: screenWidth * 0.23,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: !isShortlisted
                                          ? AppTheme.primary
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      S.of(context).interested,
                                      style: TextStyle(
                                        color: !isShortlisted
                                            ? Colors.white
                                            : AppTheme.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06, vertical: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (isShortlisted)
                                  _buildShortlistedContent()
                                else
                                  _buildInterestedContent(),
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
    );
  }

  Widget _buildShortlistedContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: _refreshData,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: shortlistedWarehouses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/warehousegift.png',
                          height: screenHeight * 0.3,
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          S.of(context).no_shortlisted_warehouses_found,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: shortlistedWarehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = shortlistedWarehouses[index];
                      String wHouseAddress = warehouse.wHouseAddress;
                      return FutureBuilder<double>(
                        future: Permission.location.isGranted.then((granted) {
                          if (granted) {
                            return distanceCalculator
                                .getDistanceFromCurrentToWarehouse(
                                    wHouseAddress);
                          } else {
                            return Future.error("Location permission denied");
                          }
                        }),
                        builder: (context, snapshot) {
                          double? distanceInKm = snapshot.hasData
                              ? (snapshot.data ?? 0.0) / 1000
                              : null;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InterestedWarehouseDetailsScreen(
                                          warehouses: warehouse),
                                ),
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.27,
                              width: screenWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.4),
                                    spreadRadius: 0.5,
                                    blurRadius: 0.5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://xpacesphere.com${warehouse.image}",
                                      width: double.infinity,
                                      height: screenHeight * 0.15,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        ImageAssets.defaultImage,
                                        width: double.infinity,
                                        height: screenHeight * 0.15,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Rent : ${warehouse.wHouseRentPerSQFT} per sq.ft",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "${S.of(context).type} : ${warehouse.wHouseType}",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Center(
                                    child: snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Calculating distance...",
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        : snapshot.hasError
                                            ? TextButton(
                                                onPressed: () =>
                                                    requestLocationPermission(
                                                        context),
                                                style: ButtonStyle(
                                                  padding:
                                                      WidgetStateProperty.all(
                                                          EdgeInsets.zero),
                                                  minimumSize:
                                                      WidgetStateProperty.all(
                                                          const Size(0, 0)),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                child: const Text(
                                                  "\u00a9 Enable location to see distance",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme.primary,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  "${distanceInKm!.toStringAsFixed(3)} km away",
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestedContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: _refreshData,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.99,
            child: interestedWarehouses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/warehousegift.png',
                          height: screenHeight * 0.3,
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          S.of(context).express_interest_to_get_callback,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: interestedWarehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = interestedWarehouses[index];
                      String whouseAddress = warehouse.wHouseAddress;
                      return FutureBuilder<double>(
                        future: Permission.location.isGranted.then((granted) {
                          if (granted) {
                            return distanceCalculator
                                .getDistanceFromCurrentToWarehouse(
                                    whouseAddress);
                          } else {
                            return Future.error("Location permission denied");
                          }
                        }),
                        builder: (context, snapshot) {
                          double? distanceInKm = snapshot.hasData
                              ? (snapshot.data ?? 0.0) / 1000
                              : null;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InterestedWarehouseDetailsScreen(
                                          warehouses: warehouse),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.9),
                                    spreadRadius: 0.5,
                                    blurRadius: 0.5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://xpacesphere.com${warehouse.image}",
                                      width: double.infinity,
                                      height: screenHeight * 0.16,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        ImageAssets.defaultImage,
                                        width: double.infinity,
                                        height: screenHeight * 0.16,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Rent : ${warehouse.wHouseRentPerSQFT} per sq.ft",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "${S.of(context).type} : ${warehouse.wHouseType}",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                          const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Calculating distance...",
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        else if (snapshot.hasError)
                                          TextButton(
                                            onPressed: () =>
                                                requestLocationPermission(
                                                    context),
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(
                                                  EdgeInsets.zero),
                                              minimumSize:
                                                  WidgetStateProperty.all(
                                                      const Size(0, 0)),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              "\u00a9 Enable location to see distance",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        else
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "${distanceInKm!.toStringAsFixed(3)} km away",
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> requestLocationPermission(BuildContext context) async {
    final navigator = Navigator.of(context);
    PermissionStatus status = await Permission.location.request();
    if (!context.mounted) return;
    if (status.isDenied || status.isPermanentlyDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigator.context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primary, size: 28),
                SizedBox(width: 8),
                Text(
                  "Enable Location",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Get the most accurate distance to warehouses near you.\n\n"
                  "✅ Find the best locations quickly\n"
                  "✅ Get estimated travel distances\n"
                  "✅ Improve your experience",
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "We respect your privacy and do not store or share your location data.",
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(),
                child:
                    const Text("Not Now", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.settings),
                label: const Text("Open Settings"),
              ),
            ],
          ),
        );
      });
    }
  }
}
