import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Warehouse/Partner/help_page.dart';
import 'package:Lisofy/Warehouse/Partner/notification_screen.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/warehouse_provider.dart';
import 'package:Lisofy/Warehouse/Partner/add_warehouse.dart';
import 'package:Lisofy/Warehouse/Partner/models/warehouses_model.dart';
import 'package:Lisofy/Warehouse/Partner/warehouse_update.dart';
import 'package:Lisofy/Warehouse/User/user_profile_screen.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/new_home_page.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({super.key, this.name = 'Guest'});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<WarehouseResponse> futureWarehouseResponse;
  final TextEditingController _searchController = TextEditingController();
  late String userName = "";
  final String warehouseName = 'WarehouseX';
  final String benefitsText =
      'WarehouseX offers the best solutions for storing your goods securely and efficiently.';
  final String appInfoText = 'Download WarehouseX app for amazing offers!';
  bool light = true;
  int _selectedIndex = 0;
  late double latitude = 0;
  late double longitude = 0;
  final PageController _pageController = PageController();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  String? qrData;
  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    userName = pref.getString("name") ?? "Default Name";
    if (kDebugMode) {
      print("Name$userName");
    }
    latitude = pref.getDouble("latitude") ?? 0.0;
    longitude = pref.getDouble("longitude") ?? 0.0;
  }

  @override
  void initState() {
    if (kDebugMode) {
      print("Init State executed");
    }
    super.initState();
    getData();
    futureWarehouseResponse = fetchWarehouseData();
  }

  Future<String> _getAddressFromLatLng(String latLong) async {
    try {
      RegExp regExp = RegExp(r'LatLng\(([^,]+), ([^,]+)\)');
      Match? match = regExp.firstMatch(latLong);
      if (match != null && match.groupCount == 2) {
        double latitude = double.parse(match.group(1)!.trim());
        double longitude = double.parse(match.group(2)!.trim());
        List<Placemark> placeMarks =
            await placemarkFromCoordinates(latitude, longitude);
        if (placeMarks.isNotEmpty) {
          Placemark place = placeMarks[0];
          return '${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        }
      }
      return 'No address found';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _limitDigits(int count) {
    if (count >= 1000) {
      return '999+';
    } else {
      return count.toString();
    }
  }

  // Future<WarehouseResponse> fetchWarehouseData() async {
  //   if (kDebugMode) {
  //     print("fetch data executed");
  //   }
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String phone = prefs.getString("phone")!;
  //   if (phone.startsWith("+91")) {
  //     phone = phone.replaceFirst("+91", "");
  //   }
  //
  //   if (kDebugMode) {
  //     print("Phone>>$phone");
  //   }
  //
  //   if (phone.isEmpty) {
  //     throw Exception('Phone number is not stored in SharedPreferences');
  //   }
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           'http://15.206.189.22:8080/api/v2/datawarehouses?mobile=$phone'),
  //     );
  //     if (kDebugMode) {
  //       print("Api response code${response.statusCode}");
  //     }
  //     if (kDebugMode) {
  //       print("Api response body${response.body}");
  //     }
  //
  //     if (response.statusCode == 200) {
  //       return WarehouseResponse.fromJson(json.decode(response.body));
  //     } else {
  //       throw Exception(
  //           'Failed to load warehouse data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to fetch warehouse data: $e');
  //   }
  // }

  Future<WarehouseResponse> fetchWarehouseData() async {
    if (kDebugMode) {
      print("fetch data executed");
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString("phone");

    if (phone == null || phone.isEmpty) {
      throw Exception('Phone number is not stored in SharedPreferences');
    }

    if (phone.startsWith("+91")) {
      phone = phone.replaceFirst("+91", "");
    }

    if (kDebugMode) {
      print("Phone>>$phone");
    }

    try {
      final response = await http.get(
        Uri.parse(
            'http://3.110.172.156:8083/api/v2/datawarehouses?mobile=$phone'),
      );

      if (kDebugMode) {
        print("Api response code ${response.statusCode}");
        print("Api response body ${response.body}");
      }

      if (response.statusCode == 200) {
        return WarehouseResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load warehouse data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch warehouse data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareAppInfo() async {
    try {
      final ByteData logoData =
          await rootBundle.load('assets/images/house.png');
      final ByteData warehouseImageData =
          await rootBundle.load('assets/images/house1.png');
      final tempDir = await getTemporaryDirectory();
      final File logoFile = File('${tempDir.path}/house.png');
      final File warehouseImageFile = File('${tempDir.path}/house1.png');
      await logoFile.writeAsBytes(logoData.buffer.asUint8List());
      await warehouseImageFile
          .writeAsBytes(warehouseImageData.buffer.asUint8List());
      await Share.shareXFiles(
        [
          XFile(logoFile.path),
          XFile(warehouseImageFile.path),
        ],
        text:
            'WarehouseX\nThe best warehouse business in town!\nContact us for more details.',
        subject: 'WarehouseX Business Info',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing app info: $e');
      }
    }
  }

  void _showQrDialog(String data) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          child: AnimatedQrDialog(data: data),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
                _buildNotificationPage(screenWidth, screenHeight),
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
                                icon: Icon(
                                  Icons.notifications,
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
                              ? const AssetImage(
                                  "assets/images/MaleUsercolored.png")
                              : const AssetImage('assets/images/MaleUser.png'),
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
    );
  }

  Widget _buildHomePage(double screenWidth, double screenHeight) {
    final warehouseProvider = Provider.of<WarehouseProvider>(context);
    return Container(
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
                  top: screenHeight * 0.0,
                  left: screenWidth * 0.015,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: screenWidth * 0.03),
                              child: Text(
                                "Hello",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: screenWidth * 0.030),
                              child: Text(
                                (userName.isNotEmpty)
                                    ? (userName.length > 7
                                        ? '${userName.substring(0, 7)}...'
                                        : userName)
                                    : 'Guest',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: screenWidth * 0.55,
                          height: screenHeight * 0.1,
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 35,
                              child: TextFormField(
                                enabled: false,
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: S.of(context).search_by_location,
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
                                  suffixIcon: const Icon(Icons.search,
                                      color: AppTheme.primary, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          child: Container(
                            height: 32,
                            width: 32,
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
                                Icons.question_mark,
                                color: AppTheme.primary,
                                size: 18,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HelpPage()));
                          },
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).manage_your_warehouse,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.zero,
                                height: screenHeight * 0.042,
                                width: screenWidth * 0.18,
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
                                      S.of(context).add_new,
                                      style: const TextStyle(
                                          fontSize: 6,
                                          fontWeight: FontWeight.normal,
                                          color: AppTheme.primary),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddWareHouse()));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Container(
                                height: screenHeight * 0.037,
                                width: screenWidth * 0.08,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddWareHouse()));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NewHomePage(
                                                  longitude: longitude,
                                                  latitude: latitude,
                                                )));
                                  },
                                  child: const Column(
                                    children: [
                                      ImageIcon(
                                        AssetImage(ImageAssets.back),
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Back",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w100),
                                      )
                                    ],
                                  )),
                              SizedBox(width: screenWidth * 0.04),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                child: RefreshIndicator(
                  onRefresh: fetchWarehouseData,
                  color: AppTheme.primary,
                  backgroundColor: Colors.white,
                  child: FutureBuilder<WarehouseResponse>(
                    future: futureWarehouseResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: SpinKitCircle(
                          color: AppTheme.primary,
                          size: 50.0,
                        ));
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Oops! Something went wrong.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'We encountered an issue while loading the data. Please try again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Retry logic here
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final warehouseList = snapshot.data!.data;
                        return warehouseList.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: SingleChildScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                          child: Image.asset(
                                              "assets/images/house.png",
                                              height: screenHeight * 0.2,
                                              width: screenWidth * 0.5)),
                                      Center(
                                        child: Text(
                                          S.of(context).start_adding_warehouse,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            S.of(context).add_warehouse_details,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          child: DottedBorder(
                                            child: Container(
                                              color: AppTheme.primary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    S.of(context).add_warehouse,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddWareHouse()),
                                          );
                                        },
                                      ),
                                      Center(
                                          child: Image.asset(
                                              "assets/images/man.png")),
                                      SizedBox(height: screenHeight * 0.013),
                                      Center(
                                        child: Text(
                                          S.of(context).we_are_happy_to_help,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.013),
                                      Center(
                                        child: Text(
                                          "${S.of(context).need_assistance} >>",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: warehouseList.length,
                                itemBuilder: (context, index) {
                                  final warehouse = warehouseList[index];
                                  if (kDebugMode) {
                                    print(
                                        "availability${warehouse.isAvailableForRent}");
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WarehouseUpdate(
                                                    warehouse: warehouse,
                                                  )));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.only(
                                                top: screenHeight * 0.01,
                                                left: 10),
                                            padding: const EdgeInsets.all(15),
                                            child: DottedBorder(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          warehouse.wHouseName
                                                                  .isNotEmpty
                                                              ? (warehouse.wHouseName
                                                                          .length >
                                                                      7
                                                                  ? '${warehouse.wHouseName.substring(0, 7)}...'
                                                                  : warehouse
                                                                      .wHouseName)
                                                              : 'N/A',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          child: Image.asset(
                                                              "assets/images/Share.png"),
                                                          onTap: () {
                                                            _shareAppInfo();
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        InkWell(
                                                          child: Image.asset(
                                                              "assets/images/QrCode.png"),
                                                          onTap: () {
                                                            String data =
                                                                'Warehouse Name: ${warehouse.wHouseName}\nLocation: ${warehouse.wHouseAddress}\nContact: ${warehouse.mobile}';
                                                            _showQrDialog(data);
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          warehouseProvider
                                                                          .warehouseStatus[
                                                                      warehouse
                                                                          .id
                                                                          .toString()] ??
                                                                  warehouse
                                                                      .isAvailable
                                                              ? ". Vacant"
                                                              : ". Rented",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: warehouseProvider
                                                                            .warehouseStatus[
                                                                        warehouse
                                                                            .id
                                                                            .toString()] ??
                                                                    warehouse
                                                                        .isAvailable
                                                                ? Colors.red
                                                                : Colors.green,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        FutureBuilder<String>(
                                                          future: _getAddressFromLatLng(
                                                              warehouse
                                                                  .wHouseAddress),
                                                          builder: (context,
                                                              snapshot) {
                                                            return SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              child: Text(
                                                                snapshot.connectionState ==
                                                                        ConnectionState
                                                                            .waiting
                                                                    ? "Getting address..."
                                                                    : snapshot
                                                                            .hasError
                                                                        ? "Error fetching address"
                                                                        : snapshot.hasData
                                                                            ? "| ${snapshot.data}"
                                                                            : "No address available",
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 10,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                            width: screenWidth *
                                                                0.05),
                                                        Text(
                                                          warehouse.warehouseCarpetArea
                                                                      .toString()
                                                                      .length >
                                                                  6
                                                              ? '${warehouse.warehouseCarpetArea.toString().substring(0, 6)}... sq.ft'
                                                              : '${warehouse.warehouseCarpetArea} sq.ft',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          warehouse.wHouseRentPerSQFT
                                                                      .toString()
                                                                      .length >
                                                                  6
                                                              ? '₹ ${warehouse.wHouseRentPerSQFT.toString().substring(0, 6)}...'
                                                              : '₹ ${warehouse.wHouseRentPerSQFT}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: screenWidth *
                                                                0.1)
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          "${S.of(context).carpet_area} Sq. ft.",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 10),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "  | ${S.of(context).rent_per_sqft} ",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 10),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          flex: 4,
                                                          child: Container(
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xffF0F4FD),
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xffF0F4FD)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "${S.of(context).view_request} | ${_limitDigits(0)}",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Flexible(
                                                          flex: 3,
                                                          child: Container(
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xffF0F4FD),
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xffF0F4FD)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "${S.of(context).bids} | ${_limitDigits(0)}",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Flexible(
                                                          flex: 4,
                                                          child: Container(
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xffF0F4FD),
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xffF0F4FD)),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "${S.of(context).contracts} | ${_limitDigits(0)}",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(S
                                                          .of(context)
                                                          .is_warehouse_available),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            S.of(context).no,
                                                            style: const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          // Switch button with Provider
                                                          Switch(
                                                            hoverColor:
                                                                Colors.white,
                                                            activeTrackColor:
                                                                Colors.green,
                                                            focusColor:
                                                                Colors.white,
                                                            activeColor:
                                                                Colors.white,
                                                            inactiveThumbColor:
                                                                Colors.grey,
                                                            value: warehouseProvider
                                                                        .warehouseStatus[
                                                                    warehouse.id
                                                                        .toString()] ??
                                                                warehouse
                                                                    .isAvailable,
                                                            onChanged:
                                                                (bool value) {
                                                              warehouseProvider
                                                                  .initializeStatus(
                                                                      warehouse
                                                                          .id
                                                                          .toString(),
                                                                      value);
                                                              warehouseProvider
                                                                  .updateWarehouseStatus(
                                                                      warehouse
                                                                          .id
                                                                          .toString(),
                                                                      value)
                                                                  .catchError(
                                                                      (error) {
                                                                warehouseProvider
                                                                    .initializeStatus(
                                                                        warehouse
                                                                            .id
                                                                            .toString(),
                                                                        !value);
                                                                if (!context
                                                                    .mounted)
                                                                  return;
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Failed to update warehouse status!')),
                                                                );
                                                              });
                                                            },
                                                          ),
                                                          Text(
                                                            S.of(context).yes,
                                                            style: const TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                      } else {
                        return const Center(child: Text('No Data Found'));
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPage(double screenWidth, double screenHeight) {
    return const NotificationScreen();
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) {
    return const UserProfileScreen();
  }

  Future<void> updateWarehouseStatus(String warehouseId, bool status) async {
    final url =
        Uri.parse('http://xpacesphere.com/api/Wherehousedt/UpdIsAvailable');

    try {
      // Send the HTTP POST request
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Id': warehouseId, 'isavailable': status}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Warehouse status updated successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to update warehouse status: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating warehouse status: $e');
      }
    }
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

class AnimatedQrDialog extends StatefulWidget {
  final String data;
  const AnimatedQrDialog({super.key, required this.data});
  @override
  AnimatedQrDialogState createState() => AnimatedQrDialogState();
}

class AnimatedQrDialogState extends State<AnimatedQrDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan this QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: widget.data,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white.withValues(alpha: 0),
              eyeStyle: const QrEyeStyle(color: Colors.white),
              dataModuleStyle: const QrDataModuleStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                  size: 40,
                )),
          ],
        ),
      ),
    );
  }
}
