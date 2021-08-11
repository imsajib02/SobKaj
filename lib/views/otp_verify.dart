import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/otp_contract.dart';
import 'package:sobkaj/contract/profile_contract.dart';
import 'package:sobkaj/contract/signup_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/localization/localization_constrants.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/models/constructor/otp.dart';
import 'package:sobkaj/models/time_out.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/otp_presenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class OtpVerify extends StatefulWidget {

  final OTP _otp;

  OtpVerify(this._otp);

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> with TickerProviderStateMixin implements SignUpContract, ProfileContract, OtpContract, Connectivity {

  OtpPresenter _otpPresenter;
  UserPresenter _userPresenter;

  Connectivity _connectivity;
  OtpContract _otpContract;
  ProfileContract _profileContract;
  SignUpContract _signUpContract;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  bool _isVerified = false;

  OverlayEntry _loader;

  TextEditingController _pinController = TextEditingController();

  StreamController<ErrorAnimationType> _errorController = StreamController<ErrorAnimationType>();

  final _bounceKey = GlobalKey<BounceState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _otpContract = this;
    _signUpContract = this;
    _profileContract = this;
    _connectivity = this;

    _otpPresenter = OtpPresenter(_otpContract, _connectivity);
    _userPresenter = UserPresenter(_connectivity, signUpContract: _signUpContract, profileContract: _profileContract);

    _otpPresenter.startCountDown();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Builder(
            builder: (BuildContext context) {

              return Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Text(MyApp.appLocale.languageCode == ENGLISH ? (AppLocalization.of(context).getTranslatedValue("otp_title") + " " +
                        AppLocalization.of(context).getTranslatedValue("+880") + widget._otp.user.phone) :
                    (AppLocalization.of(context).getTranslatedValue("+880") + widget._otp.user.phone + " " +
                        AppLocalization.of(context).getTranslatedValue("otp_title")),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),

                    SizedBox(height: 70,),

                    Text(AppLocalization.of(context).getTranslatedValue("otp_subtitle"),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black38, fontWeight: FontWeight.normal),
                    ),

                    SizedBox(height: 20,),

                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PinCodeTextField(
                        length: 6,
                        enabled: !_isVerified,
                        controller: _pinController,
                        obsecureText: false,
                        animationType: AnimationType.fade,
                        autoDisposeControllers: false,
                        textInputType: TextInputType.number,
                        textStyle: Theme.of(context).textTheme.headline4.copyWith(color: Colors.red, fontWeight: FontWeight.normal),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          fieldHeight: 50,
                          fieldWidth: 40,
                          borderWidth: 2,
                          activeFillColor: Colors.transparent,
                          disabledColor: Colors.transparent,
                          activeColor: Colors.lightBlue,
                          inactiveColor: Colors.lightBlue,
                          inactiveFillColor: Colors.transparent,
                          selectedColor: Colors.lightBlue,
                          selectedFillColor: Colors.transparent,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        errorAnimationController: _errorController,
                        onCompleted: (code) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (code) {},
                        beforeTextPaste: (text) {
                          return false;
                        },
                      ),
                    ),

                    SizedBox(height: 50,),

                    ValueListenableBuilder<TimeOut>(
                      valueListenable: timeOut,
                      builder: (context, value, _) {

                        return Visibility(
                          visible: !_isVerified,
                          child: Column(
                            children: <Widget>[

                              Visibility(
                                visible: value.time > 0,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: AppLocalization.of(context).getTranslatedValue("resend_code_in"),
                                    style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                                    children: <TextSpan>[

                                      TextSpan(text: "  :" + (MyApp.appLocale.languageCode == ENGLISH ? value.time.toString() :
                                      value.timeInBangla) + " " + AppLocalization.of(context).getTranslatedValue("second") + " " +
                                          (MyApp.appLocale.languageCode == ENGLISH ? "" : AppLocalization.of(context).getTranslatedValue("after")),
                                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: value.time == 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    Text(AppLocalization.of(context).getTranslatedValue("did_not_get_code") + "  ",
                                      style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                                    ),

                                    GestureDetector(
                                      onTap: () {

                                        FocusScope.of(context).unfocus();
                                        _otpPresenter.resendCode(context, widget._otp.user.phone);
                                      },
                                      child: Text(AppLocalization.of(context).getTranslatedValue("resend"),
                                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 50,),

                    BounceAnimation(
                      key: _bounceKey,
                      childWidget: RaisedButton(
                        padding: EdgeInsets.all(0),
                        elevation: 5,
                        onPressed: () {

                          _bounceKey.currentState.animationController.forward();
                          FocusScope.of(context).unfocus();

                          if(!_isVerified) {

                            if(_pinController.text.length < 6) {

                              onFailed(context, AppLocalization.of(context).getTranslatedValue("must_be_6_digit"));
                            }
                            else {

                              _otpPresenter.verifyCode(context, _pinController.text);
                            }
                          }
                          else {

                            if(widget._otp.type == Constants.SIGN_UP) {

                              _userPresenter.signUp(context, widget._otp.user, _loader, true);
                            }
                            else if(widget._otp.type == Constants.NEW_PHONE_VERIFY) {

                              _userPresenter.changePhone(context, widget._otp.user, _loader, true);
                            }
                          }
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
                            AppLocalization.of(context).getTranslatedValue("verify"),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
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
    );
  }


  @override
  void dispose() {

    _otpPresenter.stopCountDown();

    _errorController.close();
    _connectivityChecker.removeStatusListener();
    _connectionAlert.controller.dispose();

    super.dispose();
  }


  Future<bool> _onBackPress() {

    return Future(() => false);
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
  void onFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
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
  void onSignUpOtpSent() {}


  @override
  void onInvalidOtp(BuildContext context) {

    try{
      _errorController.add(ErrorAnimationType.shake);
    }
    catch(error) {}

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("invalid_otp"))));
  }


  @override
  void onOtpVerified(BuildContext context, OverlayEntry loader) {

    _loader = loader;

    setState(() {
      _isVerified = true;
    });

    _pinController.clear();
    _otpPresenter.stopCountDown();

    switch(widget._otp.type) {

      case Constants.SIGN_UP:
        _userPresenter.signUp(context, widget._otp.user, _loader, false);
        break;

      case Constants.PHONE_VERIFY:
        break;

      case Constants.NEW_PHONE_VERIFY:
        _userPresenter.changePhone(context, widget._otp.user, _loader, false);
        break;

      case Constants.PASSWORD_RESET:
        _loader.remove();
        Navigator.pop(context);
        Navigator.of(context).pushNamed(RouteManager.CREATE_NEW_PASSWORD, arguments: widget._otp.user.phone);
        break;
    }
  }
  

  @override
  void onSignUpFailed(BuildContext context) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(AppLocalization.of(context).getTranslatedValue("failed_to_signup")),
      action: SnackBarAction(
        textColor: Theme.of(context).accentColor,
        label: AppLocalization.of(context).getTranslatedValue("try_again"),
        onPressed: () {

          Scaffold.of(context).hideCurrentSnackBar();
          _userPresenter.signUp(context, widget._otp.user, _loader, true);
        },
      ),
    ));
  }
  

  @override
  void onSignUpSuccess() {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.BOTTOM_NAVIGATION, arguments: currentUser.value.roleID == Constants.PROVIDER ? 1 : 2);
  }


  @override
  void onInvalidData(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(message),
      action: SnackBarAction(
        textColor: Theme.of(context).accentColor,
        label: AppLocalization.of(context).getTranslatedValue("go_back"),
        onPressed: () {

          Scaffold.of(context).hideCurrentSnackBar();

          Navigator.pop(context);
          Navigator.of(context).pushNamed(RouteManager.SIGN_UP);
        },
      ),
    ));
  }


  @override
  void onError(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onPhoneNumberTaken(BuildContext context) {

    Navigator.pop(context, AppLocalization.of(context).getTranslatedValue("phone_number_taken"));
  }


  @override
  void onSuccess(BuildContext context, String message) {

    Navigator.pop(context, AppLocalization.of(context).getTranslatedValue("phone_changed"));
  }


  @override
  void onResetPasswordOtpSent() {}
}