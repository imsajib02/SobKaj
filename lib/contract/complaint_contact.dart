import 'package:flutter/material.dart';
import 'package:sobkaj/models/complaint.dart';

abstract class ComplaintContract {

  void onComplaintSaved(BuildContext context, Complaint complaint);
  void onComplaintPostFailed(BuildContext context, String message);
}