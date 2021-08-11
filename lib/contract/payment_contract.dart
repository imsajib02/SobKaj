import 'package:flutter/material.dart';
import 'package:sobkaj/models/payment.dart';

abstract class PaymentContract {

  void pay(BuildContext context);
  void onPaymentSuccess(BuildContext context);
  void onPaymentFailed(BuildContext context);
  void showAllPayout(Payouts payouts, String due);
  void onFailed(BuildContext context, String message);
}