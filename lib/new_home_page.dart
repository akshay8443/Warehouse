import 'dart:async';
import 'package:Lisofy/Animation/glitter_border.dart';
import 'package:Lisofy/Transportation/User/booking_page.dart';
import 'package:Lisofy/Warehouse/User/customPainter/custom_dailog.dart';
import 'package:Lisofy/Warehouse/User/partner_chooser_screen.dart';
import 'package:Lisofy/Warehouse/User/user_home_page.dart';
import 'package:Lisofy/Warehouse/User/user_profile_screen.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NewHomePage extends StatefulWidget {
  final dynamic longitude;
  final dynamic latitude;
  const NewHomePage(
      {super.key, required this.latitude, required this.longitude});
  @override
  State<NewHomePage> createState() => NewHomePageState();
}

class NewHomePageState extends State<NewHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  int _currentIndex = 0;
  int _transportIndex = 0;
  int _manpowerIndex = 0;
  int _agricultureIndex = 0;
  int sliderControllerIndex = 0;
  final List<String> _warehouseImages = [
    'assets/images/slider1.png',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
  ];
  final List<String> _transportImages = [
    'assets/images/transportgif.gif',
    'assets/images/truck.png',
  ];
  final List<String> _manPowerImages = [
    'assets/images/manpowergif.gif',
    'assets/images/manpower.png',
  ];
  final List<String> _advertisingImages = [
    'assets/images/ads.png',
    'assets/images/secondAds.png',
  ];
  final List<String> _agriculturalImages = [
    'assets/images/agriculturalgif.gif',
    'assets/images/agricultural.png',
  ];
  // final List<String> _demoImages = [w
  //  'https://xpacesphere.com/Content/NewFolder/warehouse_23.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_20.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_18.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_19.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_14.jpg'
  // ];

  late PageController _pageControllerSlider;
  late PageController _transportController;
  late PageController _manpowerController;
  late PageController _agricultureController;
  late PageController _advertisingController;
  final List<Timer> _autoSlideTimers = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  bool isSortApplied = false;
  bool isNearbyEnabled = false;
  bool isPriceEnabled = false;
  bool isPriceEnabledmaxtomin = false;
  bool isAreaMinToMax = false;
  bool isAreaMaxToMin = false;

  @override
  void initState() {
    super.initState();
    _pageControllerSlider = PageController(initialPage: _currentIndex);
    _transportController = PageController(initialPage: _transportIndex);
    _manpowerController = PageController(initialPage: _manpowerIndex);
    _agricultureController = PageController(initialPage: _agricultureIndex);
    _advertisingController = PageController(initialPage: sliderControllerIndex);
    _startAutoSlide(_pageControllerSlider, () {
      if (_currentIndex < _warehouseImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      return _currentIndex;
    }, 3, const Duration(milliseconds: 3000), Curves.easeInOutCubicEmphasized);
    _startAutoSlide(_transportController, () {
      if (_transportIndex < _transportImages.length - 1) {
        _transportIndex++;
      } else {
        _transportIndex = 0;
      }
      return _transportIndex;
    }, 4, const Duration(milliseconds: 200), Curves.slowMiddle);
    _startAutoSlide(_manpowerController, () {
      if (_manpowerIndex < _manPowerImages.length - 1) {
        _manpowerIndex++;
      } else {
        _manpowerIndex = 0;
      }
      return _manpowerIndex;
    }, 5, const Duration(milliseconds: 400), Curves.slowMiddle);

    _startAutoSlide(_agricultureController, () {
      if (_agricultureIndex < _agriculturalImages.length - 1) {
        _agricultureIndex++;
      } else {
        _agricultureIndex = 0;
      }
      return _agricultureIndex;
    }, 4, const Duration(milliseconds: 3000), Curves.easeInOutCubicEmphasized);

    _startAutoSlide(_advertisingController, () {
      if (sliderControllerIndex < _advertisingImages.length - 1) {
        sliderControllerIndex++;
      } else {
        sliderControllerIndex = 0;
      }
      return sliderControllerIndex;
    }, 3, const Duration(milliseconds: 2000), Curves.easeOut);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _startAutoSlide(
    PageController controller,
    int Function() onNext,
    int seconds,
    Duration duration,
    Curve curve,
  ) {
    final timer = Timer.periodic(Duration(seconds: seconds), (Timer timer) {
      if (!mounted || !controller.hasClients) {
        timer.cancel();
        return;
      }
      final nextPage = onNext();
      controller.animateToPage(
        nextPage,
        duration: duration,
        curve: curve,
      );
    });
    _autoSlideTimers.add(timer);
  }

  @override
  void dispose() {
    for (final timer in _autoSlideTimers) {
      timer.cancel();
    }
    _controller.dispose();
    _pageController.dispose();
    _pageControllerSlider.dispose();
    _transportController.dispose();
    _manpowerController.dispose();
    _agricultureController.dispose();
    _advertisingController.dispose();
    super.dispose();
  }

  List<String> horizontalSliderImages = [
    'assets/images/demoimage1.png',
    'assets/images/demoimage2.png',
    'assets/images/demoimage3.png',
    'assets/images/warehousegif.gif',
    'assets/images/noWarehouseBanner.png',
  ];
  int horizontalSliderImagesIndex = 0;
  void _shiftImagesLeft() {
    if (horizontalSliderImagesIndex + 3 < horizontalSliderImages.length) {
      setState(() {
        horizontalSliderImagesIndex++;
      });
    }
  }

  Widget _buildPromoImage(String source, BoxFit fit, double screenHeight) {
    final isNetworkImage =
        source.startsWith('http://') || source.startsWith('https://');

    if (!isNetworkImage) {
      return Image.asset(
        source,
        fit: fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          ImageAssets.defaultImage,
          fit: fit,
          width: double.infinity,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      width: double.infinity,
      placeholder: (context, url) => Shimmer(
        child: Container(
          width: double.infinity,
          height: screenHeight * 0.05,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        ImageAssets.defaultImage,
        fit: fit,
        width: double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: [
                    _buildHomePage(screenWidth, screenHeight),
                    // _userShortListedIntrestedPage(screenWidth, screenHeight),
                    _buildAccountPage(screenWidth, screenHeight),
                  ],
                ),
              ),
              Container(
                color: AppTheme.primary,
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.home_filled),
                            color: _selectedIndex == 0
                                ? Colors.white
                                : Colors.grey[300],
                            onPressed: () => _onItemTapped(0),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: ImageIcon(
                              _selectedIndex == 2
                                  ? const AssetImage("assets/images/Gear2.png")
                                  : const AssetImage('assets/images/Gear.png'),
                              color: _selectedIndex == 2
                                  ? Colors.white
                                  : Colors.grey[300],
                            ),
                            onPressed: () => _onItemTapped(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildHomePage(double screenWidth, double screenHeight) {
    return Container(
      color: AppTheme.primary,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              height: screenHeight * 0.1,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.015,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: Image.asset(ImageAssets.appLogo),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: screenWidth * 0.04, top: screenHeight * 0.02),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  painter:
                                      GlitterBorderPainter(_animation.value),
                                  child: SizedBox(
                                    width: screenWidth * 0.32,
                                    height: screenHeight * 0.037,
                                    child: TextButton(
                                      onPressed: () async {
                                        ///WarehousePartner
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PartnerChooserScreen()));
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: const BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                      ),
                                      child: Animate(
                                          effects: const [
                                            FadeEffect(),
                                            ScaleEffect()
                                          ],
                                          child: Text(
                                            S.of(context).became_partner,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppTheme.primary,
                                            ),
                                          )
                                              .animate(
                                                delay: 500.ms,
                                                onPlay: (controller) =>
                                                    controller.repeat(),
                                              )
                                              .tint(color: Colors.purple)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: screenWidth * 0.00),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(0),
                    topRight: Radius.circular(screenWidth * 0.15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserHomePage(
                                                longitude: widget.longitude,
                                                latitude: widget.latitude)));
                                  },
                                  child: Container(
                                    height: screenHeight * 0.15,
                                    width: screenWidth * 0.33,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.05),
                                      color: AppTheme.primarySoft,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.3),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          ImageAssets.warehousegif,
                                          height: screenHeight * 0.08,
                                          width: screenWidth * 0.25,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          S.of(context).warehousing,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Container(
                                  height: screenHeight * 0.15,
                                  width: screenWidth * 0.33,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.05),
                                    color: AppTheme.primarySoft,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.6),
                                        spreadRadius: 5,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      ///Transport Page Navigation to Partner
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BookingScreen()));
                                      // showCustomDialog(
                                      //     context,
                                      //     'Transportation',
                                      //     '. Get ready for Effortless Truck Booking at your FingerTips!',
                                      //     '. Easy fast and Reliable Transport just for you.',
                                      //     '. No more Hassles Seamlessly Book Track and manage Shipment'
                                      // );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          ImageAssets.transportgif,
                                          height: screenHeight * 0.08,
                                          width: screenWidth * 0.25,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          S.of(context).transportation,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: screenHeight * 0.15,
                                    width: screenWidth * 0.33,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.05),
                                      color: AppTheme.primarySoft,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.3),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        showCustomDialog(
                                            context,
                                            'Manpower',
                                            '. Your trusted partner in Land Transactions simplified and secure!',
                                            '. Buy and sell land with confidence, Transparency and ease',
                                            '. Seamless transaction and Expert Guidance at every step.');
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            ImageAssets.manpowergif,
                                            height: screenHeight * 0.08,
                                            width: screenWidth * 0.25,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            S.of(context).manpower,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: screenHeight * 0.15,
                                    width: screenWidth * 0.33,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.05),
                                      color: AppTheme.primarySoft,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.3),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        showCustomDialog(
                                            context,
                                            'Agriculture',
                                            '. Your trusted partner in Land Transactions Simplified and secure',
                                            '. Buy and sell Land with confidence Transparency and Ease.',
                                            '. Seamless Transactions and Expert Guidance at Every step');
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            ImageAssets.agriculturalgif,
                                            height: screenHeight * 0.08,
                                            width: screenWidth * 0.25,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            S.of(context).agricultural,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900),
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
                        SizedBox(
                          height: screenHeight * 0.025,
                        ),

                        ///Warehouse Slider
                        SizedBox(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.9,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserHomePage(
                                              longitude: widget.longitude,
                                              latitude: widget.latitude)));
                                },
                                child: PageView.builder(
                                  controller: _pageControllerSlider,
                                  itemCount: _warehouseImages.length,
                                  onPageChanged: (int index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: _buildPromoImage(
                                        _warehouseImages[index],
                                        BoxFit.cover,
                                        screenHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.017,
                        ),

                        ///Transportation Slider
                        SizedBox(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.9,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  showCustomDialog(
                                      context,
                                      'Transportation',
                                      '. Get ready for Effortless Truck Booking at your FingerTips!',
                                      '. Easy fast and Reliable Transport just for you.',
                                      '. No more Hassles Seamlessly Book Track and manage Shipment');
                                },
                                child: PageView.builder(
                                  controller: _transportController,
                                  itemCount: _transportImages.length,
                                  onPageChanged: (int index) {
                                    setState(() {
                                      _transportIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: _buildPromoImage(
                                        _transportImages[index],
                                        BoxFit.cover,
                                        screenHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),

                        ///Horizontal Slider
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.003),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                for (int i = 0; i < 3; i++)
                                  if (horizontalSliderImagesIndex + i <
                                      horizontalSliderImages.length)
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: _buildPromoImage(
                                                horizontalSliderImages[
                                                    horizontalSliderImagesIndex +
                                                        i],
                                                BoxFit.cover,
                                                screenHeight,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                SizedBox(
                                  width: screenWidth * 0.1,
                                  child: Center(
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 20),
                                      onPressed: _shiftImagesLeft,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),

                        ///Manpower Slider
                        SizedBox(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.9,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  showCustomDialog(
                                      context,
                                      'Manpower',
                                      '. Your trusted partner in Land Transactions simplified and secure!',
                                      '. Buy and sell land with confidence, Transparency and ease',
                                      '. Seamless transaction and Expert Guidance at every step.');
                                },
                                child: PageView.builder(
                                  controller: _manpowerController,
                                  itemCount: _manPowerImages.length,
                                  onPageChanged: (int index) {
                                    setState(() {
                                      _manpowerIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: _buildPromoImage(
                                        _manPowerImages[index],
                                        BoxFit.cover,
                                        screenHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),

                        ///Agriculture Slider
                        SizedBox(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.9,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  showCustomDialog(
                                      context,
                                      'Agriculture',
                                      '. Your trusted partner in Land Transactions Simplified and secure',
                                      '. Buy and sell Land with confidence Transparency and Ease.',
                                      '. Seamless Transactions and Expert Guidance at Every step');
                                },
                                child: PageView.builder(
                                  controller: _agricultureController,
                                  itemCount: _agriculturalImages.length,
                                  onPageChanged: (int index) {
                                    setState(() {
                                      _agricultureIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: _buildPromoImage(
                                        _agriculturalImages[index],
                                        BoxFit.cover,
                                        screenHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),

                        ///Advertising Slider
                        SizedBox(
                          height: screenHeight * 0.18,
                          width: screenWidth * 0.9,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  showCustomDialog(
                                      context,
                                      'Agriculture',
                                      '. Your trusted partner in Land Transactions Simplified and secure',
                                      '. Buy and sell Land with confidence Transparency and Ease.',
                                      '. Seamless Transactions and Expert Guidance at Every step');
                                },
                                child: PageView.builder(
                                  controller: _advertisingController,
                                  itemCount: _advertisingImages.length,
                                  onPageChanged: (int index) {
                                    setState(() {
                                      sliderControllerIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: _buildPromoImage(
                                        _advertisingImages[index],
                                        BoxFit.cover,
                                        screenHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: screenHeight*0.02,),
                        // SizedBox(
                        //     height: screenHeight*0.25,
                        //     child: DemoClass(images: _demoImages))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) {
    return const UserProfileScreen();
  }
  // void showAdvancedFiltersBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //       return const AdvancedFiltersBottomSheet();
  //     },
  //   );
  // }
}
