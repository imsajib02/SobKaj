import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/setting_contract.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/resources/images.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin implements SettingContract, Connectivity {

  AnimationController _animationController;
  Animation _sizeAnimation;

  bool reverse = false;
  bool isCallMade = false;

  SettingPresenter _presenter;
  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  Connectivity _connectivity;
  SettingContract _contract;


  @override
  void initState() {

    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..addStatusListener((status) {

        if(status == AnimationStatus.completed) {
          _animationController.repeat(reverse: !reverse);
          reverse = !reverse;
        }
      });

    _sizeAnimation = Tween<double>(begin: 125.0, end: 160.0).animate(_animationController);
    _animationController.forward();

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _connectivity = this;
    _contract = this;

    _presenter = SettingPresenter(_connectivity, settingContract: _contract);

    super.initState();
  }


  @override
  void didChangeDependencies() {

    if(!isCallMade) {

      isCallMade = true;
      _presenter.getSettings(context);
    }

    super.didChangeDependencies();
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    AnimatedBuilder(
                      animation: _sizeAnimation,
                      builder: (context, child) {

                        return Container(
                          width: _sizeAnimation.value,
                          height: _sizeAnimation.value,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(Images.appIcon),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
    _animationController.dispose();

    super.dispose();
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

    onTimeout(context);
  }


  @override
  void onFailed(BuildContext context) {

    onTimeout(context);
  }


  @override
  void onTimeout(BuildContext context) {

    Timer(Duration(milliseconds: 1000), () {

      _presenter.getSettings(context);
    });
  }


  @override
  void onUserFound() {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.BOTTOM_NAVIGATION, arguments: currentUser.value.roleID == Constants.PROVIDER ? 1 : 2);
  }


  @override
  void onUserNotFound() {

    Navigator.pop(context);
    Navigator.of(context).pushNamed(RouteManager.LOGIN);
  }


  @override
  void onTokenExpired() {

    onUserNotFound();
  }


  @override
  void onAccountNotActive(BuildContext context, String message) {

    Navigator.of(context).pushNamed(RouteManager.LOGIN, arguments: message);
  }
}