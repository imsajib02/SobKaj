import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/login_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/fcm_setup.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:sobkaj/utils/update_check.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class Login extends StatefulWidget {

  final String message;

  Login({this.message});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin implements LoginContract, Connectivity {

  UserPresenter _presenter;
  Connectivity _connectivity;
  LoginContract _contract;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _toggle = true;

  BuildContext _context;

  FocusNode _phoneNode = FocusNode();
  FocusNode _passwordNode = FocusNode();

  final _bounceKey = GlobalKey<BounceState>();
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _contract = this;
    _connectivity = this;
    _presenter = UserPresenter(_connectivity, loginContract: _contract);

    Future.delayed(Duration(milliseconds: 1200), () {

      if(widget.message != null && widget.message.isNotEmpty) {

        _contract.onAccountNotActive(_context, widget.message);
      }
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            _context = context;
            UpdateCheck.checkForUpdate(context);

            return Stack(
              children: <Widget>[

                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[

                          Padding(
                            padding: EdgeInsets.only(top: 50, bottom: 30, left: 35, right: 35),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[

                                  Text(AppLocalization.of(context).getTranslatedValue("welcome_to"),
                                      style: Theme.of(context).textTheme.subtitle2,
                                  ),

                                  SizedBox(height: 10,),

                                  Text(AppLocalization.of(context).getTranslatedValue("login_to_kaj"),
                                    style: Theme.of(context).textTheme.headline2,
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(top: 80, bottom: 15, left: 5),
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

                                      _validate(context);
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

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 20, bottom: 20, right: 10),
                                      child: GestureDetector(
                                        onTap: () {

                                          Navigator.of(context).pushNamed(RouteManager.RESET_PASSWORD);
                                        },
                                        child: Text(AppLocalization.of(context).getTranslatedValue("forgot_password"),
                                          style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontSize: 1.8 * SizeConfig.textSizeMultiplier,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(top: 50),
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
                                          child: Text(AppLocalization.of(context).getTranslatedValue("sign_in").toUpperCase(),
                                            style: Theme.of(context).textTheme.subtitle1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Text(AppLocalization.of(context).getTranslatedValue("dont_have_account"),
                                          style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: GestureDetector(
                                            onTap: () {

                                              Navigator.of(context).pushNamed(RouteManager.SIGN_UP);
                                            },
                                            child: Text(AppLocalization.of(context).getTranslatedValue("register"),
                                              style: Theme.of(context).textTheme.subtitle1.copyWith(
                                                decoration: TextDecoration.underline,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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


  void _validate(BuildContext context) {

    FocusScope.of(context).unfocus();

    if(_formKey.currentState.validate()) {

      _presenter.login(context,
          User(phone: _phoneController.text,
            password: _passwordController.text,
            deviceToken: deviceToken.value,
          ),
      );
    }
  }


  @override
  void onDisconnected(BuildContext context) {

    if(_connectionAlert != null && !_connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.forward();
    }
  }


  @override
  void onConnected(BuildContext context) {

    if(_connectionAlert != null && _connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.reverse();
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
  void onFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onSuccess() {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.BOTTOM_NAVIGATION, arguments: currentUser.value.roleID == Constants.PROVIDER ? 1 : 2);
  }


  @override
  void onAccountNotActive(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(message),
      action: SnackBarAction(
        textColor: Theme.of(context).accentColor,
        label: AppLocalization.of(context).getTranslatedValue("okay"),
        onPressed: () {

          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }


  Future<bool> _backPressed() {

    SystemNavigator.pop();
    return Future(() => false);
  }
}