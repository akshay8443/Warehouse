import 'package:Lisofy/resources/app_theme.dart';
import 'dart:async';
import 'dart:math';
import 'package:Lisofy/Warehouse/User/UserProvider/interest_provider.dart';
import 'package:Lisofy/Warehouse/User/customPainter/key_value_table.dart';
import 'package:Lisofy/Warehouse/User/express_interest_screen.dart';
import 'package:Lisofy/Warehouse/User/models/warehouse_model.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class WareHouseDetails extends StatefulWidget {
  final WarehouseModel warehouses;
  final String phone;
  const WareHouseDetails(
      {super.key, required this.warehouses, required this.phone});
  @override
  State<WareHouseDetails> createState() => _WareHouseDetailsState();
}

class _WareHouseDetailsState extends State<WareHouseDetails> {
  late PageController _pageControllerSlider;
  late Timer _timer;
  int _currentIndex = 0;
  bool _isExpanded = false;
  final List<String> _uploadedImages = [];
  final List<String> _defaultImages = [
    'assets/images/slider3.jpg',
    'assets/images/slider2.jpg',
  ];
  late String _address = "Fetching address...";
  String? selectedLocation;
  bool isLoading = false;
  late LatLng finalAddress = const LatLng(0.0, 0.0);
  @override
  void initState() {
    super.initState();

    /// Fetch shortlist status on page load
    Provider.of<CartProvider>(context, listen: false)
        .fetchShortlistStatus(widget.warehouses.id, widget.phone);

    //Address
    _getAddressFromLatLng(widget.warehouses.latitude.toString(),
        widget.warehouses.longitude.toString());

    //warehouseImage
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

  Future<void> _getAddressFromLatLng(
      String latitudeStr, String longitudeStr) async {
    try {
      double latitude = double.parse(latitudeStr.trim());
      double longitude = double.parse(longitudeStr.trim());
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placeMarks.isNotEmpty) {
        Placemark place = placeMarks[0];
        setState(() {
          _address =
              ' ${place.locality}, ${place.administrativeArea}, ${place.country}';
          if (kDebugMode) {
            print(_address);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address: $e");
      }
    }
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
    final cartProvider = Provider.of<CartProvider>(context);
    final isShortlisted = cartProvider.isShortlisted(widget.warehouses.id);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
      // if (widget.warehouses.flexingModel)
      //   {
      //     'icon': ImageAssets.flexiModel,
      //     'label': 'Flexi Model',
      //   },
    ];
    final Map<String, String> sampleData = {
      "Construction Age(in Month)":
          widget.warehouses.constructionAge.toString(),
      "Ground Floor": widget.warehouses.groundFloor,
      "Lock-in Period": widget.warehouses.wHouseLockinPeriod.toString(),
      "Token Advance": widget.warehouses.wHouseTokenAdvance!,
      "Maintenance Cost": widget.warehouses.wHouseMaintenance!,
      "Inner Length": widget.warehouses.length,
      "Inner Width": widget.warehouses.width,
      "Side Height": widget.warehouses.sideHeight,
      "Centre Height": widget.warehouses.centerHeight,
      "No. of Docks": widget.warehouses.numberOfDocks,
      "Docks Height(feet)": widget.warehouses.docksOfHeight,
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
                      height: screenHeight * 0.1,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.025,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
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
                                        widget.warehouses.id,
                                        widget.phone,
                                        context);
                                  },
                                  child: Container(
                                      height: screenHeight * 0.04,
                                      width: screenWidth * 0.1,
                                      margin: EdgeInsets.only(
                                          // top: screenHeight * 0.05,
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
                                  onTap: () {
                                    const String baseUrl =
                                        'https://xpacesphere.com';
                                    ShareWarehouseHelper.shareWarehouse(
                                      warehouseName:
                                          widget.warehouses.wHouseName,
                                      warehouseLocation:
                                          finalAddress.toString(),
                                      warehouseDetailsUrl:
                                          "https://xpacesphere.com/",
                                      warehousePhotoUrl:
                                          "$baseUrl${_uploadedImages[0]}",
                                      context: context,
                                    );
                                  },
                                  child: Container(
                                      height: screenHeight * 0.04,
                                      width: screenWidth * 0.1,
                                      margin: EdgeInsets.only(
                                          // top: screenHeight * 0.05,
                                          right: screenWidth * 0.06),
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
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                        const SizedBox(height: 10),
                                        SingleChildScrollView(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                                _uploadedImages.length,
                                                (index) {
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
                                                    color:
                                                        _currentIndex == index
                                                            ? AppTheme.primary
                                                            : Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
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
                                              "₹ ${widget.warehouses.wHouseRentPerSQFT}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          " Rent sq.ft",
                                          style: TextStyle(
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
                                  const SizedBox(
                                    height: 10,
                                  ),
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
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
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    _address,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        screenWidth * 0.5),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    "${widget.warehouses.distance.toStringAsFixed(3)} km away from your current Location",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                    textAlign: TextAlign.start,
                                                  ),
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
                                              _openMap(
                                                  widget.warehouses.latitude,
                                                  widget.warehouses.longitude);
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
                                  // Container(
                                  //   margin:
                                  //       const EdgeInsets.symmetric(horizontal: 15),
                                  //   height: screenHeight * 0.12,
                                  //   width: double.infinity,
                                  //   decoration: BoxDecoration(
                                  //       border: Border.all(
                                  //           color: Colors.grey, width: 1.5),
                                  //       borderRadius: BorderRadius.circular(5)),
                                  // ),
                                  // const SizedBox(
                                  //   height: 7,
                                  // ),
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
                                  const SizedBox(
                                    height: 15,
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
                                      SizedBox(height: screenHeight * 0.02),
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
                                          spacing: screenWidth * 0.05,
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: screenHeight * 0.045,
                                        width: screenWidth * 0.4,
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
                                          height: screenHeight * 0.045,
                                          width: screenWidth * 0.4,
                                          decoration: BoxDecoration(
                                              color: AppTheme.primary,
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
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                S.of(context).express_interest,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpressInterestScreen(
                                                          id: widget
                                                              .warehouses.id)));
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
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final random = Random();

    // Generate random offsets (±1 to 2 km)
    double latOffset =
        (random.nextDouble() * 0.018) - 0.009; // ±1 to 2 km in latitude
    double lngOffset =
        (random.nextDouble() * 0.018) - 0.009; // ±1 to 2 km in longitude
    // Adjust the coordinates
    double newLat = lat + latOffset;
    double newLng = lng + lngOffset;
    final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$newLat,$newLng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ShareWarehouseHelper {
  /// Check for location permissions and fetch current location
  static Future<String> getLocationUrl() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, cannot access location.");
    }
    Position position = await Geolocator.getCurrentPosition();
    return "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
  }

  /// Share Warehouse Details
  static Future<void> shareWarehouse({
    required String warehouseName,
    required String warehouseLocation,
    required String warehouseDetailsUrl,
    required String warehousePhotoUrl,
    required BuildContext context,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      String locationUrl = await getLocationUrl();

      String message = '''
📦 Check out this Warehouse!
🏢 Name: $warehouseName
📍 Location: $warehouseLocation
🌐 Warehouse Details: $warehouseDetailsUrl

📸 Photo: $warehousePhotoUrl
🗺️ Location URL: $locationUrl
    ''';
      Share.share(message);
    } catch (e) {
      if (kDebugMode) {
        print("Error: ${e.toString()}");
      }
      messenger.showSnackBar(
        const SnackBar(content: Text("Something went wrong...")),
      );
    }
  }
}

class WarehouseFeaturesRow extends StatelessWidget {
  final List<Map<String, dynamic>> features;

  const WarehouseFeaturesRow({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features
          .map((feature) => Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      color: AppTheme.primarySoft,
                    ),
                    child: Image.asset(feature["icon"], width: 30, height: 30),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    feature["value"],
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ))
          .toList(),
    );
  }
}
