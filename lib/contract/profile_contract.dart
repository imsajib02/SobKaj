import 'package:flutter/material.dart';

abstract class ProfileContract {

  void onError(BuildContext context, String message);
  void onPhoneNumberTaken(BuildContext context);
  void onSuccess(BuildContext context, String message);
}