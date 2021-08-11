import 'package:flutter/material.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/payment.dart';

abstract class JobContract {

  void onJobPosted(BuildContext context, Job job);
  void onPostFailed(BuildContext context);
  void onJobUpdated(BuildContext context, Job job);
  void onUpdateFailed(BuildContext context, String message);
  void onFailedToGetJobs(BuildContext context, String message);
  void showJobList(List<Job> jobs);
  void onPaymentConfirm(BuildContext context, Payment payment);
  void onPaymentConfirmFailed(BuildContext context, String message);
}