import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/home_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/resources/images.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin implements HomeContract, Connectivity {

  SettingPresenter _presenter;
  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  Connectivity _connectivity;
  HomeContract _contract;

  String _currentAddress = "";
  Color _color;

  AnimationController _controller;

  List<Color> _colors = [Color(0xffd0fffe), Color(0xfffffddb), Color(0xffe4ffde), Color(0xffffd3fd), Color(0xffffe7d3)];

  JobServices _services = JobServices(list: List());
  Jobs _jobs = Jobs(list: List());
  Users _seekers = Users(list: List());
  List<DateTime> _activeDates = List();

  bool _isCallMade = false;
  bool _isComplete = false;


  @override
  void initState() {

    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    _getAddress();

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _connectivity = this;
    _contract = this;

    _presenter = SettingPresenter(_connectivity, homeContract: _contract);

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
        body: Builder(
          builder: (BuildContext context) {

            if(!_isCallMade) {

              _isCallMade = true;
              _presenter.getHomeData(context);
            }

            return Stack(
              children: <Widget>[

                Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      primary: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[

                          Container(
                            height: 100,
                            width: double.infinity,
                          ),

                          Padding(
                            padding: EdgeInsets.only(right: 20, bottom: 20, top: 30),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                Text(AppLocalization.of(context).getTranslatedValue("services"),
                                  style: Theme.of(context).textTheme.subtitle1
                                ),

                                GestureDetector(
                                  onTap: () {

                                    Navigator.of(context).pushNamed(RouteManager.ALL_SERVICE);
                                  },
                                  child: Text(AppLocalization.of(context).getTranslatedValue("see_all"),
                                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 100,
                            child: ListView.builder(
                              itemCount: settings.value.services.list.length > Constants.SERVICE_MAX_LENGTH ? Constants.SERVICE_MAX_LENGTH : settings.value.services.list.length,
                              padding: EdgeInsets.only(left: 5),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {

                                return Visibility(
                                  visible: settings.value.services.list[index].status == Constants.ACTIVE,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {

                                        final result = await Navigator.of(context).pushNamed(RouteManager.JOB_POST, arguments: settings.value.services.list[index]);

                                        if(result != null && result.toString().isNotEmpty) {

                                          Scaffold.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(content: Text("$result")));
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[

                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: _colors[index % _colors.length],
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child: CachedNetworkImage(imageUrl: settings.value.services.list[index].imageUrl, fit: BoxFit.cover,),
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(settings.value.services.list[index].name,
                                                style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 12)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Text(AppLocalization.of(context).getTranslatedValue("scheduled_jobs"),
                                    style: Theme.of(context).textTheme.subtitle1
                                ),

                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(AppLocalization.of(context).getTranslatedValue("click_active_dates_to_see_details"),
                                      style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12)
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(right: 15, left: 5),
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DatePicker(
                                  DateTime.now(),
                                  selectionColor: Colors.lightGreen,
                                  selectedTextColor: Colors.white,
                                  activeDates: _activeDates,
                                  locale: MyApp.appLocale.toString(),
                                  onDateChange: (date) {

                                    Navigator.of(context).pushNamed(RouteManager.JOB_DETAIL, arguments: _jobs.list[_activeDates.indexOf(date)]);
                                  },
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 40, bottom: 10),
                            child: Text(AppLocalization.of(context).getTranslatedValue("best_service_providers"),
                                style: Theme.of(context).textTheme.subtitle1
                            ),
                          ),

                          Visibility(
                            visible: _isComplete && _seekers.list.length > 0,
                            child: Container(
                              height: 200,
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                itemCount: _seekers.list.length > Constants.TOP_SEEKER_MAX_LENGTH ? Constants.TOP_SEEKER_MAX_LENGTH : _seekers.list.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {

                                  return Padding(
                                    padding: EdgeInsets.only(right: 20, left: 5),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {

                                        Navigator.of(context).pushNamed(RouteManager.SEEKER_INFO, arguments: _seekers.list[index]);
                                      },
                                      child: Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).accentColor,
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: <Widget>[

                                            Hero(
                                              tag: _seekers.list[index].id.toString(),
                                              child: _seekers.list[index].avatar == null || _seekers.list[index].avatar.isEmpty ? Container(
                                                width: 200,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: AssetImage(Images.noImage),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ) : Container(
                                                width: 200,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(_seekers.list[index].avatar),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),
                                                    bottomLeft: Radius.circular(10),
                                                  )
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[

                                                    Icon(Icons.star, size: 20, color: Colors.yellow,),

                                                    Padding(
                                                      padding: EdgeInsets.only(left: 5),
                                                      child: Text(_seekers.list[index].rating.toString(),
                                                        style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Container(
                                                width: 200,
                                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 7, top: 7),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).accentColor,
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(10),
                                                      bottomRight: Radius.circular(10),
                                                    )
                                                ),
                                                child: Text(_seekers.list[index].name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: Theme.of(context).textTheme.subtitle2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          Visibility(
                            visible: !_isComplete,
                            child: Container(
                              height: 200,
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                itemCount: 6,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {

                                  return Padding(
                                    padding: EdgeInsets.only(right: 20, left: 5),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.grey[200],
                                      baseColor: Theme.of(context).accentColor,
                                      child: Container(
                                        width: 200,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text(AppLocalization.of(context).getTranslatedValue("recommended_services"),
                                style: Theme.of(context).textTheme.subtitle1
                            ),
                          ),

                          Visibility(
                            visible: _isComplete,
                            child: ListView.builder(
                              itemCount: _services.list.length > Constants.RECOMMENDED_SERVICE_MAX_LENGTH ? Constants.RECOMMENDED_SERVICE_MAX_LENGTH : _services.list.length,
                              padding: EdgeInsets.only(left: 5, right: 20),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {

                                return Visibility(
                                  visible: _services.list[index].status == Constants.ACTIVE,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {

                                        final result = await Navigator.of(context).pushNamed(RouteManager.JOB_POST, arguments: settings.value.services.list.first);

                                        if(result != null && result.toString().isNotEmpty) {

                                          Scaffold.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(content: Text("$result")));
                                        }
                                      },
                                      child: Material(
                                        elevation: 3,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).accentColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[

                                              Expanded(
                                                flex: 3,
                                                child: _services.list[index].imageUrl == null || _services.list[index].imageUrl.isEmpty ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                    image: DecorationImage(
                                                      image: AssetImage(Images.noImage),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                    image: DecorationImage(
                                                      image: CachedNetworkImageProvider(_services.list[index].imageUrl),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                flex: 6,
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 20),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[

                                                      Padding(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(_services.list[index].name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.fade,
                                                          style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black.withOpacity(.7)),
                                                        ),
                                                      ),

                                                      Visibility(
                                                        visible: _services.list[index].price != null && _services.list[index].price.isNotEmpty,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 10),
                                                          child: Text("৳" + _services.list[index].price.toString(),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.fade,
                                                            style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                                                          ),
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
                                  ),
                                );
                              },
                            ),
                          ),

                          Visibility(
                            visible: !_isComplete,
                            child: ListView.builder(
                              itemCount: 6,
                              padding: EdgeInsets.only(left: 5, right: 20),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Shimmer.fromColors(
                                      highlightColor: Colors.grey[200],
                                      baseColor: Theme.of(context).accentColor,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[

                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ),

                                            Expanded(
                                              flex: 5,
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 10),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Padding(
                                                      padding: EdgeInsets.only(right: 10),
                                                      child: Container(
                                                        height: 20,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: EdgeInsets.only(top: 10),
                                                      child: Container(
                                                        height: 20,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: EdgeInsets.only(top: 10),
                                                      child: Container(
                                                        height: 20,
                                                        color: Colors.grey[300],
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
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 30, top: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                      )
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Text(AppLocalization.of(context).getTranslatedValue("live_location"),
                          style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.normal,
                            color: Colors.black38
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            Expanded(
                              flex: 3,
                              child: Text(_currentAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _getAddress();
                                  },
                                  child: RotationTransition(
                                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                                    child: Icon(Icons.sync, size: 20, color: _color,),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

    _controller.dispose();

    _connectivityChecker.removeStatusListener();
    _connectionAlert.controller.dispose();

    super.dispose();
  }


  Future<void> _getAddress() async {

    setState(() {
      _color = Colors.blueAccent;
    });

    _controller.repeat();

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    if(position != null) {

      var addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));

      if(addresses != null && addresses.first != null && addresses.first.addressLine != null) {

        setState(() {
          _currentAddress = addresses.first.addressLine;
        });
      }
    }
    else {

      setState(() {
        _currentAddress = AppLocalization.of(context).getTranslatedValue("location_not_found");
      });
    }

    _controller.reset();

    setState(() {
      _color = Colors.black87;
    });
  }


  @override
  void onConnected(BuildContext context) {

    if(_connectionAlert != null && _connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.reverse();
    }
  }


  @override
  void onDataFound(Jobs jobs, JobServices services, Users seekers) {

    for(int i=0; i<jobs.list.length; i++) {

      if(DateTime.parse(jobs.list[i].date).isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {

        setState(() {
          _activeDates.add(DateTime.parse(jobs.list[i].date));
        });
      }
    }

    setState(() {
      _jobs = jobs;
      _services = services;
      _seekers = seekers;
      _isComplete = true;
    });
  }


  @override
  void onDisconnected(BuildContext context) {

    if(_connectionAlert != null && !_connectionAlert.controller.isCompleted) {

      _connectionAlert.controller.forward();
    }
  }


  @override
  void onFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 365),
      content: Text(message),
      action: SnackBarAction(
        textColor: Theme.of(context).accentColor,
        label: AppLocalization.of(context).getTranslatedValue("try_again"),
        onPressed: () {

          Scaffold.of(context).hideCurrentSnackBar();
          _presenter.getHomeData(context);
        },
      ),
    ));
  }


  @override
  void onTimeout(BuildContext context) {

    onFailed(context, AppLocalization.of(context).getTranslatedValue("connection_time_out"));
  }
}