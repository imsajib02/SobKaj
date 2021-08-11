import 'package:flutter/material.dart';

abstract class SettingContract {

  void onFailed(BuildContext context);
  void onUserFound();
  void onUserNotFound();
  void onTokenExpired();
  void onAccountNotActive(BuildContext context, String message);
}