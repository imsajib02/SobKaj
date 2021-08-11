import 'package:flutter/material.dart';

class CustomShapeClass extends CustomClipper<Path> {

  @override
  getClip(Size size) {

    var path = new Path();

    path.lineTo(0, size.height / 3.2);

    var firstControlPoint = Offset(size.width / 4.2, size.height / 1.95);
    var firstEndPoint = Offset(size.width / 1.55, size.height / 5.2 + 180);
    var secondControlPoint = Offset(size.width - (size.width / 50), size.height / 3.2 + 10);
    var secondEndPoint = Offset(size.width, size.height / 2.5 + 100);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper)
  {
    return true;
  }
}