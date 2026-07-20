import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_button.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_textfield.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController advancePaymentController =
        TextEditingController();
    final TextEditingController remainingPaymentController =
        TextEditingController();
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Payment",
          onBackPressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.07,
              top: screenHeight * 0.05,
              right: screenWidth * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                paymentLabel("Advance Payment"),
                subLabel("Minimum 30% of the payment"),
                CustomTextField(
                  hintText: "₹",
                  height: screenHeight * 0.05,
                  width: double.infinity,
                  controller: advancePaymentController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.05),
                paymentLabel("Balance Payment"),
                subLabel("Will be paid after the Delivery"),
                CustomTextField(
                  hintText: "₹",
                  height: screenHeight * 0.05,
                  width: double.infinity,
                  controller: remainingPaymentController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.1),
                Center(
                  child: CustomButton(
                    text: "Confirm",
                    color: AppTheme.primary,
                    onPressed: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>const SummaryScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget paymentLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );
  }

  Widget subLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
    );
  }
}
