import 'package:flutter/material.dart';

class CustomIndicator extends StatefulWidget {
  final List<Color> boxColors;
  final double rectangleWidthFactor;
  final double rectangleHeightFactor;
  final double lineWidth;
  final double lineHeightFactor;

  const CustomIndicator({
    super.key,
    required this.boxColors,
    this.rectangleWidthFactor = 0.05,
    this.rectangleHeightFactor = 0.023,
    this.lineWidth = 3,
    this.lineHeightFactor = 0.05,
  });

  @override
  State<CustomIndicator> createState() => _CustomIndicatorState();
}

class _CustomIndicatorState extends State<CustomIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxCount = widget.boxColors.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(boxCount * 2 - 1, (index) {
        if (index.isEven) {
          // Box
          return _buildAnimatedRectangle(widget.boxColors[index ~/ 2], size);
        } else {
          // Vertical line
          return _buildVerticalLine(size);
        }
      }),
    );
  }

  Widget _buildAnimatedRectangle(Color color, Size size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: size.width * widget.rectangleWidthFactor,
            height: size.height * widget.rectangleHeightFactor,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: color, width: 5),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalLine(Size size) {
    return Container(
      width: widget.lineWidth,
      height: size.height * widget.lineHeightFactor,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green, Colors.red],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
