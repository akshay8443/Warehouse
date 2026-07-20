import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/User/payment_screen.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_button.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final String goodsType;
  final String vehicleType;
  final String dateOfTransportation;
  final String startingPoint;
  final String destination;
  final String totalDistance;
  final String paymentMethod;
  final String weight;
  final String selectedQuantityType;

  const SummaryScreen({
    super.key,
    required this.goodsType,
    required this.vehicleType,
    required this.dateOfTransportation,
    required this.startingPoint,
    required this.destination,
    required this.totalDistance,
    required this.paymentMethod,
    required this.weight,
    required this.selectedQuantityType,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Summary",
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.07, vertical: screenHeight * 0.02),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summaryRow("Goods Type", goodsType),
                      summaryRow("Vehicle Type", vehicleType),
                      summaryRow(
                          "Date of Transportation", dateOfTransportation),
                      summaryRowScrollable("Starting point", startingPoint),
                      summaryRowScrollable("Destination", destination),
                      summaryRow("Total Distance", "$totalDistance Km"),
                      summaryRow("Weight", "$weight $selectedQuantityType"),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.07,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Estimated Fare",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹ 16000-18000",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomButton(
                  text: "Confirm",
                  color: AppTheme.primary,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentScreen()));
                  },
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget summaryRowScrollable(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Divider(thickness: 2),
      ],
    );
  }
}
