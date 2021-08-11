import 'dart:ui';
import 'package:flutter/material.dart';

class MyOverlayLoader {

  OverlayEntry loader;

  MyOverlayLoader(BuildContext context) {

    this.loader = OverlayEntry(builder: (context) {

      return Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 7,
          ),
        ),
      );
    });
  }
}