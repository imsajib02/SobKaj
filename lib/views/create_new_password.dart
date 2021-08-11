import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/profile_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/size_config.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class CreateNewPassword extends StatefulWidget {

  final String _phone;

  CreateNewPassword(this._phone);

  @override
  _CreateNewPasswordState createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> with TickerProviderStateMixin implements ProfileContract, Connectivity {

  UserPresenter _userPresenter;
  ProfileContract _profileContract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _toggle = true;

  FocusNode _newPasswordNode = FocusNode();
  FocusNode _confirmPasswordNode = FocusNode();

  final _bounceKey = GlobalKey<BounceState>();
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _connectivity = this;
    _profileContract = this;
    _userPresenter = UserPresenter(_connectivity, profileContract: _profileContract);

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

                            Text(AppLocalization.of(context).getTranslatedValue("create_new_password"),
                              style: Theme.of(context).textTheme.headline1,
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(AppLocalization.of(context).getTranslatedValue("create_new_password_subtitle"),
                                textAlign: TextAlign.justify,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 40, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("new_password"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _toggle,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode: _newPasswordNode,
                              onFieldSubmitted: (string) {

                                _confirmPasswordNode.requestFocus();
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

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 15, left: 5),
                              child: Text(AppLocalization.of(context).getTranslatedValue("confirm_password"),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),

                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              focusNode: _confirmPasswordNode,
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
                                else if(value != _newPasswordController.text) {
                                  return AppLocalization.of(context).getTranslatedValue("confirm_pass_not_match");
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
                                      AppLocalization.of(context).getTranslatedValue("reset_password"),
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
                              child: Text(AppLocalization.of(context).getTranslatedValue("go_back"),
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

      _userPresenter.resetPassword(context, User(
          phone: widget._phone,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text)
      );
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
  void onError(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onPhoneNumberTaken(BuildContext context) {}


  @override
  void onSuccess(BuildContext context, String message) {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.LOGIN, arguments: message);
  }
}