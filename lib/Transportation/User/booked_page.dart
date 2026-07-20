import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/User/all_bookings.dart';
import 'package:Lisofy/Transportation/User/cancelled_booking.dart';
import 'package:Lisofy/Transportation/User/progress_booking.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/cutom_app_bar.dart';
import 'package:flutter/material.dart';

class BookedPage extends StatefulWidget {
  const BookedPage({super.key});
  @override
  State<BookedPage> createState() => _BookedPageState();
}

class _BookedPageState extends State<BookedPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'All',
    'In Progress',
    'Pending',
    'Completed',
    'Cancelled'
  ];
  final List<IconData> _tabIcons = [
    Icons.list_alt,
    Icons.hourglass_top,
    Icons.pending_actions,
    Icons.check_circle,
    Icons.cancel,
  ];

  final List<Widget> _tabContent = [
    const AllBookings(),
    const ProgressBookings(),
    const Center(
        child: Text('Pending Bookings', style: TextStyle(fontSize: 18))),
    const Center(
        child: Text('Completed Bookings', style: TextStyle(fontSize: 18))),
    const CancelledBooking(),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Booking Summary",
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: screenHeight * 0.13,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    itemCount: _tabs.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: screenWidth * 0.04),
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: screenWidth * 0.4,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppTheme.primary
                                                .withValues(alpha: 0.5)
                                            : Colors.grey
                                                .withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _tabs[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -screenHeight * 0.06,
                                  left: screenWidth * 0.13,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? AppTheme.primary
                                                  .withValues(alpha: 0.8)
                                              : Colors.grey
                                                  .withValues(alpha: 0.5),
                                          blurRadius: 15,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: screenWidth * 0.08,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        _tabIcons[index],
                                        size: screenWidth * 0.08,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(child: _tabContent[_selectedTabIndex]),
            ),
          ],
        ),
      ),
    );
  }
}
