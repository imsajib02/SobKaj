import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sobkaj/contract/review_contract.dart';
import 'package:sobkaj/models/constructor/review_submit.dart';
import 'package:sobkaj/models/review.dart';
import '../contract/connectivity_contract.dart';
import '../localization/app_localization.dart';
import '../presenter/JobPresenter.dart';
import '../utils/bounce_animation.dart';
import '../utils/my_connectivity_checker.dart';
import '../widgets/connection_alert.dart';

class JobReview extends StatefulWidget {

  final String _jobId;

  JobReview(this._jobId);

  @override
  _JobReviewState createState() => _JobReviewState();
}

class _JobReviewState extends State<JobReview> with TickerProviderStateMixin implements ReviewContract, Connectivity {

  JobPresenter _presenter;

  ReviewContract _contract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  int _value = 0;

  TextEditingController _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _bounceKey = GlobalKey<BounceState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _contract = this;
    _connectivity = this;
    _presenter = JobPresenter(_connectivity, reviewContract: _contract);

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
          title: Text(AppLocalization.of(context).getTranslatedValue("give_feedback"),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {

            return Padding(
              padding: EdgeInsets.only(top: 40),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[

                      Text(AppLocalization.of(context).getTranslatedValue("rate_seeker"),
                        style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w400),
                      ),

                      SizedBox(height: 30,),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(5, (index) {

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {

                                setState(() {
                                  _value = index + 1;
                                });
                              },
                              child: Icon(
                                index < _value ? Icons.star : Icons.star_border,
                                size: 40,
                                color: index < _value ? Colors.yellow : Colors.grey[400],
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 30,),

                      Divider(height: 1, color: Colors.black38,),

                      SizedBox(height: 30,),

                      Text(AppLocalization.of(context).getTranslatedValue("review_job"),
                        style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w400),
                      ),

                      SizedBox(height: 20,),

                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[

                            TextFormField(
                              controller: _controller,
                              style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.normal),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (string) {
                                _validate(context);
                              },
                              maxLines: null,
                              minLines: 8,
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }

                                return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(250),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(width: 0, style: BorderStyle.none,),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                contentPadding: EdgeInsets.all(10),
                                fillColor: Colors.white70,
                                filled: true
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 100,),

                      Container(
                        height: 45,
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
                                AppLocalization.of(context).getTranslatedValue("submit"),
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40,),
                    ],
                  ),
                ),
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
  void onReviewPostFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onReviewSaved(BuildContext context, Review review) {

    Navigator.pop(context, ReviewSubmit(review: review, message: AppLocalization.of(context).getTranslatedValue("review_post_success")));
  }


  @override
  void showAllReview(Reviews reviews) {}


  void _validate(BuildContext context) {

    if(_value == 0) {

      Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalization.of(context).getTranslatedValue("rate_seeker"))));
    }
    else if(_formKey.currentState.validate()) {

      _presenter.submitReview(context, Review(rating: _value.toString(), review: _controller.text, jobId: widget._jobId));
    }
  }


  @override
  void failedToGetReviews(BuildContext context) {}
}