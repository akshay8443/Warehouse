// import 'package:flutter/material.dart';
// import 'package:flutter_carousel_slider/carousel_slider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
//
// class DemoClass extends StatefulWidget {
//   final List<String> images;
//   const DemoClass({super.key, required this.images});
//   @override
//   DemoClassState createState() => DemoClassState();
// }
// class DemoClassState extends State<DemoClass> {
//   late CarouselSliderController _sliderController;
//   @override
//   void initState() {
//     super.initState();
//     _sliderController = CarouselSliderController();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return CarouselSlider.builder(
//       unlimitedMode: true,
//       controller: _sliderController,
//       slideBuilder: (index) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(screenWidth*0.1),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             //borderRadius: BorderRadius.circular(screenWidth*0.05),
//             child: CachedNetworkImage(
//               imageUrl: widget.images[index],
//               fit: BoxFit.fill,
//               width: double.infinity,
//               placeholder: (context, url) => Shimmer(
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(screenWidth*0.05),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 alignment: Alignment.center,
//                 padding:  EdgeInsets.all(screenWidth*0.05),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade100,
//                   borderRadius: BorderRadius.circular(3),
//                   border: Border.all(color: Colors.red.shade200, width: 2),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: Colors.red.shade700,
//                       size: 40,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Image failed to load!',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       slideTransform: const CubeTransform(),
//       itemCount: widget.images.length,
//       initialPage: 0,
//       enableAutoSlider: true,
//     );
//   }
// }
