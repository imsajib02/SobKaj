import 'package:flutter/material.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';

abstract class HomeContract {

  void onDataFound(Jobs jobs, JobServices services, Users seekers);
  void onFailed(BuildContext context, String message);
}