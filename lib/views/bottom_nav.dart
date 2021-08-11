import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/auth_expiry.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/update_check.dart';
import 'package:sobkaj/views/home.dart';
import 'package:sobkaj/views/my_jobs.dart';
import 'package:sobkaj/views/my_payout.dart';
import 'package:sobkaj/views/profile.dart';

import 'dart:io' show Platform;
import 'package:location/location.dart' as loc;

import 'active_jobs.dart';
import 'my_bids.dart';

class BottomNavigation extends StatefulWidget {

  final int _page;

  BottomNavigation(this._page);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with TickerProviderStateMixin, WidgetsBindingObserver {

  UserPresenter _presenter;
  Connectivity _connectivity;

  LocationOptions _locationOptions;
  StreamSubscription<Position> _positionStream;

  Widget _currentTab;
  int _currentTabIndex;

  List<Permission> permissions = [Permission.location, Permission.locationAlways, Permission.locationWhenInUse];

  bool _isRequested = false;
  bool _isAlertShown = false;

  AuthExpiry _authExpiry;

  @override
  initState() {

    _authExpiry = AuthExpiry();
    _presenter = UserPresenter(_connectivity);

    WidgetsBinding.instance.addObserver(this);

    _currentTabIndex = widget._page;
    _changeTab();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _requestPermission();

    return WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Builder(
          builder: (BuildContext context) {

            UpdateCheck.checkForUpdate(context);
            _authExpiry.start(context);

            return _currentTab;
          },
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: Colors.black,
          child: currentUser.value.roleID == Constants.PROVIDER ? _providerNavBarsItems() : _seekerNavBarsItems(),
        ),
      ),
    );
  }


  Row _providerNavBarsItems() {

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_1;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.history, color: _currentTabIndex == 0 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 0 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("my_jobs").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 0 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 0 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_2;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.home, color: _currentTabIndex == 1 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 1 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("home").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 1 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 1 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_3;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.person_outline, color: _currentTabIndex == 2 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 2 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("profile").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 2 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 2 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Row _seekerNavBarsItems() {

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_1;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.history, color: _currentTabIndex == 0 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 0 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("my_jobs").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 0 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 0 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_2;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.attach_money, color: _currentTabIndex == 1 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 1 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("my_bids").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 1 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 1 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_3;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.home, color: _currentTabIndex == 2 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 2 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("nearby_jobs").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 2 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 2 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_4;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.payment, color: _currentTabIndex == 3 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 3 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("payout").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 3 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 3 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _currentTabIndex = Constants.TAB_5;
              });

              _changeTab();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Icon(Icons.person_outline, color: _currentTabIndex == 4 ? CupertinoColors.white : CupertinoColors.systemGrey, size: _currentTabIndex == 4 ? 26 : 18,),

                SizedBox(height: 4,),

                Text(AppLocalization.of(context).getTranslatedValue("profile").toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: _currentTabIndex == 4 ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: _currentTabIndex == 4 ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  void _changeTab() {

    switch(_currentTabIndex) {

      case Constants.TAB_1:

        setState(() {
          _currentTab = MyJobs();
        });
        break;

      case Constants.TAB_2:

        setState(() {

          if(currentUser.value.roleID == Constants.PROVIDER) {

            _currentTab = Home();
          }
          else {

            _currentTab = MyBids();
          }
        });
        break;

      case Constants.TAB_3:

        setState(() {

          if(currentUser.value.roleID == Constants.PROVIDER) {

            _currentTab = Profile();
          }
          else {

            _currentTab = ActiveJobs();
          }
        });
        break;

      case Constants.TAB_4:

        setState(() {
          _currentTab = MyPayouts();
        });
        break;

      case Constants.TAB_5:

        setState(() {
          _currentTab = Profile();
        });
        break;
    }
  }


  void _requestPermission() async {

    if(!_isRequested) {

      _isRequested = true;
      Map<Permission, PermissionStatus> results = await permissions.request();
      print(results.toString());
      _isPermissionGranted(results);
    }
  }


  void _isPermissionGranted(Map<Permission, PermissionStatus> results) {

    if(Platform.isAndroid) {

      if(results[Permission.locationAlways].isGranted) {

        _isLocationServiceEnabled();
      }
      else if(results[Permission.locationAlways].isDenied) {

        _isRequested = false;
        _requestPermission();
      }
      else if(results[Permission.locationAlways].isPermanentlyDenied) {

        if(!_isAlertShown) {
          _forceUserForPermission();
        }
      }
    }
    else if(Platform.isIOS) {

      if(results[Permission.locationAlways].isGranted) {

        _isLocationServiceEnabled();
      }
      else {

        if(results[Permission.locationWhenInUse].isGranted) {

          _isLocationServiceEnabled();
        }
        else if(results[Permission.locationWhenInUse].isDenied) {

          _isRequested = false;
          _requestPermission();
        }
        else if(results[Permission.locationWhenInUse].isPermanentlyDenied) {

          if(!_isAlertShown) {
            _forceUserForPermission();
          }
        }
      }
    }
  }


  void _forceUserForPermission() {

    _isAlertShown = true;
    _isRequested = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {

        return WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: AlertDialog(
            elevation: 10,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[

                  Icon(Icons.error, color: Colors.red, size: 30,),

                  SizedBox(width: 15,),

                  Text(AppLocalization.of(context).getTranslatedValue("alert"), style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.red),),
                ],
              ),
            ),
            content: Text(AppLocalization.of(context).getTranslatedValue("grant_permission"),
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            ),
            contentPadding: EdgeInsets.only(left: 30, top: 20, bottom: 20, right: 30),
            actionsPadding: EdgeInsets.only(right: 20, bottom: 10, top: 5),
            actions: <Widget> [

              FlatButton(
                color: Colors.lightBlueAccent,
                textColor: Colors.white,
                child: Text(AppLocalization.of(context).getTranslatedValue("okay")),
                onPressed: () {

                  _isAlertShown = false;
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _isLocationServiceEnabled() async {

    bool serviceEnabled = await Geolocator().isLocationServiceEnabled();

    if(!serviceEnabled) {
      _activateLocationService();
    }
    else {

      if(currentUser.value.roleID == Constants.SEEKER) {

        _listenToSeekerLocation();
      }
    }
  }


  void _activateLocationService() {

    _isAlertShown = true;
    _isRequested = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {

        return WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: AlertDialog(
            elevation: 10,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[

                  Icon(Icons.error, color: Colors.red, size: 30),

                  SizedBox(width: 15,),

                  Text(AppLocalization.of(context).getTranslatedValue("alert"), style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.red),),
                ],
              ),
            ),
            content: Text(AppLocalization.of(context).getTranslatedValue("enable_gps_location"),
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            ),
            contentPadding: EdgeInsets.only(left: 30, top: 20, bottom: 20, right: 30),
            actionsPadding: EdgeInsets.only(right: 20, bottom: 10, top: 5),
            actions: <Widget> [

              FlatButton(
                color: Colors.lightBlueAccent,
                textColor: Colors.white,
                child: Text(AppLocalization.of(context).getTranslatedValue("okay")),
                onPressed: () {

                  _isAlertShown = false;
                  Navigator.of(context).pop();
                  loc.Location().requestService();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _listenToSeekerLocation() {

    _locationOptions = LocationOptions(accuracy: LocationAccuracy.best, timeInterval: 5000);

    _positionStream = Geolocator().getPositionStream(_locationOptions).listen((Position position) {

      if(position != null && position.latitude != null && position.longitude != null) {

        _presenter.updateSeekerLocation(position);
      }
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.resumed && !_isAlertShown) {
      _requestPermission();
    }
  }


  @override
  void dispose() {

    _authExpiry.stop();
    _positionStream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  Future<bool> _backPressed() {

    SystemNavigator.pop();
    return Future(() => false);
  }
}