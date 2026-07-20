import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
class WarehouseItemDesign extends StatefulWidget {
  const WarehouseItemDesign({super.key});
  @override
  State<WarehouseItemDesign> createState() => _WarehouseItemDesignState();
}
class _WarehouseItemDesignState extends State<WarehouseItemDesign> {
  bool light = true;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(top: screenHeight * 0.01, left: 10),
                padding: const EdgeInsets.all(15),
                child: DottedBorder(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text(
                              "Lokandbala",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Image.asset("assets/images/Share.png"),
                            const SizedBox(
                              width: 15,
                            ),
                            Image.asset("assets/images/QrCode.png"),
                            const SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              ". Vacant",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                  fontSize: 10),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "  | WHNOW-UP-GAU-27142",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "13 sq.ft",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15),
                            ),
                            SizedBox(width: screenWidth * 0.4),
                            const Text(
                              "₹ 5.00",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15),
                            ),
                            SizedBox(width: screenWidth * 0.1)
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Carpet Area (Sq.ft)",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                  fontSize: 10),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "  | Rent per Sq.ft / Month",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 10),
                            ),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                flex: 4,
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF0F4FD),
                                      border: Border.all(color:  const Color(0xffF0F4FD))),
                                  child: const Center(child: Text("View Request  | 0",style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.w400),)),
                                )),
                            const SizedBox(width: 5),
                            Flexible(
                                flex: 3,
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color:  const Color(0xffF0F4FD),
                                      border: Border.all(color:  const Color(0xffF0F4FD))),
                                    child: const Center(child: Text("Bids  | 0",style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.w400),))
                                )),
                            const SizedBox(width: 5),
                            Flexible(
                                flex: 4,
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color:  const Color(0xffF0F4FD),
                                      border: Border.all(color:  const Color(0xffF0F4FD))),
                                    child: const Center(child: Text("Contracts  | 0",style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.w400),))
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Is warehouse available?"),
                          Row(
                            children: [
                              const Text("No",style: TextStyle(color: Colors.grey,fontSize: 11,fontWeight: FontWeight.w500),),
                              Switch(
                                value: light,
                                activeColor: Colors.white,
                                dragStartBehavior: DragStartBehavior.start,
                                activeTrackColor: const Color(0xff48A103),
                                onChanged: (bool value) {
                                  setState(() {
                                    light = value;
                                  });
                                },
                              ),
                              const Text("Yes",style: TextStyle(fontSize: 11,color: Colors.grey,fontWeight: FontWeight.w500),),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 3.0,left: 30),
              child: Text("Messenger"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0,left: 20,right: 20),
              child: Container(
                height: screenHeight*0.13,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: child,
    );
  }
}
class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double startX = 0;

    Path().addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw dotted border
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.height) {
      canvas.drawLine(
        Offset(size.width, startX),
        Offset(size.width, startX + dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.width) {
      canvas.drawLine(
        Offset(size.width - startX, size.height),
        Offset(size.width - startX - dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // Reset startX for the next side
    while (startX < size.height) {
      canvas.drawLine(
        Offset(0, size.height - startX),
        Offset(0, size.height - startX - dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




