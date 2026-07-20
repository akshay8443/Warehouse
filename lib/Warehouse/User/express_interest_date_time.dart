import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Warehouse/User/user_home_page.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExpressInterestDateTime extends StatefulWidget {
  final dynamic name;
  final dynamic email;
  final dynamic phone;
  final dynamic companyName;
  final dynamic designation;
  final dynamic dateOfPossession;
  final dynamic msg;
  final dynamic id;
  const ExpressInterestDateTime(
      {super.key,
      required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.companyName,
      required this.designation,
      required this.msg,
      this.dateOfPossession});
  @override
  State<ExpressInterestDateTime> createState() =>
      _ExpressInterestDateTimeState();
}

class _ExpressInterestDateTimeState extends State<ExpressInterestDateTime> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  ///Post interest data of the user
  Future<void> postWarehouseData() async {
    if (!context.mounted) return;
    Map<String, dynamic> data = {
      "warehouse_Id": widget.id,
      "Name": widget.name.toString(),
      "email": widget.email.toString(),
      "Company_Name": widget.companyName.toString(),
      "Designation": widget.designation.toString(),
      "Possession_date": widget.dateOfPossession,
      "Message": widget.msg,
      "MDate": _selectedDate.toString(),
      "MTime": _selectedTime.toString(),
      "Contact": widget.phone.toString(),
      "Type": "Interested"
    };

    String url = "https://xpacesphere.com/api/Wherehousedt/Intrest_warehouse";
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Data posted successfully!');
        }
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
        if (mounted) {
          showCongratulationsDialog(context);
        }
      } else {
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
    }
  }

  void showCongratulationsDialog(BuildContext context) {
    if (!context.mounted) return;
    SharedPreferences.getInstance().then((pref) {
      if (!context.mounted) return;
      double? latitude = pref.getDouble("latitude");
      double? longitude = pref.getDouble("longitude");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImageAssets.intrest),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).congratulations,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).warehouse_added_success,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                        Navigator.pushAndRemoveUntil(
                          dialogContext,
                          MaterialPageRoute(
                            builder: (context) => UserHomePage(
                              latitude: latitude ?? 0.0,
                              longitude: longitude ?? 0.0,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text(
                      S.of(context).continue_browsing,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => UserHomePage(
                latitude: latitude ?? 0.0,
                longitude: longitude ?? 0.0,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      });
    });
  }

  void _selectDate(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempPickedDate = initialDate;
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight * 0.3,
                    width: screenWidth * 06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.08),
                          topRight: Radius.circular(screenWidth * 0.08)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate,
                      onDateTimeChanged: (DateTime newDate) {
                        tempPickedDate = newDate;
                      },
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Container(
                      width: screenWidth * 06, height: 3, color: Colors.grey),
                  Container(
                    width: screenWidth * 06,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.08)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, tempPickedDate);
                      },
                      child: Text(
                        S.of(context).ok,
                        style: const TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: -70,
                left: 0,
                right: 0,
                child: Container(
                  width: screenWidth * 06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).cancel,
                        style: const TextStyle(color: AppTheme.primary)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  final TextEditingController _timeController = TextEditingController();
  DateTime? _selectedTime;
  void _selectTime(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime initialTime = _selectedTime ?? DateTime.now();
    DateTime? pickedTime = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempPickedTime = initialTime;
        int selectedHour =
            initialTime.hour > 12 ? initialTime.hour - 12 : initialTime.hour;
        int selectedMinute = initialTime.minute;
        bool isAm = initialTime.hour < 12;
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight * 0.21,
                    width: screenWidth * 06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.08),
                          topRight: Radius.circular(screenWidth * 0.08)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimeColumnWithArrows(
                          context,
                          1,
                          12,
                          selectedHour,
                          (newHour) {
                            selectedHour = newHour;
                          },
                        ),
                        _buildTimeColumnWithArrows(
                          context,
                          0,
                          59,
                          selectedMinute,
                          (newMinute) {
                            selectedMinute = newMinute;
                          },
                        ),
                        _buildAmPmColumnWithArrows(
                          isAm ? 'AM' : 'PM',
                          (newAmPm) {
                            isAm = (newAmPm == 'AM');
                          },
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                      width: screenWidth * 06, height: 3, color: Colors.grey),
                  // OK button
                  SizedBox(
                    width: screenWidth * 06,
                    child: TextButton(
                      onPressed: () {
                        int hour =
                            isAm ? selectedHour % 12 : (selectedHour % 12) + 12;
                        tempPickedTime = DateTime(
                          initialTime.year,
                          initialTime.month,
                          initialTime.day,
                          hour,
                          selectedMinute,
                        );
                        Navigator.pop(context, tempPickedTime);
                      },
                      child: Text(
                        S.of(context).ok,
                        style: const TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: -70,
                left: 0,
                right: 0,
                child: Container(
                  width: screenWidth * 06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).cancel,
                        style: const TextStyle(color: AppTheme.primary)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = DateFormat('hh:mm a').format(_selectedTime!);
      });
    }
  }

  Widget _buildTimeColumnWithArrows(BuildContext context, int min, int max,
      int selectedValue, ValueChanged<int> onSelectedItemChanged) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          const Icon(Icons.arrow_drop_up, size: 30, color: Colors.grey),
          SizedBox(
            width: screenWidth * 0.2,
            height: screenHeight * 0.12,
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: selectedValue - min),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                onSelectedItemChanged(index + min);
              },
              magnification: 1.2,
              useMagnifier: true,
              backgroundColor: Colors.transparent,
              children: List<Widget>.generate(max - min + 1, (int index) {
                return Center(
                  child: Text(
                    (index + min).toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }),
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 30, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAmPmColumnWithArrows(
      String selectedAmPm, ValueChanged<String> onSelectedItemChanged) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          const Icon(Icons.arrow_drop_up, size: 30, color: Colors.grey),
          SizedBox(
            width: screenWidth * 0.2,
            height: screenHeight * 0.12,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: selectedAmPm == 'AM' ? 0 : 1),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                onSelectedItemChanged(index == 0 ? 'AM' : 'PM');
              },
              magnification: 1.2,
              useMagnifier: true,
              backgroundColor: Colors.transparent,
              children: const <Widget>[
                Center(
                  child: Text(
                    'AM',
                    style: TextStyle(fontSize: 22, color: AppTheme.primary),
                  ),
                ),
                Center(
                  child: Text(
                    'PM',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 30, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
                      height: screenHeight * 0.13,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.05,
                          left: screenWidth * 0.04,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_sharp,
                                      color: Colors.white,
                                    )),
                                const SizedBox(
                                  width: 0,
                                ),
                                Text(
                                  S.of(context).express_interest,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                )
                              ],
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
                            topRight: Radius.circular(screenWidth * 0.12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Container(
                                height: screenHeight * 0.18,
                                width: screenWidth * 0.95,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07)),
                                child: Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 18.0, top: 15),
                                          child: Text(
                                            S.of(context).select_date,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: TextField(
                                        onTap: () {
                                          _selectDate(context);
                                        },
                                        readOnly: true,
                                        controller: _dateController,
                                        decoration: InputDecoration(
                                          labelText: 'Date',
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                          hintText: 'dd/mm/yyyy',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            onPressed: () =>
                                                _selectDate(context),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 2.0),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.primary,
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: screenHeight * 0.18,
                                width: screenWidth * 0.95,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07)),
                                child: Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 18.0, top: 15),
                                          child: Text(
                                            S.of(context).select_time,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: TextField(
                                        controller: _timeController,
                                        readOnly: true,
                                        onTap: () => _selectTime(context),
                                        decoration: InputDecoration(
                                          labelText: 'Time',
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                                Icons.more_time_rounded),
                                            onPressed: () {
                                              _selectTime(context);
                                            },
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 2.0),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.primary,
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.1,
                              ),
                              Container(
                                height: screenHeight * 0.06,
                                margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.07),
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.07),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      postWarehouseData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppTheme.primary,
                                      minimumSize: Size(
                                          double.infinity, screenHeight * 0.06),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.07),
                                      ),
                                    ),
                                    child: Text(S.of(context).submit),
                                  ),
                                ),
                              ),
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
}
