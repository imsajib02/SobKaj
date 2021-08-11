import 'package:flutter/material.dart';
import 'package:sobkaj/models/user.dart';

abstract class LoginContract {

  void onSuccess();
  void onFailed(BuildContext context, String message);
  void onAccountNotActive(BuildContext context, String message);
}