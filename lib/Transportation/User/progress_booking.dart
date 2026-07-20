import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_loader.dart';
import 'package:Lisofy/Transportation/common/custom_app_bar/custom_progress_indicator.dart';
import 'package:Lisofy/Transportation/common/provider/loader_notifier.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressBookings extends StatefulWidget {
  const ProgressBookings({super.key});
  @override
  State<ProgressBookings> createState() => _ProgressBookingsState();
}

class _ProgressBookingsState extends State<ProgressBookings> {
  late Future<List<String>> _future;
  @override
  void initState() {
    super.initState();
    _future = fetchItems();
  }

  Future<List<String>> fetchItems() async {
    final loader = Provider.of<LoaderNotifier>(context, listen: false);
    loader.showLoader();
    await Future.delayed(const Duration(seconds: 2));
    loader.hideLoader();
    return List.generate(1, (index) => 'Item ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final loader = Provider.of<LoaderNotifier>(context);
    return Stack(
      children: [
        FutureBuilder<List<String>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CustomProgressIndicator(
                  color: AppTheme.primary,
                  size: 50,
                  text: "Please wait...",
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No items found'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.grey.shade300,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Goods Type",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "16000/-",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Middle Container - Flex 3
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, top: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.grey, width: 2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Image.asset(
                                          ImageAssets.solar,
                                          height: 40,
                                          width: 40,
                                        ),
                                      ),
                                    ),

                                    // CustomIndicator
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.02,
                                          right: screenWidth * 0.03),
                                      child: const CustomIndicator(
                                        boxColors: [
                                          Colors.green,
                                          Colors.grey,
                                          Colors.red
                                        ],
                                      ),
                                    ),

                                    // Addresses
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            truncateText(
                                              "Delhi",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            truncateText(
                                              "Start Date MM_DD_YYYY",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.03,
                                          ),
                                          Text(
                                            truncateText(
                                              "Prayer",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            truncateText(
                                              "Time",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.02,
                                          ),
                                          Text(
                                            truncateText(
                                              "Kerala",
                                              20,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            truncateText(
                                              "Delivered Date MM_DD_YYYY",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            truncateText(
                                              "Track",
                                              15,
                                            ),
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Last Container - Flex 1
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 1.5),
                            decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: double.infinity,
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                const Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.local_shipping_rounded,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Vehicle Type",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ],
                                    )),
                                Container(
                                  height: double.infinity,
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                const Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.speed_outlined,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Distance",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ],
                                    )),
                                Container(
                                  height: double.infinity,
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                const Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.date_range_sharp,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Date",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ],
                                    )),
                                Container(
                                  height: double.infinity,
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.grey.shade300,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Advance Payment- 000-",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "Balance Payment 16000/-",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const ImageIcon(
                                          AssetImage(
                                            ImageAssets.whatsapp,
                                          ),
                                          color: Colors.lightGreen,
                                        )),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        "Whatsapp",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.wifi_calling_3_sharp,
                                      color: AppTheme.primary,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: 8.0, left: 8),
                                      child: Text(
                                        "Call Now",
                                        style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        if (loader.isLoading)
          const Center(
            child: CustomProgressIndicator(
              color: AppTheme.primary,
              size: 50.0,
              text: 'Loading...',
            ),
          ),
      ],
    );
  }

  String truncateText(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length > maxWords) {
      return '${words.take(maxWords).join(' ')}...';
    }
    const maxChars = 100;
    return text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;
  }
}
