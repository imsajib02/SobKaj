import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/otp_contract.dart';
import 'package:sobkaj/contract/user_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/otp_presenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:sobkaj/widgets/connection_alert.dart';
import 'package:sobkaj/models/constructor/otp.dart';

class ResetPassword extends StatefulWidget {

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> with TickerProviderStateMixin implements UserContract, OtpContract, Connectivity {

  UserPresenter _userPresenter;
  OtpPresenter _otpPresenter;

  Connectivity _connectivity;
  UserContract _userContract;
  OtpContract _otpContract;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  TextEditingController _phoneController = TextEditingController();

  final _bounceKey = GlobalKey<BounceState>();
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _connectivity = this;
    _userContract = this;
    _otpContract = this;

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

            return Stack(
              children: <Widget>[

                SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.only(top: 60, left: 30, right: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[

                            Text(AppLocalization.of(context).getTranslatedValue("reset_password"),
                              style: Theme.of(context).textTheme.headline1,
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(AppLocalization.of(context).getTranslatedValue("reset_password_subtitle"),
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 40, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("phone"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (string) {

                                _validate(context);
                              },
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }
                                else if(value.length < 11) {
                                  return AppLocalization.of(context).getTranslatedValue("invalid_phone");
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
                              padding: EdgeInsets.only(top: 60),
                              child: BounceAnimation(
                                key: _bounceKey,
                                childWidget: RaisedButton(
                                  padding: EdgeInsets.all(0),
                                  elevation: 5,
                                  onPressed: () {

                                    _bounceKey.currentState.animationController.forward();
                                    _validate(context);
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
                                      AppLocalization.of(context).getTranslatedValue("submit").toUpperCase(),
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 10),
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


  void _validate(BuildContext context) {

    FocusScope.of(context).unfocus();

    if(_formKey.currentState.validate()) {

      _userPresenter.validateUser(context, _phoneController.text);
    }
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
  void onUserExists(BuildContext context) {

    _otpPresenter.sendOTP(context, User(phone: _phoneController.text), Constants.PASSWORD_RESET);
  }


  @override
  void onUserNotFound(BuildContext context) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(AppLocalization.of(context).getTranslatedValue("no_user_with_this_phone")),
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
  void onFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onInvalidOtp(BuildContext context) {}


  @override
  void onNewPhoneVerifyOtpSent(User user) {}


  @override
  void onOtpVerified(BuildContext context, OverlayEntry loader) {}


  @override
  void onPhoneVerifyOtpSent() {}


  @override
  void onSignUpOtpSent() {}


  @override
  void onResetPasswordOtpSent() {

    OTP otp = OTP(user: User(phone: _phoneController.text), type: Constants.PASSWORD_RESET);
    Navigator.of(context).pushNamed(RouteManager.OTP_VERIFY, arguments: otp);
  }
}