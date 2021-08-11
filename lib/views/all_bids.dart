import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/contract/bid_contract.dart';
import 'package:sobkaj/models/bid.dart';
import 'package:sobkaj/models/constructor/bid_accept.dart';
import 'package:sobkaj/resources/images.dart';
import 'package:sobkaj/route/route_manager.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/widgets/bid_accept_dialog.dart';
import '../contract/connectivity_contract.dart';
import '../localization/app_localization.dart';
import '../models/job.dart';
import '../presenter/JobPresenter.dart';
import '../utils/bounce_animation.dart';
import '../utils/my_connectivity_checker.dart';
import '../utils/my_datetime.dart';
import '../widgets/connection_alert.dart';

class AllBid extends StatefulWidget {

  final Job _job;

  AllBid(this._job);

  @override
  _AllBidState createState() => _AllBidState();
}

class _AllBidState extends State<AllBid> with TickerProviderStateMixin implements BidContract, Connectivity {

  JobPresenter _presenter;

  BidContract _contract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  int _stackIndex = 0;
  bool _isCallMade = false;

  BuildContext _context;

  Bids _bids = Bids(list: List());
  final _bounceKey = GlobalKey<BounceState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _contract = this;
    _connectivity = this;
    _presenter = JobPresenter(_connectivity, bidContract: _contract);

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
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 3,
          centerTitle: true,
          title: Text(AppLocalization.of(context).getTranslatedValue("all_bid"),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            _context = context;

            if(!_isCallMade) {

              _isCallMade = true;
              _getAllBid(context);
            }

            return RefreshIndicator(
              backgroundColor: Colors.orange,
              displacement: 20,
              onRefresh: () async {

                _getAllBid(context);
              },
              child: IndexedStack(
                index: _stackIndex,
                children: <Widget>[

                  Stack(
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.only(top: 130),
                        child: ListView.separated(
                          itemCount: _bids.list.length,
                          padding: EdgeInsets.only(top: 5, bottom: 30),
                          separatorBuilder: (context, index) {

                            return Visibility(
                              visible: _bids.list[index].status == Constants.ACTIVE,
                              child: SizedBox(height: 40,),
                            );
                          },
                          itemBuilder: (context, index) {

                            return Visibility(
                              visible: _bids.list[index].status == Constants.ACTIVE,
                              child: Padding(
                                padding: EdgeInsets.only(left: index % 2 == 0 ? 15 : 65, right: index % 2 == 0 ? 65 : 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Material(
                                      elevation: 4,
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[

                                          IntrinsicHeight(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[

                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: () {

                                                      Navigator.of(context).pushNamed(RouteManager.SEEKER_INFO, arguments: _bids.list[index].seeker);
                                                    },
                                                    child: Hero(
                                                      tag: _bids.list[index].seekerId,
                                                      child: _bids.list[index].seeker.avatar == null || _bids.list[index].seeker.avatar.isEmpty ? Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                                                          image: DecorationImage(
                                                            image: AssetImage(Images.noImage),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ) : Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                                                          image: DecorationImage(
                                                            image: CachedNetworkImageProvider(_bids.list[index].seeker.avatar),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[

                                                      Padding(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text("৳" + _bids.list[index].fee,
                                                          textAlign: TextAlign.start,
                                                          style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w400),
                                                        ),
                                                      ),

                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border(top: BorderSide(width: 1, color: Colors.black12))
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8),
                                                          child: Text(_bids.list[index].note,
                                                            textAlign: TextAlign.justify,
                                                            style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w400),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {

                                              _confirmBidAccept(context, _bids.list[index]);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(top: 8, bottom: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(.75),
                                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                                              ),
                                              child: Text(AppLocalization.of(context).getTranslatedValue("confirm").toUpperCase(),
                                                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    Align(
                                      alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8, right: index % 2 == 0 ? 0 : 10, left: index % 2 == 0 ? 10 : 0),
                                        child: Text(MyDateTime.getDateTime(DateTime.parse(_bids.list[index].updatedAt)),
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[

                            Text(widget._job.title,
                              style: Theme.of(context).textTheme.headline2.copyWith(fontWeight: FontWeight.normal, color: Colors.black.withOpacity(.65)),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(AppLocalization.of(context).getTranslatedValue("pull_to_refresh"),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text(AppLocalization.of(context).getTranslatedValue("click_for_seeker_details"),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                            _getAllBid(context);
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

                  Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 7,
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(AppLocalization.of(context).getTranslatedValue("no_bids"),
                        style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
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


  void _getAllBid(BuildContext context) {

    try {

      setState(() {
        _stackIndex = 2;
      });
    }
    catch(error) {

      _stackIndex = 2;
    }

    _presenter.allBid(context, widget._job.id);
  }


  @override
  void failedToGetBids(BuildContext context) {

    setState(() {
      _stackIndex = 1;
    });

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("failed_to_get_bids"))));
  }


  @override
  void onAlreadyBid(BuildContext context) {}


  @override
  void onBiddingFailed(BuildContext context) {}


  @override
  void onBiddingSuccess(BuildContext context) {}


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
  void showAllBid(Bids bids) {

    setState(() {
      _bids = bids;
      _stackIndex = 0;
    });
  }


  @override
  void onNoBids(BuildContext context) {

    setState(() {
      _stackIndex = 3;
    });

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("no_bids_found"))));
  }


  @override
  void onBidAcceptFailed(BuildContext context) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("failed_to_accept_bid"))));
  }


  @override
  void onBidAccepted(BuildContext context, Bid bid) {

    Navigator.pop(context, BidAccept(bid: bid, message: AppLocalization.of(context).getTranslatedValue("bid_accept_success")));
  }


  void _confirmBidAccept(BuildContext context, Bid bid) {

    showDialog(
        context: context,
        builder: (context) {

          return BidAcceptDialog(
            onSubmit: (note) {

              _presenter.acceptBid(_context, bid.id, note);
            },
          );
        }
    );
  }


  @override
  void onBidCancelled(BuildContext context, String bidId) {}
}