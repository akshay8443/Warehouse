import 'package:Lisofy/resources/app_theme.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Lisofy/Animation/glitter_border.dart';
import 'package:Lisofy/Warehouse/Partner/home_screen.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/sorting_provider.dart';
import 'package:Lisofy/Warehouse/User/models/warehouse_model.dart';
import 'package:Lisofy/Warehouse/User/search_location_user.dart';
import 'package:Lisofy/Warehouse/User/user_notification_screen.dart';
import 'package:Lisofy/Warehouse/User/user_profile_screen.dart';
import 'package:Lisofy/Warehouse/User/user_shortlisted_intrested.dart';
import 'package:Lisofy/Warehouse/User/warehouse_details.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/new_home_page.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserHomePage extends StatefulWidget {
  final double latitude;
  final double longitude;
  const UserHomePage(
      {super.key, required this.latitude, required this.longitude});
  @override
  State<UserHomePage> createState() => UserHomePageState();
}

class UserHomePageState extends State<UserHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isLoading = false;
  final PageController _pageController = PageController();
  late Future<List<WarehouseModel>> futureWarehouses;
  int warehouseCount = 0;
  String address = "";
  String? phone;
  double searchedLatitude = 0.0;
  double searchedLongitude = 0.0;
  int searchedDistance = 0;
  String searchedLoc = "";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  int _currentIndex = 0;
  final List<String> _images = [
    //'https://xpacesphere.com/Content/NewFolder/warehouse_21.jpg',
    'https://astuglobaltech.in/wp-content/uploads/2025/08/Frame-507.png',
    'https://xpacesphere.com/Content/NewFolder/warehouse_22.jpg'
  ];

  late PageController _pageControllerSlider;
  late Timer _timer;
  bool isSortApplied = false;
  bool isNearbyEnabled = false;
  bool isPriceEnabled = false;
  bool isPriceEnabledmaxtomin = false;
  bool isAreaMinToMax = false;
  bool isAreaMaxToMin = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<String> constructionTypes = [''];
  List<String> warehouseTypes = [''];
  String rentRange = '';
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("CurrentLat  ${widget.latitude}");
    }
    if (kDebugMode) {
      print("CurrentLong  ${widget.longitude}");
    }

    ///Warehouse Fetching
    futureWarehouses = fetchWarehouses(
        widget.latitude, widget.longitude, 20, [], [], rentRange);
    _pageControllerSlider = PageController(initialPage: _currentIndex);
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || !_pageControllerSlider.hasClients) {
        return;
      }
      if (_currentIndex < _images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageControllerSlider.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.slowMiddle,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  double getValidCoordinate(double? searchedValue, double fallbackValue) {
    return (searchedValue != null && searchedValue != 0.0)
        ? searchedValue
        : fallbackValue;
  }

  int getValidDistance(int? searchedValue, int fallbackValue) {
    return (searchedValue != null && searchedValue != 0)
        ? searchedValue
        : fallbackValue;
  }

  Future<void> _refreshData() async {
    double latitude = getValidCoordinate(searchedLatitude, widget.latitude);
    double longitude = getValidCoordinate(searchedLongitude, widget.longitude);
    int distance = getValidDistance(searchedDistance, 20);

    setState(() {
      isLoading = true;
    });

    List<WarehouseModel> updatedWarehouses =
        await fetchWarehouses(latitude, longitude, distance, [], [], rentRange);

    setState(() {
      futureWarehouses = Future.value(updatedWarehouses);
      isLoading = false;
    });
  }

  List imageList = [];

  // Future<List<WarehouseModel>> fetchWarehouses(
  //     double latitude,
  //     double longitude,
  //     int distance,
  //     List<String> constructionTypes,
  //     List<String> warehouseTypes,
  //     String rentRange) async {
  //    //const url = 'https://xpacesphere.com/api/Wherehousedt/GetNLocation';
  //   const url = 'http://15.206.189.22:8080/api/v2/datawarehouses';
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   phone = pref.getString("phone");
  //   final Map<String, dynamic> body = {
  //     "latitude": latitude.toString(),
  //     "longitude": longitude.toString(),
  //     "distance": distance
  //   };
  //   if (kDebugMode) {
  //     print("Body $body");
  //   }
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(body),
  //     );
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['status'] == 200 && responseData['data'] != null) {
  //         if (kDebugMode) {
  //           print("Api data${response.body}");
  //         }
  //         final List<dynamic> jsonResponse = responseData['data'];
  //         warehouseCount = jsonResponse.length;
  //         return jsonResponse
  //             .map((data) => WarehouseModel.fromJson(data))
  //             .toList();
  //       } else {
  //         if (kDebugMode) {
  //           print("No data found in API response.");
  //         }
  //         warehouseCount = 0;
  //         return [];
  //       }
  //     } else {
  //       throw Exception(
  //           'Failed to fetch warehouses. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error fetching warehouses: $e");
  //     }
  //     return [];
  //   }
  // }

  Future<List<WarehouseModel>> fetchWarehouses(
      double latitude,
      double longitude,
      int distance,
      List<String> constructionTypes,
      List<String> warehouseTypes,
      String rentRange) async {
    // Build query parameters for GET
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'distance': distance.toString(),
      // Add more parameters if your API supports filtering by constructionTypes, warehouseTypes, rentRange, etc.
    };

    final uri = Uri.http(
        '3.110.172.156:8083', '/api/v2/datawarehouses', queryParameters);

    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        // Here response.body may be a list or wrapped in 'data' - adjust accordingly
        final responseData = json.decode(response.body);

        // If responseData is a list directly:
        final List<dynamic> jsonResponse =
            responseData is List ? responseData : responseData['data'] ?? [];

        warehouseCount = jsonResponse.length;

        return jsonResponse
            .map((data) => WarehouseModel.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch warehouses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching warehouses: $e");
      }
      return [];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _pageController.dispose();
    _pageControllerSlider.dispose();
    super.dispose();
  }

  void showFilterDialog(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 750),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: screenHeight * 0.6,
            height: screenWidth * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.2),
                bottomLeft: Radius.circular(screenWidth * 0.2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        S.of(context).filter,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                            color: Colors.black),
                      ),
                      const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.black,
                      )
                    ],
                  ),
                  const Text(
                    "data",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.translate(
          offset:
              Offset(MediaQuery.of(context).size.width * (1 - anim1.value), 0),
          child: Transform.rotate(
            angle: (1 - anim1.value) * 0.9,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  _buildHomePage(screenWidth, screenHeight),
                  _userShortListedInterestedPage(screenWidth, screenHeight),
                  _buildAccountPage(screenWidth, screenHeight),
                ],
              ),
            ),
            Container(
              color: AppTheme.primary,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.home_filled),
                          color: _selectedIndex == 0
                              ? Colors.white
                              : Colors.grey[300],
                          onPressed: () => _onItemTapped(0),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _selectedIndex == 1
                                      ? AppTheme.primary
                                      : const Color(0xffD9D9D9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: ImageIcon(
                                    const AssetImage(ImageAssets.storage),
                                    color: _selectedIndex == 1
                                        ? Colors.white
                                        : AppTheme.primary,
                                    size: 24,
                                  ),
                                  onPressed: () => _onItemTapped(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: ImageIcon(
                            _selectedIndex == 2
                                ? const AssetImage("assets/images/Gear2.png")
                                : const AssetImage('assets/images/Gear.png'),
                            color: _selectedIndex == 2
                                ? Colors.white
                                : Colors.grey[300],
                          ),
                          onPressed: () => _onItemTapped(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(double screenWidth, double screenHeight) {
    final sortingProvider =
        Provider.of<SortingProvider>(context, listen: false);
    return Container(
      color: AppTheme.primary,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              height: screenHeight * 0.22,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.015,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          ImageAssets.appLogo,
                          fit: BoxFit.fill,
                          height: screenHeight * 0.065,
                          width: screenWidth * 0.3,
                        ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.only(
                              right: screenWidth * 0.06,
                              top: screenHeight * 0.01),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomPaint(
                                      painter: GlitterBorderPainter(
                                          _animation.value),
                                      child: SizedBox(
                                        width: screenWidth * 0.32,
                                        height: screenHeight * 0.037,
                                        child: TextButton(
                                          onPressed: () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HomeScreen()));
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      screenWidth * 0.03),
                                              side: const BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                          ),
                                          child: Animate(
                                              effects: const [
                                                FadeEffect(),
                                                ScaleEffect()
                                              ],
                                              child: Text(
                                                S.of(context).became_partner,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color: AppTheme.primary,
                                                ),
                                              )
                                                  .animate(
                                                    delay: 500.ms,
                                                    onPlay: (controller) =>
                                                        controller.repeat(),
                                                  )
                                                  .tint(color: Colors.purple)),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _openSearchLocationPage,
                          child: SizedBox(
                            width: screenWidth * 0.79,
                            height: screenHeight * 0.09,
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: screenHeight * 0.05,
                                width: double.infinity,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: searchedLoc.isNotEmpty
                                        ? searchedLoc
                                        : S.of(context).search_by_location,
                                    hintStyle: const TextStyle(
                                        color: Colors.blueGrey, fontSize: 12),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                    prefixIcon: const Icon(Icons.search,
                                        color: AppTheme.primary, size: 25),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        InkWell(
                          child: Container(
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.12,
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications,
                                color: AppTheme.primary,
                                size: 25,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UserNotificationScreen()));
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$warehouseCount ${S.of(context).warehouse_near_you}",
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewHomePage(
                                            longitude: widget.longitude,
                                            latitude: widget.latitude,
                                          )));
                            },
                            child: Column(
                              children: [
                                const ImageIcon(
                                  AssetImage(ImageAssets.backArrow),
                                  color: Colors.white,
                                ),
                                Text(
                                  S.of(context).back,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w100),
                                )
                              ],
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: screenHeight * 0.044,
                              width: screenWidth * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: TextButton(
                                  child: Text(
                                    "${S.of(context).sort}↑↓",
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                screenWidth * 0.059)),
                                      ),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setModalState) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.57,
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    screenWidth * 0.05),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Container(
                                                      height:
                                                          screenHeight * 0.05,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primary,
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            S
                                                                .of(context)
                                                                .filter,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.clear,
                                                              color: sortingProvider
                                                                      .selectedSortOption
                                                                      .isNotEmpty
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                            ),
                                                            onPressed: sortingProvider
                                                                    .selectedSortOption
                                                                    .isNotEmpty
                                                                ? () {
                                                                    setModalState(
                                                                        () {
                                                                      sortingProvider
                                                                          .selectedSortOption = '';
                                                                      isSortApplied =
                                                                          false;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                : null,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    _buildSortOption(
                                                      context,
                                                      sortingProvider,
                                                      label:
                                                          S.of(context).near_by,
                                                      optionValue: 'Nearby',
                                                    ),
                                                    _buildSortOption(
                                                      context,
                                                      sortingProvider,
                                                      label: S
                                                          .of(context)
                                                          .price_min_to_max,
                                                      optionValue:
                                                          'PriceMinToMax',
                                                    ),
                                                    _buildSortOption(
                                                      context,
                                                      sortingProvider,
                                                      label: S
                                                          .of(context)
                                                          .price_max_to_min,
                                                      optionValue:
                                                          'PriceMaxToMin',
                                                    ),
                                                    _buildSortOption(
                                                      context,
                                                      sortingProvider,
                                                      label: S
                                                          .of(context)
                                                          .area_min_to_max,
                                                      optionValue:
                                                          'AreaMinToMax',
                                                    ),
                                                    _buildSortOption(
                                                      context,
                                                      sortingProvider,
                                                      label: S
                                                          .of(context)
                                                          .area_max_to_min,
                                                      optionValue:
                                                          'AreaMaxToMin',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            InkWell(
                              child: Container(
                                margin:
                                    EdgeInsets.only(right: screenWidth * 0.07),
                                height: screenHeight * 0.044,
                                width: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                    child: Text(
                                  S.of(context).filter,
                                  style: const TextStyle(color: Colors.white),
                                )),
                              ),
                              onTap: () {
                                showAdvancedFiltersBottomSheet(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const Spacer()
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
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.20,
                        width: screenWidth,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageControllerSlider,
                              itemCount: _images.length,
                              onPageChanged: (int index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppTheme.primary, width: 3),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: _images[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: screenHeight * 0.15,

                                    /// **Shimmer Effect as a Placeholder**
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.white,
                                      child: Container(
                                        width: double.infinity,
                                        height: screenHeight * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),

                                    /// ** Error Widget**
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      ImageAssets.defaultImage,
                                      width: double.infinity,
                                      height: screenHeight * 0.15,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: screenHeight * 0.025,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    List.generate(_images.length, (index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      width: _currentIndex == index ? 16 : 16,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? AppTheme.primary
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      /// Api Warehouse data
                      Expanded(
                        child: RefreshIndicator(
                            color: AppTheme.primary,
                            backgroundColor: Colors.white,
                            onRefresh: _refreshData,
                            child: FutureBuilder<List<WarehouseModel>>(
                              future: futureWarehouses,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: SpinKitCircle(
                                    color: AppTheme.primary,
                                  ));
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Column(
                                    children: [
                                      Image.asset(ImageAssets.something),
                                      Text(
                                        S.of(context).please_wait_for_sometime,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      )
                                    ],
                                  ));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return SingleChildScrollView(
                                    child: Center(
                                        child: Column(
                                      children: [
                                        Image.asset(
                                            ImageAssets.noWarehouseBanner),
                                        SizedBox(
                                          height: screenHeight * 0.05,
                                        ),
                                        Stack(
                                          children: [
                                            Image.asset(
                                                ImageAssets.noWarehouse),
                                            // Container(
                                            //     margin: EdgeInsets.only(
                                            //         bottom: screenHeight * 0.1),
                                            //     child: const Center(
                                            //         child: Text(
                                            //           "Sorry...",
                                            //           style: TextStyle(
                                            //               fontWeight: FontWeight.w800,
                                            //               fontSize: 18),
                                            //         ))),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: screenHeight * 0.1),
                                              child: Center(
                                                  child: Text(
                                                S
                                                    .of(context)
                                                    .no_warehouse_near_you,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18),
                                              )),
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                                  );
                                } else {
                                  return Consumer<SortingProvider>(builder:
                                      (context, sortingProvider, child) {
                                    final List<WarehouseModel> warehouses =
                                        List.from(snapshot.data!);
                                    if (sortingProvider.selectedSortOption ==
                                        'PriceMinToMax') {
                                      warehouses.sort((a, b) {
                                        if (a.wHouseRent == null &&
                                            b.wHouseRent == null) {
                                          return 0;
                                        }
                                        if (a.wHouseRent == null) return 1;
                                        if (b.wHouseRent == null) return -1;
                                        return a.wHouseRent!
                                            .compareTo(b.wHouseRent!);
                                      });
                                    } else if (sortingProvider
                                            .selectedSortOption ==
                                        'PriceMaxToMin') {
                                      warehouses.sort((a, b) {
                                        if (a.wHouseRent == null &&
                                            b.wHouseRent == null) {
                                          return 0;
                                        }
                                        if (a.wHouseRent == null) return 1;
                                        if (b.wHouseRent == null) return -1;
                                        return b.wHouseRent!
                                            .compareTo(a.wHouseRent!);
                                      });
                                    } else if (sortingProvider
                                            .selectedSortOption ==
                                        'AreaMinToMax') {
                                      warehouses.sort((a, b) {
                                        if (a.warehouseCarpetArea == null &&
                                            b.warehouseCarpetArea == null) {
                                          return 0;
                                        }
                                        if (a.warehouseCarpetArea == null)
                                          return 1;
                                        if (b.warehouseCarpetArea == null) {
                                          return -1;
                                        }
                                        return a.warehouseCarpetArea!
                                            .compareTo(b.warehouseCarpetArea!);
                                      });
                                    } else if (sortingProvider
                                            .selectedSortOption ==
                                        'AreaMaxToMin') {
                                      warehouses.sort((a, b) {
                                        if (a.warehouseCarpetArea == null &&
                                            b.warehouseCarpetArea == null) {
                                          return 0;
                                        }
                                        if (a.warehouseCarpetArea == null)
                                          return 1;
                                        if (b.warehouseCarpetArea == null) {
                                          return -1;
                                        }
                                        return b.warehouseCarpetArea!
                                            .compareTo(a.warehouseCarpetArea!);
                                      });
                                    }
                                    return GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.8,
                                      ),
                                      itemCount: warehouses.length,
                                      itemBuilder: (context, index) {
                                        final warehouse = warehouses[index];
                                        return InkWell(
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            height: screenHeight * 0.25,
                                            width: screenWidth * 0.45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withValues(alpha: 0.8),
                                                  spreadRadius: 0.5,
                                                  blurRadius: 0.8,
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            "https://xpacesphere.com${warehouse.image}",
                                                        width: double.infinity,
                                                        height:
                                                            screenHeight * 0.15,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Container(
                                                            color: Colors
                                                                .grey[300],
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                screenHeight *
                                                                    0.15,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              ImageAssets
                                                                  .defaultImage,
                                                              width: double
                                                                  .infinity,
                                                              height:
                                                                  screenHeight *
                                                                      0.15,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(children: [
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        40),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                warehouse
                                                                    .wHouseRentPerSQFT
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              ),
                                                            ),
                                                          ),
                                                          const Text(
                                                            "  per sq.ft",
                                                            style: TextStyle(
                                                                fontSize: 5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ]),
                                                        Row(children: [
                                                          const Text(
                                                            "Type: ",
                                                            style: TextStyle(
                                                                fontSize: 7,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        40),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                warehouse
                                                                    .wHouseType,
                                                                style: const TextStyle(
                                                                    fontSize: 7,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .black87),
                                                                textAlign: TextAlign
                                                                    .start, // Align text as needed
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(children: [
                                                          const SizedBox(
                                                              width: 5),
                                                          Image.asset(
                                                              "assets/images/Scaleup.png",
                                                              height: 20,
                                                              width: 20),
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        40),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                warehouse
                                                                    .warehouseCarpetArea
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              ),
                                                            ),
                                                          ),
                                                          const Text(
                                                            " per sq.ft",
                                                            style: TextStyle(
                                                                fontSize: 5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ]),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(children: [
                                                          const Icon(
                                                            Icons.location_on,
                                                            size: 12,
                                                            color: Colors.red,
                                                          ),
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        80),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                "${warehouse.distance.toStringAsFixed(3)}km away",
                                                                style: const TextStyle(
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .grey),
                                                                textAlign: TextAlign
                                                                    .start, // Align text as needed
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                        Row(children: [
                                                          Image.asset(
                                                            "assets/images/people.png",
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 3),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 2),
                                                            ),
                                                            child: const Center(
                                                              child: Text(
                                                                "P",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        13),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                        const SizedBox(
                                                          width: 5,
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7)),
                                                      child: InkWell(
                                                        onTap: () {
                                                          downloadImages(
                                                              warehouse
                                                                  .filePath);
                                                        },
                                                        child: const Icon(
                                                            Icons
                                                                .file_download_outlined,
                                                            color: AppTheme
                                                                .primary),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WareHouseDetails(
                                                            warehouses:
                                                                warehouse,
                                                            phone: phone!)));
                                          },
                                        );
                                      },
                                    );
                                  });
                                }
                              },
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for each sorting option
  Widget _buildSortOption(
    BuildContext context,
    SortingProvider sortingProvider, {
    required String label,
    required String optionValue,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenHeight * 0.009),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: sortingProvider.selectedSortOption == optionValue
                ? const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)
                : const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Checkbox(
            checkColor: Colors.white,
            activeColor: Colors.green,
            value: sortingProvider.selectedSortOption == optionValue,
            onChanged: (bool? value) {
              if (value == true) {
                sortingProvider.selectedSortOption = optionValue;
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _userShortListedInterestedPage(
      double screenWidth, double screenHeight) {
    return const UserShortListedInterested();
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) {
    return const UserProfileScreen();
  }

  void showAdvancedFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const AdvancedFiltersBottomSheet();
      },
    );
  }

  Future<void> downloadImages(String filePath) async {
    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Storage permission is required to save images.")),
      );
      return;
    }
    final newFile = filePath;
    const baseUrl = "http://3.110.172.156:8083";
    imageList =
        newFile.split(',').map((path) => "$baseUrl${path.trim()}").toList();
    if (kDebugMode) {
      print("DEGREE$imageList");
    }

    for (String url in imageList) {
      await _downloadAndSaveImageToGallery(url);
    }
    Fluttertoast.showToast(
        msg: "All images saved to Gallery!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  /// Request permission for accessing media
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted)
        return true;
      if (await Permission.photos.request().isGranted) return true;
    }
    return false;
  }

  /// Save image directly in the Gallery (Public Pictures folder)
  Future<void> _downloadAndSaveImageToGallery(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Directory directory = Directory("/storage/emulated/0/Pictures/Lisofy");
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        String fileName = Uri.parse(url).pathSegments.last.split('?').first;
        String filePath = "${directory.path}$fileName";
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print("Saved to Gallery: $filePath");
        }
      } else {
        if (kDebugMode) {
          print("Failed to download image: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving image: $e");
      }
    }
  }

  void _openSearchLocationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationUser(
          initialLatitude: searchedLatitude,
          initialLongitude: searchedLongitude,
          initialDistance: searchedDistance,
          initialLoc: searchedLoc,
        ),
      ),
    );

    if (result != null) {
      double latitude = result['latitude'];
      double longitude = result['longitude'];
      int distance = result['distance'];
      String place = result['loc'];

      if (kDebugMode) {
        print("Received Data:");
        print("Latitude: $latitude");
        print("Longitude: $longitude");
        print("Distance: $distance ");
        print("Place: $place ");
      }

      setState(() {
        searchedLatitude = latitude;
        searchedLongitude = longitude;
        searchedDistance = distance;
        searchedLoc = place;
        isLoading = true;
        futureWarehouses =
            fetchWarehouses(latitude, longitude, distance, [], [], "");
      });
    }
    if (result == null) {
      setState(() {
        searchedLoc = "";
        searchedDistance = 0;
        searchedLatitude = 0;
        searchedLongitude = 0;
      });
      futureWarehouses =
          fetchWarehouses(widget.latitude, widget.longitude, 20, [], [], "");
    }
  }
}

class AdvancedFiltersBottomSheet extends StatefulWidget {
  const AdvancedFiltersBottomSheet({super.key});

  @override
  AdvancedFiltersBottomSheetState createState() =>
      AdvancedFiltersBottomSheetState();
}

class AdvancedFiltersBottomSheetState
    extends State<AdvancedFiltersBottomSheet> {
  String? selectedFilter;
  bool isClearFilters = true;
  Map<String, List<String>> filterOptions = {
    'Construction Types': [
      'PEB',
      'Cold Storage',
      'RCC',
      'Shed',
      'Factory',
      'Others'
    ],
    'Warehouse Types': [
      'PEB',
      'Cold Storage',
      'RCC',
      'SHED',
      'Dark Store',
      'Open Space',
      'Industrial SHED',
      'BTS',
      'Multi Storey Building',
      'Parking Land'
    ],
    'Rent Range': [],
  };

  Map<String, Map<String, bool>> selectedOptions = {
    'Construction Types': {},
    'Warehouse Types': {},
    'Rent Range': {},
  };
  double minRent = 0;
  double maxRent = 10000;
  RangeValues rentRange = const RangeValues(0, 10000);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight / 1.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: screenHeight * 0.06,
            margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    S.of(context).advanced_filters,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.clear,
                      color: Colors.white, size: screenHeight * 0.03),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Filter categories
                Container(
                  width: screenWidth / 2.5,
                  color: Colors.grey.shade100,
                  child: ListView(
                    children: filterOptions.keys.map((filter) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: selectedFilter == filter
                                ? AppTheme.primary
                                : Colors.white,
                            border: Border.all(color: AppTheme.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedFilter == filter
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Filter Options
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: selectedFilter == 'Rent Range'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${S.of(context).select_rent_range} (₹)",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              RangeSlider(
                                min: minRent,
                                max: maxRent,
                                values: rentRange,
                                onChanged: (RangeValues newRange) {
                                  setState(() {
                                    rentRange = newRange;
                                  });
                                },
                                divisions: 10,
                                labels: RangeLabels(
                                  '${rentRange.start.round()}',
                                  '${rentRange.end.round()}',
                                ),
                              ),
                              Text(
                                  "₹${rentRange.start.round()} - ₹${rentRange.end.round()}")
                            ],
                          )
                        : selectedFilter != null
                            ? ListView(
                                children: filterOptions[selectedFilter!]!
                                    .map((option) {
                                  return ListTile(
                                    leading: Checkbox(
                                      activeColor: Colors.green,
                                      value: selectedOptions[selectedFilter]
                                              ?[option] ??
                                          false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedOptions[selectedFilter]![
                                              option] = value!;
                                        });
                                      },
                                    ),
                                    title: Text(option,
                                        style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                              )
                            : Center(
                                child: Text(S.of(context).select_filter,
                                    style: const TextStyle(fontSize: 14))),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isClearFilters = true;
                      selectedOptions = {
                        'Construction Types': {},
                        'Warehouse Types': {},
                        'Rent Range': {},
                      };
                      rentRange = const RangeValues(0, 10000);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300),
                  child: Text(S.of(context).clear_all,
                      style: const TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isClearFilters = false;
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                  child: Text(S.of(context).apply_filters,
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: child,
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double startX = 0;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw dotted border
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.height) {
      canvas.drawLine(
        Offset(size.width, startX),
        Offset(size.width, startX + dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.width) {
      canvas.drawLine(
        Offset(size.width - startX, size.height),
        Offset(size.width - startX - dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.height) {
      canvas.drawLine(
        Offset(0, size.height - startX),
        Offset(0, size.height - startX - dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class UserHomePage extends StatefulWidget {
//   final double latitude;
//   final double longitude;
//
//   const UserHomePage({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   @override
//   State<UserHomePage> createState() => _WarehousesHomePageState();
// }
//
// class _WarehousesHomePageState extends State<UserHomePage> {
//   List<dynamic> warehouses = [];
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWarehouses();
//   }
//
//   Future<void> fetchWarehouses() async {
//     try {
//       final queryParameters = {
//         "latitude": widget.latitude.toString(),
//         "longitude": widget.longitude.toString(),
//         "distance": "20"
//       };
//
//       final url = Uri.http('15.206.189.22:8080', '/api/v2/datawarehouses', queryParameters);
//
//       print("📍 Request URL: $url");
//
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("✅ Warehouses: $data");
//
//         setState(() {
//           warehouses = data["data"] ?? [];
//           loading = false;
//         });
//       } else {
//         throw Exception(
//             "Failed to fetch warehouses. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("❌ Error fetching warehouses: $e");
//       setState(() {
//         loading = false;
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Warehouses")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: warehouses.length,
//         itemBuilder: (context, index) {
//           final warehouse = warehouses[index];
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               leading: warehouse["imageUrl"] != null
//                   ? Image.network(warehouse["imageUrl"], width: 60)
//                   : const Icon(Icons.warehouse),
//               title: Text(warehouse["name"] ?? "No name"),
//               subtitle: Text(warehouse["address"] ?? "No address"),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
