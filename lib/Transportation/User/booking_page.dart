import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/User/booked_page.dart';
import 'package:Lisofy/Transportation/User/provider/booking_provider.dart';
import 'package:Lisofy/Transportation/User/transport_page_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingScreenProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final pages = [
      const TransportPageHome(),
      _buildPage("Settings Page", Colors.greenAccent),
      const BookedPage(),
    ];
    return Scaffold(
      body: PageView(
        controller: bookingProvider.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: screenHeight * 0.09,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.007),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: screenWidth * 0.03),
                    _buildNavItem(Icons.home_filled, 0, bookingProvider),
                    const Spacer(),
                    _buildNavItem(
                        Icons.local_shipping_outlined, 2, bookingProvider),
                    SizedBox(width: screenWidth * 0.03),
                  ],
                ),
              ),
              Positioned(
                top: -screenHeight * 0.025,
                child: InkWell(
                  onTap: () => bookingProvider.setIndex(1),
                  child: Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      color: bookingProvider.selectedIndex == 1
                          ? Colors.white
                          : Colors.grey,
                    ),
                    child: Icon(
                      Icons.settings,
                      color: bookingProvider.selectedIndex == 1
                          ? AppTheme.primary
                          : Colors.white,
                      size: screenHeight * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(String text, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, int index, BookingScreenProvider provider) {
    return IconButton(
      icon: Icon(
        icon,
        color: provider.selectedIndex == index ? AppTheme.primary : Colors.grey,
        size: 35,
      ),
      onPressed: () => provider.setIndex(index),
    );
  }
}
