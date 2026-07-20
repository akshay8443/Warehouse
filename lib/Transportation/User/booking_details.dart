import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/User/summary_screen.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_button.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class BookingPage extends StatefulWidget {
  final String pickUpAddress;
  final String finalAddress;
  final String distance;
  const BookingPage(
      {required this.finalAddress,
      required this.pickUpAddress,
      super.key,
      required this.distance});
  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  final TextEditingController weightController = TextEditingController();
  final PageController _controller = PageController(viewportFraction: .4);
  int currentIndex = 0;
  int selectedIndex = -1;
  String? selectedCategoryItem;
  final List<Map<String, String>> categoryItem = [
    {'text': 'Chemicals and\nLiquid Barrels', 'image': ImageAssets.chemical},
    {'text': 'Solar\n Products', 'image': ImageAssets.solar},
    {'text': 'Household and\nWorkplace Items', 'image': ImageAssets.workplace},
    {'text': 'Industrial\nMachinery', 'image': ImageAssets.chimney},
    {
      'text': 'Electrical Panels\nEquipment Spare parts',
      'image': ImageAssets.electricPanel
    },
  ];
  final TextEditingController _dateController = TextEditingController();
  final List<String> wightType = ['kg', 'gm', 'mg', 'ton'];
  String selectedQuantityType = 'kg';
  void _showDatePicker() {
    final screenWidth = MediaQuery.of(context).size.width;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: screenWidth * 0.7,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done',
                        style: TextStyle(color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    _dateController.text =
                        DateFormat('dd-MM-yyyy').format(dateTime);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? vehicleSelectedItem;
  bool advancedPayment = true;
  bool isOpen = false;
  final List<Map<String, String>> vehicleItem = [
    {'image': ImageAssets.chemical, 'text': 'Bus'},
    {'image': ImageAssets.chemical, 'text': 'Car'},
    {'image': ImageAssets.chemical, 'text': 'Taxi'},
  ];
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Transportation",
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.025,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.1),
                child: const Text(
                  "Choose Goods Category",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  AnimatedOpacity(
                    opacity: currentIndex > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_circle_left_outlined,
                        size: screenWidth * 0.075,
                        color: AppTheme.primary,
                      ),
                      onPressed: currentIndex > 0
                          ? () {
                              setState(() {
                                currentIndex--;
                                if (_controller.hasClients) {
                                  _controller.animateToPage(
                                    currentIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.12,
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: categoryItem.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        padEnds: false, // Prevent automatic centering of items
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                selectedCategoryItem =
                                    categoryItem[index]['text']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : screenWidth * 0.02,
                                right: screenWidth * 0.02,
                              ),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? AppTheme.primary
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    categoryItem[index]['image']!,
                                    height: screenHeight * 0.05,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      categoryItem[index]['text']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: currentIndex < categoryItem.length - 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_circle_right_outlined,
                        size: screenWidth * 0.075,
                        color: AppTheme.primary,
                      ),
                      onPressed: currentIndex < categoryItem.length - 1
                          ? () {
                              setState(() {
                                currentIndex++;
                                if (_controller.hasClients) {
                                  _controller.animateToPage(
                                    currentIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.09),
                child: const Text(
                  "Date",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.03),
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _showDatePicker,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Select Date',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Icon(Icons.calendar_month_outlined,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Weight",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 22),
                    ),
                    SizedBox(
                      width: screenWidth * 0.015,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Weight is required';
                          }
                          if (value.length > 10) {
                            return 'Enter in range';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.001),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            borderSide:
                                const BorderSide(color: AppTheme.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.015,
                    ),
                    Container(
                      width: screenWidth * 00.17,
                      height: screenHeight * 0.055,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(screenWidth * 0.01),
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      child: Center(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedQuantityType,
                            icon: const Icon(Icons.keyboard_arrow_down_outlined,
                                color: Colors.white),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            dropdownColor: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedQuantityType = newValue!;
                              });
                            },
                            items: wightType
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.085,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.09, top: screenHeight * 0.035),
                child: const Text(
                  "Choose your Vehicle",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() => isOpen = !isOpen);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.088,
                          vertical: screenHeight * 0.005),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vehicleSelectedItem ?? '',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Icon(isOpen
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_outlined),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen)
                    BounceInDown(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.088,
                            vertical: screenHeight * 0.005),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: Column(
                          children: vehicleItem
                              .map((item) => _buildDropdownItem(item))
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.09, top: screenHeight * 0.035),
                child: const Text(
                  "Advance Payment Options",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                height: screenHeight * 0.05,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 7,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              advancedPayment = true;
                            });
                          },
                          child: Container(
                            color: advancedPayment
                                ? AppTheme.primary
                                : Colors.white,
                            alignment: Alignment.center,
                            child: Text(
                              '70%',
                              style: TextStyle(
                                color: advancedPayment
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            advancedPayment = false;
                          });
                        },
                        child: Container(
                          color:
                              advancedPayment ? Colors.white : AppTheme.primary,
                          alignment: Alignment.center,
                          child: Text(
                            '30%',
                            style: TextStyle(
                              color:
                                  advancedPayment ? Colors.black : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  height: screenHeight * 0.3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.03),
                        child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Pickup Address",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            )),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03),
                          height: screenHeight * 0.06,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(3)),
                          child: SizedBox(
                            height: screenHeight * 0.06,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.pickUpAddress,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.03),
                        child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Delivery Address",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18))),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03),
                          height: screenHeight * 0.06,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(3)),
                          child: SizedBox(
                            height: screenHeight * 0.06,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.finalAddress,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  )),
              SizedBox(
                height: screenHeight * 0.07,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.1),
                child: Row(
                  children: [
                    const Text(
                      "Estimated Fare",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        height: screenHeight * 0.05,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "1000",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.07,
              ),
              Center(
                child: CustomButton(
                  text: "Continue",
                  color: AppTheme.primary,
                  onPressed: () {
                    if (selectedCategoryItem == null ||
                        selectedCategoryItem!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please select a category item before continuing."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (vehicleSelectedItem == null ||
                        vehicleSelectedItem!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please select a vehicle type before continuing."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (weightController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please enter the weight before continuing."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (_dateController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please select a date before continuing."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedQuantityType.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please select a weight unit before continuing."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SummaryScreen(
                                goodsType: selectedCategoryItem!,
                                vehicleType: vehicleSelectedItem!,
                                dateOfTransportation:
                                    _dateController.text.toString().trim(),
                                startingPoint: widget.pickUpAddress,
                                destination: widget.finalAddress,
                                totalDistance: widget.distance,
                                paymentMethod: "",
                                weight: weightController.text.toString().trim(),
                                selectedQuantityType: selectedQuantityType)));
                  },
                ),
              ),
              SizedBox(
                height: screenHeight * 0.07,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(Map<String, String> item) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isSelected = item['text'] == vehicleSelectedItem;
    return GestureDetector(
      onTap: () => setState(() {
        vehicleSelectedItem = item['text'];
        isOpen = false;
      }),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        child: Row(
          children: [
            Image.asset(item['image']!,
                width: screenWidth * 0.15, height: screenHeight * 0.07),
            SizedBox(width: screenHeight * 0.05),
            Text(
              item['text']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
