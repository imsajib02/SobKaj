import 'package:flutter/material.dart';

abstract class SignUpContract  {

  void onSignUpSuccess();
  void onSignUpFailed(BuildContext context);
  void onInvalidData(BuildContext context, String message);
}