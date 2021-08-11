import 'package:flutter/material.dart';
import 'package:sobkaj/models/constructor/otp.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/job_seeker.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/views/all_bids.dart';
import 'package:sobkaj/views/all_service.dart';
import 'package:sobkaj/views/bottom_nav.dart';
import 'package:sobkaj/views/complaint_issue.dart';
import 'package:sobkaj/views/create_new_password.dart';
import 'package:sobkaj/views/job_post.dart';
import 'package:sobkaj/views/job_review.dart';
import 'package:sobkaj/views/login.dart';
import 'package:sobkaj/views/job_details.dart';
import 'package:sobkaj/views/otp_verify.dart';
import 'package:sobkaj/views/reset_password.dart';
import 'package:sobkaj/views/seeker_info.dart';
import 'package:sobkaj/views/signup.dart';
import 'package:sobkaj/views/splash_screen.dart';
import 'package:sobkaj/widgets/webview_loader.dart';
import 'package:sobkaj/models/constructor/my_web_view.dart';

class RouteManager {

  static const String SPLASH_SCREEN = "splashScreen";
  static const String BOTTOM_NAVIGATION = "bottomNavigationPage";
  static const String LOGIN = "loginPage";
  static const String SIGN_UP = "signUpPage";
  static const String OTP_VERIFY = "otpVerify";
  static const String WEB_VIEW = "webView";
  static const String ALL_SERVICE = "allService";
  static const String RESET_PASSWORD = "resetPassword";
  static const String CREATE_NEW_PASSWORD = "createNewPassword";
  static const String SEEKER_INFO = "seekerInfo";
  static const String JOB_POST = "jobPost";
  static const String JOB_DETAIL = "jobDetails";
  static const String ALL_BID = "allBid";
  static const String JOB_REVIEW = "jobReview";
  static const String COMPLAINT = "complaint";

  static Route<dynamic> generate(RouteSettings settings) {

    final args = settings.arguments;

    switch(settings.name) {

      case SPLASH_SCREEN:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case BOTTOM_NAVIGATION:
        return MaterialPageRoute(builder: (_) => BottomNavigation(args as int));

      case LOGIN:
        return MaterialPageRoute(builder: (_) => Login(message: args as String));

      case SIGN_UP:
        return MaterialPageRoute(builder: (_) => SignUp());

      case OTP_VERIFY:
        return MaterialPageRoute(builder: (_) => OtpVerify(args as OTP));

      case WEB_VIEW:
        return MaterialPageRoute(builder: (_) => WebViewLoader(args as MyWebView));

      case ALL_SERVICE:
        return MaterialPageRoute(builder: (_) => AllService());

      case RESET_PASSWORD:
        return MaterialPageRoute(builder: (_) => ResetPassword());

      case CREATE_NEW_PASSWORD:
        return MaterialPageRoute(builder: (_) => CreateNewPassword(args as String));

      case SEEKER_INFO:
        return MaterialPageRoute(builder: (_) => SeekerInfo(args as User));

      case JOB_POST:
        return MaterialPageRoute(builder: (_) => JobPost(args as JobService));

      case JOB_DETAIL:
        return MaterialPageRoute(builder: (_) => JobDetails(args as Job));

      case ALL_BID:
        return MaterialPageRoute(builder: (_) => AllBid(args as Job));

      case JOB_REVIEW:
        return MaterialPageRoute(builder: (_) => JobReview(args as String));

      case COMPLAINT:
        return MaterialPageRoute(builder: (_) => ComplaintIssue(args as String));

      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Center(child: Text("Route Error")))));
    }
  }
}