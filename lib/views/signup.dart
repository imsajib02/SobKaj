import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/otp_contract.dart';
import 'package:sobkaj/contract/user_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/models/constructor/my_web_view.dart';
import 'package:sobkaj/models/constructor/otp.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sobkaj/presenter/otp_presenter.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/theme/apptheme_notifier.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class SignUp extends StatefulWidget {

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin implements OtpContract, UserContract, Connectivity {

  OtpPresenter _otpPresenter;
  UserPresenter _userPresenter;

  OtpContract _otpContract;
  UserContract _userContract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  List<bool> _userTypeCheck = [false, false];
  List<bool> _providerType = [false, false];
  List<bool> _userGender = [false, false, false];
  List<bool> _serviceCheck = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _attachmentController = TextEditingController();
  TextEditingController _cvController = TextEditingController();

  bool _toggle = true;
  bool _isValid = false;

  FocusNode _nameNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _phoneNode = FocusNode();
  FocusNode _passwordNode = FocusNode();

  final _bounceKey = GlobalKey<BounceState>();
  final _formKey = GlobalKey<FormState>();

  File _attachment;
  File _cvAttachment;

  User _user = User(services: JobServices(list: List()));


  @override
  void initState() {

    _serviceCheck = List.filled(settings.value.services.list.length, false);

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _otpContract = this;
    _userContract = this;
    _connectivity = this;

    _otpPresenter = OtpPresenter(_otpContract, _connectivity);
    _userPresenter = UserPresenter(_connectivity, userContract: _userContract);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {

        return Future(() => true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            if(_attachmentController.text.isEmpty) {

              _attachmentController.text = AppLocalization.of(context).getTranslatedValue("optional");
            }

            if(_cvController.text.isEmpty) {

              _cvController.text = AppLocalization.of(context).getTranslatedValue("optional");
            }

            return Stack(
              children: <Widget>[

                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 25, bottom: 30, left: 35, right: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[

                            Text(AppLocalization.of(context).getTranslatedValue("register"),
                              style: Theme.of(context).textTheme.headline2,
                            ),

                            SizedBox(height: 25,),

                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(width: 1, color: Colors.black54)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Checkbox(
                                          activeColor: Colors.blueAccent,
                                          checkColor: Colors.white,
                                          value: _userTypeCheck[0],
                                          onChanged: (value) {

                                            _setUserType(0);
                                            _user.roleID = Constants.PROVIDER;
                                            _user.providingJobAs = null;
                                          },
                                        ),

                                        Text(AppLocalization.of(context).getTranslatedValue("job_provider"),
                                          style: Theme.of(context).textTheme.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(width: 20,),

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(width: 1, color: Colors.black54)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Checkbox(
                                          activeColor: Colors.blueAccent,
                                          checkColor: Colors.white,
                                          value: _userTypeCheck[1],
                                          onChanged: (value) {

                                            _setUserType(1);
                                            _user.roleID = Constants.SEEKER;
                                            _user.providingJobAs = Constants.NONE;
                                          },
                                        ),

                                        Text(AppLocalization.of(context).getTranslatedValue("job_seeker"),
                                          style: Theme.of(context).textTheme.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 30, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("name"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode: _nameNode,
                              onFieldSubmitted: (string) {
                                FocusScope.of(context).unfocus();
                              },
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }
                                else if(value.length < 3) {
                                  return AppLocalization.of(context).getTranslatedValue("invalid_name");
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                fillColor: Colors.white70,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("gender"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[

                                      Checkbox(
                                        activeColor: Colors.blueAccent,
                                        checkColor: Colors.white,
                                        value: _userGender[0],
                                        onChanged: (value) {

                                          _setGenderType(0);
                                          _user.gender = Constants.MALE;
                                        },
                                      ),

                                      Text(AppLocalization.of(context).getTranslatedValue("male"),
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 10,),

                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[

                                      Checkbox(
                                        activeColor: Colors.blueAccent,
                                        checkColor: Colors.white,
                                        value: _userGender[1],
                                        onChanged: (value) {

                                          _setGenderType(1);
                                          _user.gender = Constants.FEMALE;
                                        },
                                      ),

                                      Text(AppLocalization.of(context).getTranslatedValue("female"),
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 10,),

                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[

                                      Checkbox(
                                        activeColor: Colors.blueAccent,
                                        checkColor: Colors.white,
                                        value: _userGender[2],
                                        onChanged: (value) {

                                          _setGenderType(2);
                                          _user.gender = Constants.OTHER;
                                        },
                                      ),

                                      Text(AppLocalization.of(context).getTranslatedValue("other"),
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("birthdate"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {

                                _selectDate(context);
                              },
                              child: TextFormField(
                                controller: _dateController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                enabled: false,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.date_range, color: Colors.transparent,),
                                  suffixIcon: Icon(Icons.date_range, color: Colors.grey[600],),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                  fillColor: Colors.white70,
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("email") + " (" +
                                  AppLocalization.of(context).getTranslatedValue("optional") + ")",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusNode: _emailNode,
                              onFieldSubmitted: (string) {
                                _phoneNode.requestFocus();
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                fillColor: Colors.white70,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("phone"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              focusNode: _phoneNode,
                              onFieldSubmitted: (string) {
                                _passwordNode.requestFocus();
                              },
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }
                                else if(value.length != 11) {
                                  return AppLocalization.of(context).getTranslatedValue("invalid_phone");
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                prefixStyle: Theme.of(context).textTheme.subtitle2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                fillColor: Colors.white70,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("password"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _toggle,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              focusNode: _passwordNode,
                              onFieldSubmitted: (string) {
                                FocusScope.of(context).unfocus();
                              },
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }
                                else if(value.length < 8) {
                                  return AppLocalization.of(context).getTranslatedValue("must_be_8_char");
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(icon: Icon(_toggle ? Icons.visibility : Icons.visibility_off),
                                    color: Colors.lightBlueAccent,
                                    onPressed: () {

                                      setState(() {
                                        _toggle = !_toggle;
                                      });
                                    }),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                fillColor: Colors.white70,
                              ),
                            ),

                            Visibility(
                              visible: _userTypeCheck[0],
                              child: Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 15, left: 5),
                                child: Text(AppLocalization.of(context).getTranslatedValue("providing_job_as"),
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _userTypeCheck[0],
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[

                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Checkbox(
                                          activeColor: Colors.blueAccent,
                                          checkColor: Colors.white,
                                          value: _providerType[0],
                                          onChanged: (value) {

                                            _setProviderType(0);
                                            _user.providingJobAs = Constants.INDIVIDUAL;
                                          },
                                        ),

                                        Text(AppLocalization.of(context).getTranslatedValue("individual"),
                                          style: Theme.of(context).textTheme.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 20,),

                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Checkbox(
                                          activeColor: Colors.blueAccent,
                                          checkColor: Colors.white,
                                          value: _providerType[1],
                                          onChanged: (value) {

                                            _setProviderType(1);
                                            _user.providingJobAs = Constants.BUSINESS;
                                          },
                                        ),

                                        Text(AppLocalization.of(context).getTranslatedValue("business"),
                                          style: Theme.of(context).textTheme.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Visibility(
                              visible: _userTypeCheck[1],
                              child: Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 15, left: 5),
                                child: Text(AppLocalization.of(context).getTranslatedValue("seeking_job_as"),
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                            ),

                            Flexible(
                              child: Visibility(
                                visible: _userTypeCheck[1],
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(top: 1.5 * SizeConfig.heightSizeMultiplier),
                                  child: Wrap(
                                    children: settings.value.services.list.asMap().map((index, service) => MapEntry(index, Container(
                                      height: 35,
                                      padding: EdgeInsets.only(right: 10),
                                      margin: EdgeInsets.only(left: 1.28 * SizeConfig.widthSizeMultiplier, right: 1.28 * SizeConfig.widthSizeMultiplier,
                                          bottom: 2 * SizeConfig.heightSizeMultiplier),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black54, width: 1),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[

                                          Checkbox(
                                            activeColor: Colors.lightGreen,
                                            checkColor: Colors.white,
                                            value: _serviceCheck[index],
                                            onChanged: (value) {

                                              setState(() {
                                                _serviceCheck[index] = !_serviceCheck[index];
                                              });

                                              if(_serviceCheck[index]) {

                                                _user.services.list.add(settings.value.services.list[index]);
                                              }
                                              else {

                                                _user.services.list.remove(settings.value.services.list[index]);
                                              }
                                            },
                                          ),

                                          Text(service.name,
                                            style: Theme.of(context).textTheme.subtitle2,
                                          ),
                                        ],
                                      ),
                                    ))).values.toList(),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("attachment"),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),

                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {

                                _pickAttachment();
                              },
                              child: TextFormField(
                                controller: _attachmentController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                enabled: false,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white,),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.file_upload, color: Colors.transparent,),
                                  suffixIcon: Icon(Icons.file_upload, color: Colors.white,),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                  fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.indigoAccent.withOpacity(.75) : Colors.white.withOpacity(.3),
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _userTypeCheck[1],
                              child: Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 20, left: 5),
                                child: Text(AppLocalization.of(context).getTranslatedValue("cv_attachment"),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _userTypeCheck[1],
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {

                                  _pickCvAttachment();
                                },
                                child: TextFormField(
                                  controller: _cvController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  enabled: false,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.file_upload, color: Colors.transparent,),
                                    suffixIcon: Icon(Icons.file_upload, color: Colors.white,),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                    ),
                                    filled: true,
                                    contentPadding: EdgeInsets.all(1.6875 * SizeConfig.heightSizeMultiplier),
                                    fillColor: AppThemeNotifier().isDarkModeOn == false ? Colors.indigoAccent.withOpacity(.75) : Colors.white.withOpacity(.3),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 65),
                              child: BounceAnimation(
                                key: _bounceKey,
                                childWidget: RaisedButton(
                                  padding: EdgeInsets.all(0),
                                  elevation: 5,
                                  onPressed: () {

                                    _bounceKey.currentState.animationController.forward();
                                    FocusScope.of(context).unfocus();

                                    _validateForm(context);
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor,
                                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    child: Text(
                                      AppLocalization.of(context).getTranslatedValue("sign_up").toUpperCase(),
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 30, bottom: 10),
                              child: Text(AppLocalization.of(context).getTranslatedValue("by_creating_account"),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ),

                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {

                                MyWebView view = MyWebView(url: settings.value.termsConditionsUrl,
                                    title: AppLocalization.of(context).getTranslatedValue("terms_condition"));

                                Navigator.of(context).pushNamed(RouteManager.WEB_VIEW, arguments: view);
                              },
                              child: Text(AppLocalization.of(context).getTranslatedValue("terms_condition"),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.green,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("or"),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption.copyWith(fontSize: 15),
                              ),
                            ),

                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {

                                Navigator.pop(context);
                              },
                              child: Text(AppLocalization.of(context).getTranslatedValue("back_to_login"),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                _connectionAlert.onDisconnected(context),
              ],
            );
          },
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


  void _setUserType(int position) {

    if(position < _userTypeCheck.length && !_userTypeCheck[position]) {

      _serviceCheck = List.filled(settings.value.services.list.length, false);
      _providerType = List.filled(2, false);

      for(int i=0; i<_userTypeCheck.length; i++) {

        setState(() {

          if(i == position) {

            _userTypeCheck[i] = true;
          }
          else {

            _userTypeCheck[i] = false;
          }
        });
      }
    }
  }


  Future<void> _selectDate(BuildContext context) async {

    final DateTime dateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        helpText: AppLocalization.of(context).getTranslatedValue("birthdate"),
        locale: MyApp.appLocale,
    );

    if(dateTime != null) {

      _dateController.text = MyDateTime.getDatabaseFormat(dateTime);
      _user.birthDate = _dateController.text;
    }

    FocusScope.of(context).requestFocus(FocusNode());
  }


  void _setGenderType(int position) {

    if(position < _userGender.length && !_userGender[position]) {

      for(int i=0; i<_userGender.length; i++) {

        setState(() {

          if(i == position) {

            _userGender[i] = true;
          }
          else {

            _userGender[i] = false;
          }
        });
      }
    }
  }


  void _setProviderType(int position) {

    if(position < _providerType.length && !_providerType[position]) {

      for(int i=0; i<_providerType.length; i++) {

        setState(() {

          if(i == position) {

            _providerType[i] = true;
          }
          else {

            _providerType[i] = false;
          }
        });
      }
    }
  }


  void _validateForm(BuildContext context) {

    if(_formKey.currentState.validate()) {

      if(_user.roleID == null || _user.roleID.isEmpty) {

        onInvalid(context, AppLocalization.of(context).getTranslatedValue("select_user_type"));
      }
      else {

        if(_user.gender == null || _user.gender.isEmpty) {

          onInvalid(context, AppLocalization.of(context).getTranslatedValue("select_gender_type"));
        }
        else {

          if(_user.birthDate == null || _user.birthDate.isEmpty) {

            onInvalid(context, AppLocalization.of(context).getTranslatedValue("give_birthdate"));
          }
          else {

            if(_user.providingJobAs == null || _user.providingJobAs.isEmpty) {

              onInvalid(context, AppLocalization.of(context).getTranslatedValue("select_provider_type"));
            }
            else {

              if(_user.roleID == Constants.PROVIDER) {

                onValid(context);
              }
              else if(_user.roleID == Constants.SEEKER) {

                if(_user.services.list == null || _user.services.list.isEmpty) {

                  onInvalid(context, AppLocalization.of(context).getTranslatedValue("select_service_type"));
                }
                else {

                  onValid(context);
                }
              }
            }
          }
        }
      }
    }
  }


  void onInvalid(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 1500), content: Text(message)));
  }


  void onValid(BuildContext context) {

    _user.name = _nameController.text;
    _user.birthDate = _dateController.text;

    if(_emailController.text != null && _emailController.text.isNotEmpty) {
      _user.email = _emailController.text;
    }

    _user.phone = _phoneController.text;
    _user.password = _passwordController.text;

    if(_attachment != null) {
      _user.attachment = _attachment.path;
    }

    if(_cvAttachment != null) {
      _user.cvAttachment = _cvAttachment.path;
    }

    try {
      Scaffold.of(context).hideCurrentSnackBar();
    }
    catch(error) {}

    if(_isValid) {

      _otpPresenter.sendOTP(context, _user, Constants.SIGN_UP);
    }
    else {

      _userPresenter.validateUser(context, _user.phone);
    }
  }


  Future<void> _pickAttachment() async {

    _attachment = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: ["pdf", "jpg", "jpeg"],
    );

    if(_attachment != null) {

      if(path.extension(_attachment.path) == "jpg" || path.extension(_attachment.path) == "jpeg") {

        _attachment = await _compressFile(_attachment);
      }

      setState(() {
        _attachmentController.text = _attachment.path.substring(_attachment.path.lastIndexOf("/")+1, _attachment.path.length);
      });
    }
  }


  Future<void> _pickCvAttachment() async {

    _cvAttachment = await FilePicker.getFile(
      type: FileType.custom,
      allowCompression: true,
      allowedExtensions: ["pdf", "doc", "docx"],
    );

    if(_cvAttachment != null) {

      setState(() {
        _cvController.text = _cvAttachment.path.substring(_cvAttachment.path.lastIndexOf("/")+1, _cvAttachment.path.length);
      });
    }
  }


  Future<File> _compressFile(File file) async {

    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, outPath,
      quality: 5,
    );

    return result;
  }


  @override
  void onFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onConnected(BuildContext context) {

    if(_connectionAlert != null && _connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.reverse();
    }
  }


  @override
  void onDisconnected(BuildContext context) {

    if(_connectionAlert != null && !_connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.forward();
    }
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
  void onNewPhoneVerifyOtpSent(User user) {}


  @override
  void onPhoneVerifyOtpSent() {}


  @override
  void onSignUpOtpSent() {

    OTP otp = OTP(user: _user, type: Constants.SIGN_UP);

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.OTP_VERIFY, arguments: otp);
  }


  @override
  void onInvalidOtp(BuildContext context) {}


  @override
  void onOtpVerified(BuildContext context, OverlayEntry loader) {}


  @override
  void onUserNotFound(BuildContext context) {

    _isValid = true;
    _otpPresenter.sendOTP(context, _user, Constants.SIGN_UP);
  }


  @override
  void onUserExists(BuildContext context) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(AppLocalization.of(context).getTranslatedValue("user_found_with_phone")),
      action: SnackBarAction(
        textColor: Theme.of(context).accentColor,
        label: AppLocalization.of(context).getTranslatedValue("okay"),
        onPressed: () {

          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }


  @override
  void onValidateFailed(BuildContext context) {

    onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_validate_user"));
  }


  @override
  void onResetPasswordOtpSent() {}
}