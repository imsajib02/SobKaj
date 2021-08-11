import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/job_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/constructor/bid_accept.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/payment.dart';
import 'package:sobkaj/presenter/JobPresenter.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/resources/images.dart';
import 'package:sobkaj/utils/bounce_animation.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/widgets/connection_alert.dart';
import 'package:sobkaj/widgets/tav_view.dart';

import '../route/route_manager.dart';

class MyJobs extends StatefulWidget {

  @override
  _MyJobsState createState() => _MyJobsState();
}

class _MyJobsState extends State<MyJobs> with TickerProviderStateMixin implements JobContract, Connectivity {

  JobPresenter _presenter;

  JobContract _contract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  int _index;
  IconData _icon;
  Color _color;

  List<Job> _jobs = [];

  int _stackIndex = 0;
  int _currentPage = 0;
  bool _isCallMade = false;

  final _bounceKey = GlobalKey<BounceState>();


  @override
  void initState() {

    if(currentUser.value.roleID == Constants.PROVIDER) {

      _index = Constants.IS_ACTIVE;
      _icon = Icons.info;
      _color = Colors.blue;
    }
    else {

      _index = Constants.IS_SCHEDULED;
      _icon = Icons.schedule;
      _color = Color(0xff0D4F8B);
    }

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _contract = this;
    _connectivity = this;
    _presenter = JobPresenter(_connectivity, jobContract: _contract);

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
              _presenter.myJobs(context);
            }
            
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[

                  Expanded(
                    flex: 1,
                    child: TabView(
                      selectedIndex: _currentPage,
                      onTap: (int index) {

                        setState(() {
                          _currentPage = index;
                        });

                        _onItemSelected(index);
                      },
                      items: currentUser.value.roleID == Constants.PROVIDER ? _providerTabItems() : _seekerTabItems(),
                    ),
                  ),

                  Expanded(
                    flex: 10,
                    child: IndexedStack(
                      index: _stackIndex,
                      children: <Widget>[

                        ListView.separated(
                          itemCount: _jobs.length,
                          padding: EdgeInsets.all(30),
                          separatorBuilder: (BuildContext context, int index) {

                            return Visibility(
                              visible: _index == Constants.IS_ACTIVE && _jobs[index].status == Constants.IS_ACTIVE.toString() ? true :
                              _index == Constants.IS_SCHEDULED && _jobs[index].status == Constants.IS_SCHEDULED.toString() ? true :
                              _index == Constants.IS_CANCELLED && _jobs[index].status == Constants.IS_CANCELLED.toString() ? true :
                              _index == Constants.IS_COMPLETE && _jobs[index].status == Constants.IS_COMPLETE.toString() ? true :false,
                              child: SizedBox(height: 20,),
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {

                            return Visibility(
                              visible: _index == Constants.IS_ACTIVE && _jobs[index].status == Constants.IS_ACTIVE.toString() ? true :
                              _index == Constants.IS_SCHEDULED && _jobs[index].status == Constants.IS_SCHEDULED.toString() ? true :
                              _index == Constants.IS_CANCELLED && _jobs[index].status == Constants.IS_CANCELLED.toString() ? true :
                              _index == Constants.IS_COMPLETE && _jobs[index].status == Constants.IS_COMPLETE.toString() ? true :false,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {

                                  _onTap(_jobs[index]);
                                },
                                child: Stack(
                                  children: <Widget>[

                                    Padding(
                                      padding: EdgeInsets.only(top: 17.5),
                                      child: Material(
                                        elevation: 4,
                                        color: Theme.of(context).accentColor,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 15),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[

                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[

                                                    Icon(Icons.visibility, size: 18,),

                                                    Padding(
                                                      padding: EdgeInsets.only(left: 7),
                                                      child: Text(AppLocalization.of(context).getTranslatedValue("view_details"),
                                                        style: Theme.of(context).textTheme.bodyText1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.only(top: 10),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[

                                                    Text(MyDateTime.getMonthData(DateTime.parse(_jobs[index].date)),
                                                      style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                                    ),

                                                    Text(_jobs[index].time,
                                                      style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.only(top: 15),
                                                child: Row(
                                                  children: <Widget>[

                                                    Text(AppLocalization.of(context).getTranslatedValue("service") + ":  ",
                                                        style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w500)
                                                    ),

                                                    Text(_jobs[index].service.name,
                                                      style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w500, color: Colors.black.withOpacity(.65))
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.only(top: 10),
                                                child: Row(
                                                  children: <Widget>[

                                                    Text(AppLocalization.of(context).getTranslatedValue("title") + ":  ",
                                                        style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w500)
                                                    ),

                                                    Text(_jobs[index].title,
                                                        style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w500, color: Colors.black.withOpacity(.65))
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      left: 20,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: _color,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Icon(_icon, size: 20, color: Colors.white,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        Center(
                          child: Container(
                            height: 45,
                            padding: EdgeInsets.only(left: 70, right: 70),
                            child: BounceAnimation(
                              key: _bounceKey,
                              childWidget: RaisedButton(
                                padding: EdgeInsets.all(0),
                                elevation: 5,
                                onPressed: () {

                                  _bounceKey.currentState.animationController.forward();

                                  setState(() {
                                    _stackIndex = 0;
                                  });

                                  _presenter.myJobs(context);
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
                                    AppLocalization.of(context).getTranslatedValue("try_again"),
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  List<BottomBarItem> _providerTabItems() {

    return [

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.requested), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("requested")),
        activeColor: Colors.blue,
      ),

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.scheduled), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("scheduled")),
        activeColor: Color(0xff0D4F8B),
      ),

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.cancelled), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("cancelled")),
        activeColor: Colors.orange,
      ),

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.completed), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("complete")),
        activeColor: Colors.greenAccent.shade700,
      ),
    ];
  }


  List<BottomBarItem> _seekerTabItems() {

    return [

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.scheduled), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("scheduled")),
        activeColor: Color(0xff0D4F8B),
      ),

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.cancelled), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("cancelled")),
        activeColor: Colors.orange,
      ),

      BottomBarItem(
        icon: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(Images.completed), fit: BoxFit.contain),
          ),
        ),
        title: Text(AppLocalization.of(context).getTranslatedValue("complete")),
        activeColor: Colors.greenAccent.shade700,
      ),
    ];
  }


  @override
  void dispose() {

    _connectivityChecker.removeStatusListener();
    _connectionAlert.controller.dispose();
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
  }


  @override
  void onFailedToGetJobs(BuildContext context, String message) {

    setState(() {
      _stackIndex = 1;
    });

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onJobPosted(BuildContext context, Job job) {}


  @override
  void onJobUpdated(BuildContext context, Job job) {}


  @override
  void onPostFailed(BuildContext context) {}


  @override
  void onTimeout(BuildContext context) {

    setState(() {
      _stackIndex = 1;
    });

    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).getTranslatedValue("connection_time_out"),
          ),
    ));
  }


  @override
  void onUpdateFailed(BuildContext context, String message) {}


  @override
  void showJobList(List<Job> jobs) {

    jobs.sort((a,b) => b.date.compareTo(a.date));

    setState(() {
      _jobs = jobs;
    });
  }


  @override
  void onPaymentConfirm(BuildContext context, Payment payment) {}


  @override
  void onPaymentConfirmFailed(BuildContext context, String message) {}


  void _onTap(Job job) {

    switch(int.parse(job.status)) {

      case Constants.IS_ACTIVE:
        _showAllBid(job);
        break;

      case Constants.IS_SCHEDULED:
        _showDetails(job);
        break;

      case Constants.IS_CANCELLED:
        break;

      case Constants.IS_COMPLETE:
        Navigator.of(context).pushNamed(RouteManager.JOB_DETAIL, arguments: job);
        break;
    }
  }


  Future<void> _showAllBid(Job job) async {

    BidAccept result = await Navigator.of(context).pushNamed(RouteManager.ALL_BID, arguments: job) as BidAccept;

    if(result != null && result.bid.seeker != null) {

      for(int i=0; i<_jobs.length; i++) {

        if(_jobs[i].id == job.id) {

          setState(() {
            _jobs[i].bid = result.bid;
            _jobs[i].status = Constants.IS_SCHEDULED.toString();
          });

          break;
        }
      }

      setState(() {
        _index = Constants.IS_SCHEDULED;
      });

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }


  Future<void> _showDetails(Job job) async {

    final result = await Navigator.of(context).pushNamed(RouteManager.JOB_DETAIL, arguments: job) as int;

    if(result != null && result == Constants.IS_CANCELLED) {

      setState(() {
        _index = Constants.IS_CANCELLED;
      });

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("job_cancel_success"))));
    }
    if(result != null && result == Constants.IS_COMPLETE) {

      setState(() {
        _index = Constants.IS_COMPLETE;
      });

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("job_complete_success"))));
    }
  }


  void _onItemSelected(int index) {

    switch(index) {

      case 0:
        currentUser.value.roleID == Constants.PROVIDER ? _showPostedJobs() : _showScheduledJobs();
        break;

      case 1:
        currentUser.value.roleID == Constants.PROVIDER ? _showScheduledJobs() : _showCancelledJobs();
        break;

      case 2:
        currentUser.value.roleID == Constants.PROVIDER ? _showCancelledJobs() : _showCompleteJobs();
        break;

      case 3:
        _showCompleteJobs();
        break;
    }
  }


  void _showPostedJobs() {

    setState(() {
      _index = Constants.IS_ACTIVE;
      _icon = Icons.info;
      _color = Colors.blue;
    });
  }


  void _showScheduledJobs() {

    setState(() {
      _index = Constants.IS_SCHEDULED;
      _icon = Icons.schedule;
      _color = Color(0xff0D4F8B);
    });
  }


  void _showCancelledJobs() {

    setState(() {
      _index = Constants.IS_CANCELLED;
      _icon = Icons.cancel;
      _color = Colors.deepOrange;
    });
  }


  void _showCompleteJobs() {

    setState(() {
      _index = Constants.IS_COMPLETE;
      _icon = Icons.check_circle;
      _color = Colors.green;
    });
  }
}