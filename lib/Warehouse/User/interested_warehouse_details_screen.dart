import 'package:Lisofy/resources/app_theme.dart';
import 'dart:async';
import 'package:Lisofy/Warehouse/User/UserProvider/interest_provider.dart';
import 'package:Lisofy/Warehouse/User/customPainter/key_value_table.dart';
import 'package:Lisofy/Warehouse/User/warehouse_details.dart';
import 'package:Lisofy/distance_calculator.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class InterestedWarehouseDetailsScreen extends StatefulWidget {
  final dynamic warehouses;
  const InterestedWarehouseDetailsScreen({super.key, required this.warehouses});
  @override
  State<InterestedWarehouseDetailsScreen> createState() =>
      _InterestedWarehouseDetailsScreenState();
}

class _InterestedWarehouseDetailsScreenState
    extends State<InterestedWarehouseDetailsScreen> {
  late PageController _pageControllerSlider;
  DistanceCalculator distanceCalculator = DistanceCalculator();
  late Timer _timer;
  int _currentIndex = 0;
  bool isLoading = false;
  bool _isExpanded = false;
  late String phone;

  final List<String> _uploadedImages = [];
  final List<String> _defaultImages = [
    'assets/images/slider3.jpg',
    'assets/images/slider2.jpg',
  ];
  @override
  void initState() {
    super.initState();
    getSharedData();
    String filePath = widget.warehouses.filePath;
    processMediaFilePath(filePath);
    _pageControllerSlider = PageController(initialPage: _currentIndex);
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!mounted || !_pageControllerSlider.hasClients) {
        return;
      }
      if (_uploadedImages.isEmpty) {
        return;
      }
      if (_currentIndex < _uploadedImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageControllerSlider.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void getSharedData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    phone = pref.getString("phone")!;
  }

  void processMediaFilePath(String filePath) {
    List<String> filePaths = filePath.split(',');
    List<String> photos = [];
    for (var path in filePaths) {
      if (path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png')) {
        photos.add(path);
      }
    }
    setState(() {
      _uploadedImages.addAll(photos);
    });
    if (_uploadedImages.isEmpty) {
      setState(() {
        _uploadedImages.addAll(_defaultImages);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageControllerSlider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cartProvider = Provider.of<CartProvider>(context);
    final isShortlisted = cartProvider.isShortlisted(widget.warehouses.id);
    final List<Map<String, dynamic>> gridItems = [
      if (widget.warehouses.officeSpace)
        {
          'icon': ImageAssets.officeSpace,
          'label': 'Office Space',
        },
      if (widget.warehouses.dockLevelers)
        {
          'icon': ImageAssets.dockleveler,
          'label': 'Dock Levelers',
        },
      if (widget.warehouses.fireComplaints)
        {
          'icon': ImageAssets.fireNoc,
          'label': 'Fire NOC',
        },
      if (widget.warehouses.powerBackup)
        {
          'icon': ImageAssets.powerBackup,
          'label': 'Power Backup',
        },
      if (widget.warehouses.flexingModel)
        {
          'icon': ImageAssets.flexiModel,
          'label': 'Flexi Model',
        },
    ];
    DistanceCalculator distanceCalculator = DistanceCalculator();
    final Map<String, String> sampleData = {
      "Previous Tenants": widget.warehouses.electricity,
      "Construction Age(in Month)":
          widget.warehouses.constructionAge.toString(),
      "Name": widget.warehouses.wHouseName,
      "Ground Floor": widget.warehouses.groundFloor,
      "Lock-in Period": widget.warehouses.wHouseLockInPeriod.toString(),
      "Token Advance": widget.warehouses.wHouseTokenAdvance!,
      "Maintenance Cost": widget.warehouses.wHouseMaintenance!,
      "Inner Length": widget.warehouses.length.toString(),
      "Inner Width": widget.warehouses.width.toString(),
      "Side Height": widget.warehouses.sideHeight.toString(),
      "Centre Height": widget.warehouses.centerHeight.toString(),
      "No. of Docks": widget.warehouses.numberOfDocks.toString(),
      "Docks Height(feet)": widget.warehouses.docksOfHeight.toString(),
    };
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
                          top: screenHeight * 0.025,
                          left: screenWidth * 0.025,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.02,
                                  height: screenHeight * 0.04,
                                ),
                                InkWell(
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    cartProvider.toggleWarehouse(
                                        widget.warehouses.id, phone, context);
                                  },
                                  child: Container(
                                      height: screenHeight * 0.04,
                                      width: screenWidth * 0.1,
                                      margin: EdgeInsets.only(
                                          top: screenHeight * 0.05,
                                          right: screenWidth * 0.04),
                                      child: isShortlisted
                                          ? const Icon(
                                              Icons.favorite_outlined,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
                                              color: Colors.white,
                                            )),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                      height: screenHeight * 0.04,
                                      width: screenWidth * 0.1,
                                      margin: EdgeInsets.only(
                                          top: screenHeight * 0.05,
                                          right: screenWidth * 0.04),
                                      decoration: const BoxDecoration(
                                          color: AppTheme.primary),
                                      child: Image.asset(
                                          "assets/images/Shareicon.png")),
                                ),
                              ],
                            )
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
                          child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.28,
                                    width: screenWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: screenHeight * 0.25,
                                          width: screenWidth,
                                          child: PageView.builder(
                                            controller: _pageControllerSlider,
                                            itemCount: _uploadedImages.length,
                                            onPageChanged: (int index) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              const String baseUrl =
                                                  'http://3.110.172.156:8083';
                                              return Container(
                                                margin: const EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenWidth * 0.06),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenWidth * 0.06),
                                                  child: CachedNetworkImage(
                                                    imageUrl: Uri.encodeFull(
                                                        '$baseUrl${_uploadedImages[index]}'),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: screenHeight * 0.5,
                                                    placeholder:
                                                        (context, url) =>
                                                            Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          Colors.grey.shade100,
                                                      child: Container(
                                                        width: double.infinity,
                                                        height:
                                                            screenHeight * 0.5,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      ImageAssets.defaultImage,
                                                      width: double.infinity,
                                                      height:
                                                          screenHeight * 0.5,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                              _uploadedImages.length, (index) {
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                width: _currentIndex == index
                                                    ? 20
                                                    : 20,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: _currentIndex == index
                                                      ? AppTheme.primary
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Container(
                                    height: screenHeight * 0.05,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppTheme.primary),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 40),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "₹ ${widget.warehouses.wHouseRentPerSQFT} ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          S.of(context).rent_per_sqft,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 10,
                                              color: Colors.grey),
                                        ),
                                        const Spacer(),
                                        Container(
                                          height: screenHeight * 0.05,
                                          width: screenWidth * 0.13,
                                          decoration: const BoxDecoration(
                                              color: AppTheme.primary),
                                          child: const Icon(
                                            Icons.help_center_outlined,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: screenHeight * 0.12,
                                        width: screenWidth * 0.37,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                                color: Colors.grey, width: 1.5),
                                            shape: BoxShape.rectangle),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, top: 8),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 40),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    widget.warehouses
                                                        .warehouseCarpetArea
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                S.of(context).available_area,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, top: 8),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 40),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    widget.warehouses
                                                        .securityDeposit
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                "${S.of(context).security_deposit}(Month)",
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: screenHeight * 0.12,
                                        width: screenWidth * 0.37,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                                color: Colors.grey, width: 1.5),
                                            shape: BoxShape.rectangle),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, top: 8),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 50),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    widget
                                                        .warehouses.wHouseType,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                S.of(context).warehouse_type,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, top: 8),
                                              child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 40),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      widget.warehouses
                                                          .wHouseConstructionType,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                S.of(context).flooring_type,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        S.of(context).address,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    height: screenHeight * 0.07,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 1.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Column(
                                            children: [
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 130),
                                                child: FutureBuilder<double>(
                                                  future: distanceCalculator
                                                      .getDistanceFromCurrentToWarehouse(
                                                          widget.warehouses
                                                              .wHouseAddress),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                        "Calculating distance...",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.start,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Text(
                                                        "Error fetching distance",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.start,
                                                      );
                                                    } else {
                                                      double distanceInKm =
                                                          snapshot.data! /
                                                              1000; // Convert meters to KM
                                                      return FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          "${distanceInKm.toStringAsFixed(2)} km away from your current Location",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 16),
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        screenWidth * 0.5),
                                                child: FutureBuilder<String>(
                                                  future: distanceCalculator
                                                      .getAddressFromLatLng(
                                                          widget.warehouses
                                                              .wHouseAddress),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                        "Fetching address...",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.start,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Text(
                                                        "Error fetching address",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.start,
                                                      );
                                                    } else {
                                                      return FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          "${snapshot.data}",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.grey,
                                                            fontSize: 16,
                                                          ),
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 5.0, top: 3, bottom: 3),
                                          child: InkWell(
                                            onTap: () {
                                              _openMapFromAddress(widget
                                                  .warehouses.wHouseAddress);
                                            },
                                            child: ClipOval(
                                              child: Image.asset(
                                                ImageAssets.map,
                                                height: screenHeight * 0.06,
                                                width: screenWidth * 0.13,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  KeyValueTable(data: sampleData),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).amenities,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isExpanded = !_isExpanded;
                                          });
                                        },
                                        child: Text(
                                          _isExpanded
                                              ? S.of(context).view_less
                                              : S.of(context).view_more,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      WarehouseFeaturesRow(
                                        features: [
                                          {
                                            "icon": ImageAssets.electricity,
                                            "value":
                                                "${widget.warehouses.electricity} KWA"
                                          },
                                          {
                                            "icon": ImageAssets.toilets,
                                            "value":
                                                "Toilets | ${widget.warehouses.numberOfToilets}"
                                          },
                                          {
                                            "icon": ImageAssets.truckSlot,
                                            "value":
                                                "Truck Slot | ${widget.warehouses.truckParkingSlot}"
                                          },
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.04),
                                      WarehouseFeaturesRow(
                                        features: [
                                          {
                                            "icon": ImageAssets.fansNumber,
                                            "value":
                                                "Fans | ${widget.warehouses.numberOfFans}"
                                          },
                                          {
                                            "icon": ImageAssets.lightbulb,
                                            "value":
                                                "Lights | ${widget.warehouses.numberOfLights}"
                                          },
                                          {
                                            "icon": ImageAssets.bikeSlot,
                                            "value":
                                                "Bike Slot | ${widget.warehouses.bikeParkingSlot}"
                                          },
                                        ],
                                      ),
                                    ],
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: screenHeight * 0.04),
                                        Wrap(
                                          spacing: screenWidth * 0.1,
                                          runSpacing: screenWidth * 0.10,
                                          children: gridItems.map((item) {
                                            return SizedBox(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3.5 -
                                                  30,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color:
                                                              AppTheme.primary,
                                                          width: 2),
                                                      color: const Color(
                                                          0xffCCDCF9),
                                                    ),
                                                    child: Image.asset(
                                                        item['icon']),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    item['label'],
                                                    style: const TextStyle(
                                                      color: AppTheme.primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                      ],
                                    ),
                                    crossFadeState: _isExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: screenHeight * 0.0415,
                                        width: screenWidth * 0.34,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppTheme.primary),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              color: AppTheme.primary,
                                              size: 16,
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              S.of(context).schedule_a_visit,
                                              style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontSize: 10),
                                            )
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        child: Container(
                                          height: screenHeight * 0.0415,
                                          width: screenWidth * 0.34,
                                          decoration: BoxDecoration(
                                              color: AppTheme.primarySoft,
                                              border: Border.all(
                                                  color: AppTheme.primarySoft),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Already Interested",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              ),
                                              Spacer(),
                                              Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>ExpressInterestScreen(id:widget.warehouses.id)));
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
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

  void _openMapFromAddress(String wHouseAddress) {
    DistanceCalculator distanceCalculator = DistanceCalculator();
    try {
      LatLng warehouseLatLng = distanceCalculator.parseLatLng(wHouseAddress);
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${warehouseLatLng.latitude},${warehouseLatLng.longitude}";
      launchUrl(Uri.parse(googleMapsUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid location format: $e")),
      );
    }
  }
}
