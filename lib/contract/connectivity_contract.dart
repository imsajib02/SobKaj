import 'package:flutter/material.dart';

abstract class Connectivity {

  void onConnected(BuildContext context);
  void onDisconnected(BuildContext context);
  void onTimeout(BuildContext context);
}