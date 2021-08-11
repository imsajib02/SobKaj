import 'package:flutter/material.dart';
import 'package:sobkaj/models/user.dart';

abstract class OtpContract {

  void onInvalidOtp(BuildContext context);
  void onOtpVerified(BuildContext context, OverlayEntry loader);
  void onSignUpOtpSent();
  void onPhoneVerifyOtpSent();
  void onResetPasswordOtpSent();
  void onNewPhoneVerifyOtpSent(User user);
  void onFailed(BuildContext context, String message);
}