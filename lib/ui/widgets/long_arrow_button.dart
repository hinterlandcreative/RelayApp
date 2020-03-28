import 'dart:ui';

import 'package:flutter/material.dart';

class LongArrowButton extends StatelessWidget {
  final Function() onTap;
  const LongArrowButton({
    Key key, 
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width / 3, 20.0),
        painter: _Arrow()),
    );
  }
}

class _Arrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = PointMode.polygon;
    final arrowBack = size.height / 2.5;
    final arrowHeadPoints = [
      Offset(size.width - arrowBack, 0),
      Offset(size.width, size.height / 2),
      Offset(size.width - arrowBack, size.height)
    ];

    final linePoints = [
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2)
    ];

    final paint = Paint()
      ..color = Colors.white
      .. strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPoints(pointMode, arrowHeadPoints, paint);
    canvas.drawPoints(pointMode, linePoints, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}