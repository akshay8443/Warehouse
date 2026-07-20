import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'package:Lisofy/Warehouse/Partner/home_screen.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseService extends StatefulWidget {
  final String electricity;
  final String tenants;
  final int toilets;
  final String parkingSlots;
  final String constructionAge;
  final String bikeSlots;
  final int fans;
  final int lights;
  final String powerBackup;
  final String provideOffice;
  final String dockLevelers;
  final String cluDocument;
  final String fireComplaint;
  final int id;
  const WarehouseService({
    super.key,
    required this.electricity,
    required this.tenants,
    required this.toilets,
    required this.parkingSlots,
    required this.constructionAge,
    required this.bikeSlots,
    required this.fans,
    required this.lights,
    required this.powerBackup,
    required this.provideOffice,
    required this.dockLevelers,
    required this.fireComplaint,
    required this.cluDocument,
    required this.id,
  });

  @override
  State<WarehouseService> createState() => _WarehouseServiceState();
}

class _WarehouseServiceState extends State<WarehouseService> {
  final TextEditingController _noOfDocks = TextEditingController();
  final TextEditingController _dockHeight = TextEditingController();
  final TextEditingController _sideHeight = TextEditingController();
  final TextEditingController _centreHeight = TextEditingController();
  final TextEditingController _width = TextEditingController();
  final TextEditingController _length = TextEditingController();

  String? _selectedFlooringType;
  String? _selectedFurnishingType;
  String flexingModel = '';

  final List<String> _flooringType = ['Epoxy', 'VDF', 'Concrete'];
  final List<String> _furnishingType = [
    'Full Furnished',
    'Semi Furnished',
    'Unfurnished',
    'Others'
  ];

  void _showCupertinoSheet(List<String> options, Function(String) onSelected) {
    int selectedIndex = 0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          height: screenHeight * 0.4,
          padding: EdgeInsets.all(screenHeight * 0.05),
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: screenWidth * 0.17,
                  onSelectedItemChanged: (index) {
                    FocusScope.of(context).unfocus();
                    selectedIndex = index;
                  },
                  children: options.map((option) => Text(option)).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.of(context).cancel,
                        style: const TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      onSelected(options[selectedIndex]);
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).done,
                        style: const TextStyle(color: AppTheme.primary)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _submitForm() async {
    // NEW CODE
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? warehouseId = prefs.getInt("warehouseId");

    if (warehouseId == null) {
      print("❌ Warehouse ID not found");
      return;
    }
    if ([_noOfDocks, _dockHeight, _sideHeight, _centreHeight, _width, _length]
            .any((controller) => controller.text.isEmpty) ||
        _selectedFlooringType == null ||
        _selectedFurnishingType == null) {
      return;
    }
    _showProgressIndicator();
    try {
      final bodyData = _prepareBodyData();
      if (kDebugMode) {
        print("Request Body: $bodyData");
      }
      final response = await http.post(
        Uri.parse(
            'http://3.110.172.156:8083/api/v3/amenities/warehouse/$warehouseId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyData),
      );
      if (kDebugMode) {
        print("Response: ${response.statusCode}, Body: ${response.body}");
      }
      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSuccessPopup();
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error: $error");
      }
      Navigator.of(context).pop();
    }
  }

  void _showProgressIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitCircle(color: AppTheme.primary, size: 50.0),
      ),
    );
  }

  void _showSuccessPopup() {
    print("Success popup called");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/addedAnimation.json',
                width: 120,
                height: 120,
                repeat: false,
              ),
              const SizedBox(height: 10),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Your warehouse has been Published Successfully...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      print('Closing popup and navigating to HomeScreen');
      Navigator.of(context).pop();
      _navigateToHomeScreen();
    });
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Map<String, dynamic> _prepareBodyData() {
    return {
      "electricity": widget.electricity,
      "p_backup": widget.powerBackup.toLowerCase() == "yes",
      "office_space": widget.provideOffice.toLowerCase() == "yes",
      "dock_levelers": widget.dockLevelers.toLowerCase() == "yes",
      //"no_of_toilets": int.tryParse(widget.toilets) ?? 0,
      "no_of_toilets": widget.toilets,
      "truck_parking_slots": int.tryParse(widget.parkingSlots) ?? 0,
      "bike_parking_slots": int.tryParse(widget.bikeSlots) ?? 0,
      //"no_of_fan": int.tryParse(widget.fans) ?? 0,
      "no_of_fan": widget.fans,
      //"no_of_light": int.tryParse(widget.lights) ?? 0,
      "no_of_light": widget.lights,
      "fire_noc": widget.fireComplaint.toLowerCase() == "yes",
      "no_of_docks": int.tryParse(_noOfDocks.text.trim()) ?? 0,
      "length": double.tryParse(_length.text.trim()) ?? 0.0,
      "width": double.tryParse(_width.text.trim()) ?? 0.0,
      "side_height": double.tryParse(_sideHeight.text.trim()) ?? 0.0,
      "center_height": double.tryParse(_centreHeight.text.trim()) ?? 0.0,
      "height_of_dock": double.tryParse(_dockHeight.text.trim()) ?? 0.0,
      // "flexi_model": widget.flexingModel?.toLowerCase() == "yes",
      "flooring_type": _selectedFlooringType,
      "furnicing_type": _selectedFurnishingType
    };
  }

  @override
  void dispose() {
    _noOfDocks.dispose();
    _dockHeight.dispose();
    _sideHeight.dispose();
    _centreHeight.dispose();
    _width.dispose();
    _length.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            height: screenHeight * 0.18,
            width: double.infinity,
            padding: EdgeInsets.only(
                left: screenWidth * 0.07, top: screenHeight * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        child: const Icon(Icons.arrow_back_ios_new_outlined,
                            color: Colors.white),
                        onTap: () => Navigator.pop(context),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(S.of(context).add_warehouse_details,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text("${S.of(context).warehouse_dimensions} 4/4",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.005,
                  horizontal: screenWidth * 0.045),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            keyboardType: TextInputType.number,
                            controller: _length,
                            decoration: InputDecoration(
                              labelText: S.of(context).inner_length,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            keyboardType: TextInputType.number,
                            controller: _width,
                            decoration: InputDecoration(
                              labelText: S.of(context).inner_width,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            keyboardType: TextInputType.number,
                            controller: _sideHeight,
                            decoration: InputDecoration(
                              labelText: S.of(context).side_height,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            keyboardType: TextInputType.number,
                            controller: _centreHeight,
                            decoration: InputDecoration(
                              labelText: S.of(context).centre_height,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            controller: _noOfDocks,
                            decoration: InputDecoration(
                              labelText: S.of(context).num_of_docks,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: AppTheme.primary),
                            controller: _dockHeight,
                            decoration: InputDecoration(
                              labelText: S.of(context).docks_height,
                              labelStyle: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                              hintText: "ex2",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.primary),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppTheme.primary, width: 2.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ListTile(
                      tileColor: AppTheme.primarySoft,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1)),
                      title: Text(
                        S.of(context).flooring_type,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(_selectedFlooringType ?? 'None',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              color: AppTheme.primary)),
                      trailing: const Icon(Icons.keyboard_arrow_down,
                          color: AppTheme.primary),
                      onTap: () => _showCupertinoSheet(
                        _flooringType,
                        (value) =>
                            setState(() => _selectedFlooringType = value),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ListTile(
                      tileColor: AppTheme.primarySoft,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1)),
                      title: Text(S.of(context).furnishing_type),
                      subtitle: Text(_selectedFurnishingType ?? 'None',
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            color: AppTheme.primary,
                          )),
                      trailing: const Icon(Icons.keyboard_arrow_down,
                          color: AppTheme.primary),
                      onTap: () => _showCupertinoSheet(
                        _furnishingType,
                        (value) =>
                            setState(() => _selectedFurnishingType = value),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // buildToggleButtons(
                    //     S.of(context).flexi_model_interest,
                    //     flexingModel,
                    //     (value) => setState(() => flexingModel = value)),
                    // SizedBox(height: screenHeight * 0.04),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 8, // Add elevation
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.06),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.15,
                              vertical: screenHeight * 0.01),
                        ),
                        child: Text(
                          S.of(context).submit,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildToggleButtons(
      String title, String selectedValue, Function(String) onSelected) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015, horizontal: screenWidth * 0.037),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              buildToggleButton('Yes', selectedValue, onSelected),
              SizedBox(width: screenWidth * 0.03),
              buildToggleButton('No', selectedValue, onSelected),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildToggleButton(
      String label, String selectedValue, Function(String) onSelected) {
    bool isActive = label == selectedValue;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => onSelected(label),
      child: Container(
        width: screenWidth * 0.1,
        height: screenHeight * 0.03,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
