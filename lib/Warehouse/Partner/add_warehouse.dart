import 'dart:convert';
import 'package:Lisofy/Warehouse/Partner/help_page.dart';
import 'package:Lisofy/Warehouse/Partner/map_screen.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/location_provider.dart';
import 'package:Lisofy/Warehouse/Partner/warehouse_image_screen.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddWareHouse extends StatefulWidget {
  const AddWareHouse({super.key});

  @override
  State<AddWareHouse> createState() => _AddWareHouseState();
}

class _AddWareHouseState extends State<AddWareHouse> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rentPerSqFt = TextEditingController();
  final TextEditingController _maintenanceCost = TextEditingController();
  final TextEditingController _tokenAdvance = TextEditingController();
  final TextEditingController _warehouseName = TextEditingController();
  final TextEditingController _totalArea = TextEditingController();
  final TextEditingController _carpetAreaController = TextEditingController();
  final int _maxLength = 29;
  bool _isCheckedBase = false;
  int _numberOfFloor = 0;
  int _constructionAgeNumber = 0;
  int _securityDepositNumber = 0;
  int _lockingNumber = 0;
  String displayText = 'Click here to Locate your Warehouse';
  String fullAddress = '';
  String? _selectedWarehouseType;
  String? _selectedConstructionType;
  String? selectedLocation;
  bool isLoading = false;
  late final LatLng finalAddress;
  String groundFloor = "";

  //NEW CODE............
  Future<void> saveWarehouseId(int warehouseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('warehouseId', warehouseId);
    debugPrint("Warehouse ID saved: $warehouseId");
  }

  Future<int?> getWarehouseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('warehouseId');
  }

//_++++++++++++++++++++++++++++++++++++++++++++
  final List<String> _constructionTypes = [
    'Shed',
    'Cold Storage',
    'RCC',
    'PEB',
    'Others',
  ];

  final List<String> warehouseTypes = [
    'Small Warehouse',
    'Warehouse',
    'Building',
    'Bonded',
    'Cold storage',
    'Dark Store',
    'Commercial Building',
    'Independent House',
    'Multi Storey Building',
    'Open Space',
    'RCC Structure',
    'shed',
    'Industrial Shed',
    'Climate Controlled',
    'Government or Public Warehouse',
    'Other',
  ];

  void _increase() {
    setState(() {
      _numberOfFloor++;
    });
  }

  void _decrease() {
    if (_numberOfFloor > 0) {
      setState(() {
        _numberOfFloor--;
      });
    }
  }

  void _lockInIncrease() {
    setState(() {
      _lockingNumber++;
    });
  }

  void _lockInDecrease() {
    if (_lockingNumber > 0) {
      setState(() {
        _lockingNumber--;
      });
    }
  }

  void _securityIncrease() {
    setState(() {
      _securityDepositNumber++;
    });
  }

  void _securityDecrease() {
    if (_securityDepositNumber > 0) {
      setState(() {
        _securityDepositNumber--;
      });
    }
  }

  void _ageIncrease() {
    setState(() {
      _constructionAgeNumber++;
    });
  }

  void _ageDecrease() {
    if (_constructionAgeNumber > 0) {
      setState(() {
        _constructionAgeNumber--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _warehouseName.addListener(_updateTextLength);
  }

  void _updateTextLength() {
    if (_warehouseName.text.length > _maxLength) {
      _warehouseName.text = _warehouseName.text.substring(0, _maxLength);
      _warehouseName.selection = TextSelection.fromPosition(
          TextPosition(offset: _warehouseName.text.length));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _warehouseName.dispose();
    _carpetAreaController.dispose();
    _rentPerSqFt.dispose();
    _maintenanceCost.dispose();
    _tokenAdvance.dispose();
    _totalArea.dispose();
    super.dispose();
  }

  // Future<void> _submitForm() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String phone = prefs.getString("phone")?.replaceFirst("+91", "") ?? "";
  //     if (kDebugMode) {
  //       print("ShareDataMobile :$phone");
  //     }
  //     if (!_formKey.currentState!.validate()) return;
  //     setState(() => isLoading = true);
  //
  //     final Map<String, dynamic> data = {
  //       'SecurityDeposit': _securityDepositNumber,
  //       'whouse_type': _selectedWarehouseType?.trim() ?? "",
  //       'whouse_Cunstructiontype': _selectedConstructionType?.trim() ?? "",
  //       'whouse_address': finalAddress.toString(),
  //       'warehouse_carpetarea':
  //           double.tryParse(_carpetAreaController.text.trim()) ?? 0.0,
  //       'TotalArea': _totalArea.text.trim(),
  //       'whouse_rentPerSQFT': double.tryParse(_rentPerSqFt.text.trim()) ?? 0.0,
  //       'whouseLockinPeriod': _lockingNumber,
  //       'whouse_maintenance': _maintenanceCost.text.trim(),
  //       'whouse_tokenAdvance': _tokenAdvance.text.trim(),
  //       'whouse_name': _warehouseName.text.trim(),
  //       'isavilableForRent': _isCheckedBase,
  //       'NOfFloors': _numberOfFloor,
  //       'Current_address': fullAddress,
  //       'CunstructiontAge': _constructionAgeNumber,
  //       'graundFloor': groundFloor,
  //       'mobile': phone.toString(),
  //     };
  //     if (kDebugMode) {
  //       print("Warehouse data $data");
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse('https://xpacesphere.com/api/Wherehousedt/Ins_whousedetails'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //     if (kDebugMode) {
  //       print("Response   >>${response.body}");
  //     }
  //     if (kDebugMode) {
  //       print("Response   >>${response.statusCode}");
  //     }
  //
  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //     if (!mounted) return;
  //     if (response.statusCode == 200 && responseData['status'] == 200) {
  //       Navigator.push(context, MaterialPageRoute(builder: (context)=>const WarehouseImageScreen()));
  //     } else {
  //       _showErrorMessage(responseData['message'] ?? 'Failed to upload data.');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error: $e');
  //     }
  //     if (context.mounted) {
  //       _showErrorMessage('An error occurred. Please try again.');
  //     }
  //   } finally {
  //     if (context.mounted) {
  //       setState(() => isLoading = false);
  //     }
  //   }
  // }

  Future<void> _submitForm() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String phone = prefs.getString("phone")?.replaceFirst("+91", "") ?? "";
      int? userId = prefs.getInt("userId");
      debugPrint("User ID: $userId");

      if (userId == null) {
        _showErrorMessage("User ID not found. Please login again.");
        return;
      }

      if (!_formKey.currentState!.validate()) return;
      setState(() => isLoading = true);

      final Map<String, dynamic> data = {
        "whouseAddress": finalAddress.toString(),
        "whouseType": _selectedWarehouseType?.trim() ?? "",
        "consType": _selectedConstructionType?.trim() ?? "",
        "whouseFloor": groundFloor,
        "whouseCarpetAria": _carpetAreaController.text.trim(), // "1500 sq ft"
        "isAvaiable": _isCheckedBase ? 1 : 0,
        "whouseRent": _rentPerSqFt.text.trim(), // "25000"
        "whouseMaintenance": _maintenanceCost.text.trim(), // "2000"
        "whouseExpected":
            _tokenAdvance.text.trim(), // Assuming this is expected rent
        "whouseToken":
            _tokenAdvance.text.trim(), // Re-use same or separate if available
        "whouseLockin": _lockingNumber,
        "whouseName": _warehouseName.text.trim(),
        "whouseFilepath":
            "/files/warehouseA.pdf", // Placeholder, update if file picker is implemented
        "mobile": phone,
        "dateTime": DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(
            'http://3.110.172.156:8083/api/v2/datawarehouses/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        //NEW CODE

        // print("📥 Response Body w: ${response.body}");
        // // ✅ Agar response me 'data' object ke andar 'id' hai
        // int? warehouseId;
        // if (responseData.containsKey('data')) {
        //   warehouseId = responseData['data']['id'];
        // }
        // // ✅ Agar directly 'id' mil raha ho
        // else if (responseData.containsKey('id')) {
        //   warehouseId = responseData['id'];
        // }
        //
        // if (warehouseId != null) {
        //   print("✅ Warehouse ID: $warehouseId");
        //   await prefs.setInt("warehouseId", warehouseId);
        // } else {
        //   print("❌ Warehouse ID not found in response");
        // }
        // ✅ Warehouse ID save करने का logic
        int? warehouseId;
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          warehouseId = responseData['data']['id'];
        } else if (responseData.containsKey('id')) {
          warehouseId = responseData['id'];
        }

        if (warehouseId != null) {
          debugPrint("Warehouse ID Saved: $warehouseId");
          await prefs.setInt("warehouseId", warehouseId);
        } else {
          debugPrint("Warehouse ID not found in response.");
        }

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WarehouseImageScreen()),
        );
      } else {
        _showErrorMessage(responseData['message'] ?? 'Failed to upload data.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      if (context.mounted) {
        _showErrorMessage('An error occurred. Please try again.');
      }
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          child: const Icon(
                                            Icons.arrow_back_ios_new,
                                            color: Colors.white,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Text(
                                          S.of(context).add_warehouse,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const Spacer(),
                                InkWell(
                                  child: Container(
                                    height: screenHeight * 0.039,
                                    width: screenWidth * 0.08,
                                    margin: EdgeInsets.only(
                                        right: screenWidth * 0.05),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.question_mark,
                                        color: AppTheme.primary,
                                        size: screenHeight * 0.025,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HelpPage()));
                                  },
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).manage_your_warehouse,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
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
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      S.of(context).enter_address,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  InkWell(
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppTheme.primarySoft,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        margin: EdgeInsets.only(
                                            top: screenHeight * 0.01),
                                        child: DottedBorder(
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.14),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    ImageAssets
                                                        .worldWideLocation,
                                                    width: screenWidth * 0.2,
                                                    height:
                                                        screenHeight * 0.04),
                                                SizedBox(
                                                    height:
                                                        screenHeight * 0.02),
                                                Text(displayText,
                                                    style: const TextStyle(
                                                        color: AppTheme.primary,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LocationSelectionScreen()),
                                      );
                                      if (result != null &&
                                          result is LocationData) {
                                        setState(() {
                                          finalAddress = result.latLng;
                                        });
                                        LatLng selectedLocation = result.latLng;
                                        String selectedAddress = result.address;
                                        LocationProvider? locationProvider;
                                        if (context.mounted) {
                                          locationProvider =
                                              Provider.of<LocationProvider>(
                                                  context,
                                                  listen: false);
                                        }
                                        locationProvider?.updateLocation(
                                            selectedAddress, selectedLocation);
                                        setState(() {
                                          fullAddress = selectedAddress;
                                          displayText +=
                                              '\nAddress: $selectedAddress';
                                          if (kDebugMode) {
                                            print("Addresses$fullAddress");
                                          }
                                        });
                                        if (kDebugMode) {
                                          print(
                                              "Selected Location: ${selectedLocation.latitude}, ${selectedLocation.longitude}");
                                        }
                                      } else {
                                        if (kDebugMode) {
                                          print("No location selected");
                                        }
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.01,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        S.of(context).warehouse_name_owner_name,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Image.asset(
                                        "assets/images/InfoPopup.png",
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                  TextFormField(
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Field is required'
                                            : null,
                                    controller: _warehouseName,
                                    decoration: InputDecoration(
                                      hintText: 'ex. Thane Mumbai Warehouse',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.015),
                                      border: InputBorder.none,
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 14, color: AppTheme.primary),
                                    maxLength: _maxLength,
                                    keyboardType: TextInputType.text,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.005,
                                  ),
                                  Text(
                                    S.of(context).total_area,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  TotalCarpetArea(totalCarpetArea: _totalArea),
                                  SizedBox(
                                    height: screenHeight * 0.009,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).carpet_area,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  CarpetAreaTextFormField(
                                      controller: _carpetAreaController),
                                  SizedBox(
                                    height: screenHeight * 0.015,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        S.of(context).ground_floor,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const Spacer(),
                                      Text(S.of(context).open),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      customCheckbox("Open"),
                                      SizedBox(
                                        width: screenWidth * 0.09,
                                      ),
                                      Text(S.of(context).close),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      customCheckbox("Close"),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S
                                            .of(context)
                                            .num_of_floors_including_ground_floors,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.197,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: AppTheme.primary,
                                          border: Border.all(
                                              color: AppTheme.primary),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _decrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.0633,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_numberOfFloor',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _increase,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isCheckedBase,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            _isCheckedBase = newValue ?? false;
                                          });
                                        },
                                        checkColor: Colors.white,
                                        fillColor:
                                            WidgetStateProperty.resolveWith(
                                                (states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return AppTheme.primary;
                                          }
                                          return Colors.white;
                                        }),
                                        side: WidgetStateBorderSide.resolveWith(
                                            (states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return const BorderSide(
                                                color: AppTheme.primary,
                                                width: 2);
                                          }
                                          return const BorderSide(
                                              color: Colors.grey, width: 2);
                                        }),
                                      ),
                                      Text(
                                        S
                                            .of(context)
                                            .is_base_available_for_rent,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).warehouse_type,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2.0),
                                        child: Image.asset(
                                          "assets/images/InfoPopup.png",
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppTheme.accent,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedWarehouseType,
                                      hint: const Text(
                                        'Select Warehouse Type',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      items: warehouseTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedWarehouseType = newValue;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Field is required'
                                          : null,
                                      dropdownColor: Colors.white,
                                      menuMaxHeight: screenHeight * 0.4,
                                      borderRadius: BorderRadius.circular(10),
                                      isExpanded: true,
                                      icon: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppTheme.accent,
                                            size: 24.0,
                                          ),
                                          Positioned(
                                            bottom: 2,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.accent,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).construction_type,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2.0),
                                        child: Image.asset(
                                          "assets/images/InfoPopup.png",
                                          height: 14,
                                          width: 13,
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppTheme.accent,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedConstructionType,
                                      hint: const Text(
                                        'Select Construction Type',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      items:
                                          _constructionTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedConstructionType = newValue;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Field is required'
                                          : null,
                                      dropdownColor:
                                          Colors.white.withValues(alpha: 0.9),
                                      menuMaxHeight: screenHeight * 0.4,
                                      borderRadius: BorderRadius.circular(10),
                                      isExpanded: true,
                                      icon: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppTheme.accent,
                                            size: 24.0,
                                          ),
                                          Positioned(
                                            bottom: 2,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.accent,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S
                                            .of(context)
                                            .construction_age_in_months,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.197,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: AppTheme.primary,
                                          border: Border.all(
                                              color: AppTheme.primary),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _ageDecrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.0633,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_constructionAgeNumber',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _ageIncrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).rent_per_sqft,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  RentPerSqFt(
                                    controller: _rentPerSqFt,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${S.of(context).maintenance_cost_per_sqft} ",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  MaintenanceCost(
                                    controller: _maintenanceCost,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).security_deposit,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.197,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: AppTheme.primary,
                                          border: Border.all(
                                              color: AppTheme.primary),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _securityDecrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.0633,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_securityDepositNumber',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _securityIncrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).token_advance,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  TokenAdvance(
                                    controller: _tokenAdvance,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).lock_in_period,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.197,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          color: AppTheme.primary,
                                          border: Border.all(
                                              color: AppTheme.primary),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _lockInDecrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth * 0.0633,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_lockingNumber',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _lockInIncrease,
                                              child: Container(
                                                width: screenWidth * 0.0633,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.green),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _submitForm,
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: SpinKitCircle(
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            )
                                          : Text(
                                              S.of(context).save,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget customCheckbox(String label) {
    bool isChecked = groundFloor == label;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          groundFloor = label;
          if (kDebugMode) {
            print("option selected  $groundFloor");
          }
        });
      },
      child: Container(
        width: screenWidth * 0.06,
        height: screenHeight * 0.028,
        decoration: BoxDecoration(
          color: isChecked ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
        ),
        child: isChecked
            ? const Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              )
            : null,
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

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.height) {
      canvas.drawLine(
        Offset(size.width, startX),
        Offset(size.width, startX + dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(size.width - startX, size.height),
        Offset(size.width - startX - dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0;
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

class CarpetAreaTextFormField extends StatelessWidget {
  final TextEditingController controller;

  const CarpetAreaTextFormField({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'Enter carpet area',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|SQFT',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class HeightOfWarehouse extends StatelessWidget {
  final TextEditingController controller;
  const HeightOfWarehouse({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'Enter height of warehouse',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|metre',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class ConstructionAge extends StatelessWidget {
  final TextEditingController controller;
  const ConstructionAge({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'Enter construction age',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|Years',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class TotalCarpetArea extends StatelessWidget {
  final TextEditingController totalCarpetArea;

  const TotalCarpetArea({super.key, required this.totalCarpetArea});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
      child: TextFormField(
        style: const TextStyle(fontSize: 14, color: AppTheme.primary),
        controller: totalCarpetArea,
        keyboardType: TextInputType.number,
        validator: (value) =>
            value == null || value.isEmpty ? 'Field is required' : null,
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          contentPadding: const EdgeInsets.only(left: 8, bottom: 10),
          border: InputBorder.none,
          suffix: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 6),
            child: const Text(
              '|SQFT',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

class RentPerSqFt extends StatelessWidget {
  final TextEditingController controller;

  const RentPerSqFt({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: '₹|ex.35',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|per month',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class MaintenanceCost extends StatelessWidget {
  final TextEditingController controller;

  const MaintenanceCost({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: '₹|ex.2',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|per month',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class ExpectedSecurityDeposit extends StatelessWidget {
  final TextEditingController controller;

  const ExpectedSecurityDeposit({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: const InputDecoration(
        hintText: 'ex.2',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
      ),
    );
  }
}

class TokenAdvance extends StatelessWidget {
  final TextEditingController controller;

  const TokenAdvance({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'Rs.',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class ExpectedLockInPeriod extends StatelessWidget {
  final TextEditingController controller;

  const ExpectedLockInPeriod({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'ex.18',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|per month',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class CarpetAreaTextFormField8 extends StatelessWidget {
  const CarpetAreaTextFormField8({super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14, color: AppTheme.primary),
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'ex.18',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.0),
        ),
        suffix: Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            '|per month',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
