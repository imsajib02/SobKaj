import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/otp_contract.dart';
import 'package:sobkaj/contract/profile_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/constructor/my_web_view.dart';
import 'package:sobkaj/models/constructor/otp.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/otp_presenter.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/utils/shared_preference.dart';
import 'package:sobkaj/widgets/app_language.dart';
import 'package:sobkaj/widgets/change_password.dart';
import 'package:sobkaj/widgets/change_phone.dart';
import 'package:sobkaj/widgets/connection_alert.dart';
import 'package:sobkaj/widgets/pick_avatar.dart';
import 'package:sobkaj/widgets/service_change.dart';
import 'package:sobkaj/widgets/update_profile.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin implements ProfileContract, OtpContract, Connectivity {

  UserPresenter _userPresenter;
  OtpPresenter _otpPresenter;

  ProfileContract _profileContract;
  OtpContract _otpContract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  MySharedPreference _preference = MySharedPreference();
  BuildContext _context;


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _profileContract = this;
    _otpContract = this;
    _connectivity = this;

    _otpPresenter = OtpPresenter(_otpContract, _connectivity);
    _userPresenter = UserPresenter(_connectivity, profileContract: _profileContract);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: <Widget>[

            SafeArea(
              child: Builder(
                builder: (BuildContext context) {

                  this._context = context;

                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Stack(
                      children: <Widget>[

                        NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowGlow();
                            return;
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[

                                Opacity(
                                  opacity: 0,
                                  child: Material(
                                    elevation: 5,
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                                    child: ValueListenableBuilder(
                                      valueListenable: currentUser,
                                      builder: (BuildContext context, User user, _) {

                                        return Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[

                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[

                                                  Flexible(
                                                    flex: 2,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {

                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {

                                                              return PickAvatar(
                                                                onSubmit: (file) {

                                                                  if(file != null && file.path != null && file.path.isNotEmpty) {

                                                                    _userPresenter.updateAvatar(_context, file);
                                                                  }
                                                                },
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: ClipOval(
                                                        child: CachedNetworkImage(
                                                          imageUrl: user.avatar,
                                                          height: 55,
                                                          width: 55,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context, url) => CircularProgressIndicator(),
                                                          errorWidget: (context, url, error) => Icon(Icons.account_circle,
                                                            size: 55,
                                                            color: Colors.black26,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  Flexible(
                                                    flex: 6,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 20),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                        children: <Widget>[

                                                          Text(user.name,
                                                            style: Theme.of(context).textTheme.headline5,
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.only(top: 5),
                                                            child: Text(user.phone,
                                                              style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black45),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  Flexible(
                                                    flex: 1,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {

                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {

                                                              return UpdateProfile(
                                                                onSubmit: (user) {

                                                                  _userPresenter.updateProfile(_context, user);
                                                                },
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xff0D4F8B),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 16,),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 20,),

                                              Padding(
                                                padding: EdgeInsets.only(left: 17),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.event, size: 22, color: Colors.grey[600]),

                                                    Padding(
                                                      padding: EdgeInsets.only(left: 15),
                                                      child: Text(MyDateTime.getMonthData(DateTime.parse(user.birthDate)),
                                                        style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Visibility(
                                                visible: user != null && user.email != null && user.email.isNotEmpty,
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 17, top: 10),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[

                                                      Icon(Icons.email, size: 22, color: Colors.grey[600]),

                                                      Padding(
                                                        padding: EdgeInsets.only(left: 15),
                                                        child: Text(user.email,
                                                          style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w600),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Visibility(
                                                visible: user != null && user.address != null && user.address.isNotEmpty,
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 17, top: 10),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[

                                                      Icon(Icons.location_on, size: 22, color: Colors.grey[600],),

                                                      Flexible(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 15),
                                                          child: Text(user.address,
                                                            style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 25,),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    showDialog(
                                        context: context,
                                        builder: (context) {

                                          return ChangePhone(
                                            onSubmit: (user) {

                                              _otpPresenter.sendOTP(_context, user, Constants.NEW_PHONE_VERIFY);
                                            },
                                          );
                                        }
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.phone, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("change_phone"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    showDialog(
                                      context: context,
                                      builder: (context) {

                                        return ChangePassword(
                                          onSubmit: (user) {

                                            _userPresenter.changePassword(_context, user);
                                          },
                                        );
                                      }
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.lock, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("change_password"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible: currentUser.value.roleID == Constants.SEEKER,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {

                                      showDialog(
                                          context: context,
                                          builder: (context) {

                                            return ChangeService(
                                              onSubmit: (List<JobService> services) {

                                                _userPresenter.updateServices(_context, services);
                                              },
                                            );
                                          }
                                      );
                                    },
                                    child: ListTile(
                                      contentPadding: EdgeInsets.only(left: 30),
                                      leading: Container(
                                        height: 30,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.indigo,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.view_list, color: Theme.of(context).accentColor, size: 16,),
                                      ),
                                      title: Text(AppLocalization.of(context).getTranslatedValue("my_services"),
                                        style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ),
                                ),

                                ListTile(
                                  contentPadding: EdgeInsets.only(left: 40),
                                  leading: Text(AppLocalization.of(context).getTranslatedValue("app_preference"),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.howItWorks,
                                        title: AppLocalization.of(context).getTranslatedValue("how_it_works"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.indigo,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.help, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("how_it_works"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.helpSupport,
                                        title: AppLocalization.of(context).getTranslatedValue("help_support"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.help, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("help_support"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.termsConditionsUrl,
                                        title: AppLocalization.of(context).getTranslatedValue("terms_condition"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.library_books, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("terms_condition"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.privacyPolicyUrl,
                                        title: AppLocalization.of(context).getTranslatedValue("privacy_policy"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.security, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("privacy_policy"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.faq,
                                        title: AppLocalization.of(context).getTranslatedValue("faqs"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.help, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("faqs"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.aboutUs,
                                        title: AppLocalization.of(context).getTranslatedValue("about_us"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withOpacity(.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.help, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("about_us"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    MyWebView view = MyWebView(url: settings.value.contactUs,
                                        title: AppLocalization.of(context).getTranslatedValue("contact_us"));

                                    Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.lightGreen,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.help, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("contact_us"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    showDialog(
                                        context: context,
                                        builder: (context) {

                                          return AppLanguage();
                                        }
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.cyan,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.translate, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("language"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {

                                    _logOut();
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 30),
                                    leading: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.exit_to_app, color: Theme.of(context).accentColor, size: 16,),
                                    ),
                                    title: Text(AppLocalization.of(context).getTranslatedValue("logout"),
                                      style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        Material(
                          elevation: 5,
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                          child: ValueListenableBuilder(
                            valueListenable: currentUser,
                            builder: (BuildContext context, User user, _) {

                              return Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[

                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Flexible(
                                          flex: 2,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {

                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {

                                                    return PickAvatar(
                                                      onSubmit: (file) {

                                                        if(file != null && file.path != null && file.path.isNotEmpty) {

                                                          _userPresenter.updateAvatar(_context, file);
                                                        }
                                                      },
                                                    );
                                                  }
                                              );
                                            },
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: user.avatar,
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => Icon(Icons.account_circle,
                                                  size: 60,
                                                  color: Colors.black26,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Flexible(
                                          flex: 6,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: <Widget>[

                                                Text(user.name,
                                                  style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.normal),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(top: 4),
                                                  child: Text(user.phone,
                                                    style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black45),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Flexible(
                                          flex: 1,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {

                                                    return UpdateProfile(
                                                      onSubmit: (user) {

                                                        _userPresenter.updateProfile(_context, user);
                                                      },
                                                    );
                                                  }
                                              );
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Color(0xff0D4F8B),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.edit, color: Theme.of(context).accentColor, size: 16,),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20,),

                                    Padding(
                                      padding: EdgeInsets.only(left: 17),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[

                                          Icon(Icons.event, size: 22, color: Colors.grey[500]),

                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Text(MyDateTime.getMonthData(DateTime.parse(user.birthDate)),
                                              style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Visibility(
                                      visible: user != null && user.email != null && user.email.isNotEmpty,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 17, top: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[

                                            Icon(Icons.email, size: 22, color: Colors.grey[500]),

                                            Padding(
                                              padding: EdgeInsets.only(left: 15),
                                              child: Text(user.email,
                                                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: user != null && user.address != null && user.address.isNotEmpty,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 17, top: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[

                                            Icon(Icons.location_on, size: 22, color: Colors.grey[500],),

                                            Flexible(
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 15),
                                                child: Text(user.address,
                                                  style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            _connectionAlert.onDisconnected(context),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {

    _connectivityChecker.removeStatusListener();
    _connectionAlert.controller.dispose();
    super.dispose();
  }


  @override
  void onConnected(BuildContext context) {

    try {

      if(_connectionAlert != null && _connectionAlert.controller.isCompleted) {

        _connectionAlert.controller.reverse();
      }
    }
    catch(error) {}
  }


  @override
  void onDisconnected(BuildContext context) {

    try {

      if(_connectionAlert != null && !_connectionAlert.controller.isCompleted) {

        _connectionAlert.controller.forward();

        Timer(Duration(milliseconds: 3500), () {

          _connectionAlert.controller.reverse();
        });
      }
    }
    catch(error) {}
  }


  @override
  void onTimeout(BuildContext context) {

    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).getTranslatedValue("connection_time_out"),
          ),
    ));
  }
  

  @override
  void onError(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  Future<void> _logOut() async {

    await _preference.remove(MySharedPreference.LOGGED_USER);
    await _preference.remove(MySharedPreference.LOGIN_TIME);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.LOGIN);
  }


  @override
  void onFailed(BuildContext context, String message) {}


  @override
  void onInvalidOtp(BuildContext context) {}


  @override
  Future<void> onNewPhoneVerifyOtpSent(User user) async {

    OTP otp = OTP(user: user, type: Constants.NEW_PHONE_VERIFY);

    final result = await Navigator.of(context).pushNamed(RouteManager.OTP_VERIFY, arguments: otp);

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result")));
  }


  @override
  void onOtpVerified(BuildContext context, OverlayEntry loader) {}


  @override
  void onPhoneVerifyOtpSent() {}


  @override
  void onSignUpOtpSent() {}


  @override
  void onPhoneNumberTaken(BuildContext context) {}


  @override
  void onSuccess(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onResetPasswordOtpSent() {}
}