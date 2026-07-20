import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/Warehouse/Partner/help_page.dart';
import 'package:Lisofy/Warehouse/Partner/home_screen.dart';
import 'package:Lisofy/Warehouse/Partner/map_screen.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/location_provider.dart';
import 'package:Lisofy/Warehouse/Partner/models/warehouses_model.dart';
import 'package:Lisofy/Warehouse/Partner/warehouse_media_update.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WarehouseUpdate extends StatefulWidget {
  final Warehouse warehouse;
  const WarehouseUpdate({super.key, required this.warehouse});
  @override
  State<WarehouseUpdate> createState() => _WarehouseUpdateState();
}

class _WarehouseUpdateState extends State<WarehouseUpdate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _carpetAreaController = TextEditingController();
  final TextEditingController _totalArea = TextEditingController();
  final TextEditingController _rentPerSqFt = TextEditingController();
  final TextEditingController _maintenanceCost = TextEditingController();
  final TextEditingController _expectedSecurityDeposit =
      TextEditingController();
  final TextEditingController _tokenAdvance = TextEditingController();
  final TextEditingController _expectedLockInPeriod = TextEditingController();
  final TextEditingController _warehouseName = TextEditingController();
  final int _maxLength = 29;
  bool _isChecked = false;
  int _number = 0;
  late String _address = "Fetching address...";
  int _constructionAgenumber = 0;
  int _securityDepositNumber = 0;
  int _lockinNumber = 0;
  String? _selectedWarehouseType;
  String? _selectedConstructionType;
  String? selectedLocation;
  bool isLoading = false;
  late LatLng finalAddress = const LatLng(0.0, 0.0);
  LatLng? _latLng;
  String groundFloor = "";
  void _increase() {
    setState(() {
      _number++;
    });
  }

  void _decrease() {
    if (_number > 0) {
      setState(() {
        _number--;
      });
    }
  }

  void _ageIncrease() {
    setState(() {
      _constructionAgenumber++;
    });
  }

  void _ageDecrease() {
    if (_constructionAgenumber > 0) {
      setState(() {
        _constructionAgenumber--;
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

  void _lockInIncrease() {
    setState(() {
      _lockinNumber++;
    });
  }

  void _lockInDecrease() {
    if (_lockinNumber > 0) {
      setState(() {
        _lockinNumber--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng();
    _constructionAgenumber = widget.warehouse.constructionAge;
    _securityDepositNumber = widget.warehouse.securityDeposit;
    _lockinNumber = int.parse(widget.warehouse.wHouseLockingPeriod);
    groundFloor = widget.warehouse.groundFloor;
    _selectedWarehouseType = widget.warehouse.wHouseType;
    _selectedConstructionType = widget.warehouse.wHouseConstructionType;
    _number = widget.warehouse.nOfFloors;
    _isChecked = widget.warehouse.isAvailableForRent;
    _carpetAreaController.text =
        widget.warehouse.warehouseCarpetArea.toString();
    _totalArea.text = widget.warehouse.totalArea.toString();
    _rentPerSqFt.text = widget.warehouse.wHouseRentPerSQFT.toString();
    _maintenanceCost.text = widget.warehouse.wHouseMaintenance.toString();
    _expectedSecurityDeposit.text =
        widget.warehouse.wHouseMaintenance.toString();
    _tokenAdvance.text = widget.warehouse.wHouseTokenAdvance.toString();
    _expectedLockInPeriod.text =
        widget.warehouse.wHouseLockingPeriod.toString();
    _warehouseName.text = widget.warehouse.wHouseName.toString();
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      RegExp regExp = RegExp(r'LatLng\(([^,]+), ([^,]+)\)');
      Match? match = regExp.firstMatch(widget.warehouse.wHouseAddress);
      if (match != null && match.groupCount == 2) {
        double latitude = double.parse(match.group(1)!.trim());
        double longitude = double.parse(match.group(2)!.trim());
        _latLng = LatLng(latitude, longitude);
        List<Placemark> placeMarks =
            await placemarkFromCoordinates(latitude, longitude);
        Placemark place = placeMarks[0];
        if (placeMarks.isNotEmpty) {
          setState(() {
            _address =
                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
            if (kDebugMode) {
              print(_address);
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address: $e");
      }
    }
  }

  final List<String> _construction = [
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
  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString("phone")!;
    if (phone.startsWith("+91")) {
      phone = phone.replaceFirst("+91", "");
    }

    if (kDebugMode) {
      print("Mobile>>>$phone");
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      LatLng addressToSubmit = finalAddress != const LatLng(0.0, 0.0)
          ? finalAddress
          : _latLng ?? const LatLng(0.0, 0.0);
      String warehousetype = _selectedWarehouseType!;
      String constructionType = _selectedConstructionType!;
      double carpetArea = double.tryParse(_carpetAreaController.text) ?? 0.0;
      String totalArea = _totalArea.text.toString().trim();
      double rentPerSqFt = double.tryParse(_rentPerSqFt.text.trim()) ?? 0.0;
      String maintenanceCostValue = _maintenanceCost.text.toString().trim();
      String expectedSecurityDepositValue =
          _expectedSecurityDeposit.text.toString();
      String tokenAdvanceValue = _tokenAdvance.text.toString().trim();
      int lockInPeriodValue = _lockinNumber;
      String warehouseNameValue = _warehouseName.text.toString().trim();
      String graundFloor = groundFloor.trim();
      int constructionAge = _constructionAgenumber;
      int securityDeposit = _securityDepositNumber;

      Map<String, dynamic> data = {
        'whouse_type': warehousetype,
        'whouse_Cunstructiontype': constructionType,
        'whouse_address': addressToSubmit.toString(),
        'warehouse_carpetarea': carpetArea,
        'TotalArea': totalArea,
        'whouse_rentPerSQFT': rentPerSqFt,
        'whouse_maintenance': maintenanceCostValue,
        'whouse_expected': expectedSecurityDepositValue,
        'whouse_tokenAdvance': tokenAdvanceValue,
        'whouseLockinPeriod': lockInPeriodValue,
        'whouse_name': warehouseNameValue,
        'SecurityDeposit': securityDeposit,
        'NOfFloors': _number,
        'Id': widget.warehouse.id,
        'mobile': phone,
        'graundFloor': graundFloor,
        'isavilableForRent': _isChecked,
        'CunstructiontAge': constructionAge,
      };
      if (kDebugMode) {
        print("Dataclass $data");
      }
      try {
        final response = await http.post(
          Uri.parse('https://xpacesphere.com/api/Wherehousedt/Updwarehouse'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );
        if (kDebugMode) {
          print("ApiResponseBody${response.body}");
        }
        if (kDebugMode) {
          print("ApiResponseCode${response.statusCode}");
        }
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (response.statusCode == 200 && responseData['status'] == 200) {
            if (kDebugMode) {
              print('Data Updated successfully');
            }
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WarehouseMediaUpdate(warehouse: widget.warehouse)),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _clearFormFields();
            setState(() {
              isLoading = false;
            });
          } else {
            if (kDebugMode) {
              print('Failed to submit data: ${response.statusCode}');
            }
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload data. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing response JSON: $e');
          }
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error occurred: $e');
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _clearFormFields() {
    _carpetAreaController.clear();
    _totalArea.clear();
    _rentPerSqFt.clear();
    _maintenanceCost.clear();
    _expectedSecurityDeposit.clear();
    _tokenAdvance.clear();
    _expectedLockInPeriod.clear();
    _warehouseName.clear();
    finalAddress = const LatLng(0.0, 0.0);
    _isChecked = false;
    _number = 1;
    _selectedWarehouseType = '';
    _selectedConstructionType = '';
    setState(() {});
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
                                          S.of(context).update_warehouse,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const Spacer(),
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
                                            builder: (context) =>
                                                const HelpPage()));
                                  },
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: screenHeight * 0.08, left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).update_warehouse_info,
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
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: screenHeight * 0.02,
                                          left: screenHeight * 0.035),
                                      child: Text(
                                        S.of(context).update_warehouse_address,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      )),
                                  InkWell(
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        margin: EdgeInsets.only(
                                            top: screenHeight * 0.01),
                                        child: DottedBorder(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    'assets/images/Worldwidelocation.png',
                                                    width: 40,
                                                    height:
                                                        40), // Replace with your image asset
                                                Text(
                                                    _address.isNotEmpty
                                                        ? _address
                                                        : 'Address not available',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                SizedBox(
                                                  height: 100,
                                                  width: double.infinity,
                                                  child: _latLng != null
                                                      ? GoogleMap(
                                                          initialCameraPosition:
                                                              CameraPosition(
                                                            target: _latLng!,
                                                            zoom: 18.0,
                                                          ),
                                                          markers: {
                                                            Marker(
                                                              markerId:
                                                                  const MarkerId(
                                                                      'location'),
                                                              position:
                                                                  _latLng!,
                                                              icon: BitmapDescriptor
                                                                  .defaultMarkerWithHue(
                                                                      BitmapDescriptor
                                                                          .hueRed),
                                                            ),
                                                          },
                                                        )
                                                      : const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      // Navigate to the LocationSelectionScreen
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
                                        if (context.mounted) {
                                          final locationProvider =
                                              Provider.of<LocationProvider>(
                                                  context,
                                                  listen: false);
                                          locationProvider.updateLocation(
                                              selectedAddress,
                                              selectedLocation);
                                        }
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
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        S.of(context).warehouse_name_owner_name,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2.0),
                                        child: Image.asset(
                                          "assets/images/InfoPopup.png",
                                          height: 18,
                                          width: 17,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  TextFormField(
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Field is required'
                                            : null,
                                    controller: _warehouseName,
                                    decoration: const InputDecoration(
                                      hintText: 'ex. Thane Mumbai Warehouse',
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      border: InputBorder.none,
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    maxLength: _maxLength,
                                    keyboardType: TextInputType.text,
                                  ),
                                  Text(
                                    S.of(context).total_area,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TotalCarpetArea(totalcarpetArea: _totalArea),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).carpet_area,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  CarpetAreaTextFormField(
                                      controller: _carpetAreaController),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        S.of(context).ground_floor,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Text(S.of(context).open),
                                      customCheckbox("Open"),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(S.of(context).close),
                                      customCheckbox("Close"),
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
                                        S
                                            .of(context)
                                            .num_of_floors_including_ground_floors,
                                        style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 82,
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
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                _number.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _increase,
                                              child: Container(
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
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
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            _isChecked = newValue ?? false;
                                          });
                                        },
                                        checkColor: AppTheme.primary,
                                        fillColor: WidgetStateProperty.all(
                                            Colors.white),
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
                                            color: Colors.grey, fontSize: 13),
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
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
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: widget.warehouse.wHouseType,
                                      hint: const Text(
                                        'Select Warehouse Type',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                      items: warehouseTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style:
                                                const TextStyle(fontSize: 14),
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
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Colors.grey,
                                      ),
                                      iconSize: 20.0,
                                      isExpanded: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).construction_type,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
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
                                            color: AppTheme.primary,
                                            width: 1.0),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: widget
                                          .warehouse.wHouseConstructionType,
                                      hint: const Text(
                                        'Select Construction Type',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                      items: _construction.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style:
                                                const TextStyle(fontSize: 14),
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
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Colors.grey,
                                      ),
                                      iconSize: 20.0,
                                      isExpanded: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S
                                            .of(context)
                                            .construction_age_in_months,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 82,
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
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_constructionAgenumber',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _ageIncrease,
                                              child: Container(
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
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
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).rent_per_sqft,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  RentPerSqFt(
                                    controller: _rentPerSqFt,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).maintenance_cost_per_sqft,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  MaintenanceCost(controller: _maintenanceCost),
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
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 82,
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
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
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
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  TokenAdvance(
                                    controller: _tokenAdvance,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.of(context).lock_in_period,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 82,
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
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '-',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              color: AppTheme.primary,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$_lockinNumber',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _lockInIncrease,
                                              child: Container(
                                                width: 25,
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
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
                                    height: 30,
                                  ),
                                  InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 15),
                                      child: DottedBorder(
                                        child: Container(
                                          color: AppTheme.primary,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              isLoading
                                                  ? const SpinKitCircle(
                                                      color: Colors.white,
                                                      size: 50.0,
                                                    )
                                                  : Text(
                                                      S
                                                          .of(context)
                                                          .update_and_proceed,
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
                                      _submitForm();
                                    },
                                  ),
                                  InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 50),
                                      child: DottedBorder(
                                        child: Container(
                                          color: AppTheme.primary,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              isLoading
                                                  ? const SpinKitCircle(
                                                      color: Colors.white,
                                                      size: 50.0,
                                                    )
                                                  : Row(
                                                      children: [
                                                        Text(
                                                          S
                                                              .of(context)
                                                              .skip_for_now,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .skip_next_outlined,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()),
                                      );
                                    },
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
        width: 25,
        height: 25,
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

class CarpetAreaTextFormField extends StatelessWidget {
  final TextEditingController controller;

  const CarpetAreaTextFormField({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14),
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
            '|sqft',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class TotalCarpetArea extends StatelessWidget {
  final TextEditingController totalcarpetArea;

  const TotalCarpetArea({super.key, required this.totalcarpetArea});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
      child: TextFormField(
        style: const TextStyle(fontSize: 14),
        controller: totalcarpetArea,
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
              '|sqft',
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
      style: const TextStyle(fontSize: 14),
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
      style: const TextStyle(fontSize: 14),
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
      style: const TextStyle(fontSize: 14),
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
      style: const TextStyle(fontSize: 14),
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
      decoration: InputDecoration(
        hintText: 'ex.3',
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

class ExpectedLockInPeriod extends StatelessWidget {
  final TextEditingController controller;

  const ExpectedLockInPeriod({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 14),
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
