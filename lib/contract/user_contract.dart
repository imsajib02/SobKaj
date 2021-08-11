import 'package:flutter/material.dart';

abstract class UserContract {

  void onUserExists(BuildContext context);
  void onUserNotFound(BuildContext context);
  void onValidateFailed(BuildContext context);
}