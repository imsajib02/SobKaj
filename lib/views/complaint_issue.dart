import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sobkaj/contract/complaint_contact.dart';
import 'package:sobkaj/models/complaint.dart';
import 'package:sobkaj/models/constructor/complaint_submit.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/constants.dart';
import '../contract/connectivity_contract.dart';
import '../localization/app_localization.dart';
import '../presenter/JobPresenter.dart';
import '../utils/bounce_animation.dart';
import '../utils/my_connectivity_checker.dart';
import '../widgets/connection_alert.dart';

class ComplaintIssue extends StatefulWidget {

  final String _jobId;

  ComplaintIssue(this._jobId);

  @override
  _ComplaintIssueState createState() => _ComplaintIssueState();
}

class _ComplaintIssueState extends State<ComplaintIssue> with TickerProviderStateMixin implements ComplaintContract, Connectivity {

  JobPresenter _presenter;

  ComplaintContract _contract;
  Connectivity _connectivity;

  MyConnectivityChecker _connectivityChecker;
  ConnectionAlert _connectionAlert;

  TextEditingController _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _bounceKey = GlobalKey<BounceState>();


  @override
  void initState() {

    _connectionAlert = ConnectionAlert(this);
    _connectivityChecker = MyConnectivityChecker();

    _contract = this;
    _connectivity = this;
    _presenter = JobPresenter(_connectivity, complaintContract: _contract);

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
          title: Text(AppLocalization.of(context).getTranslatedValue("submit_complaint"),
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

                      Text(currentUser.value.roleID == Constants.PROVIDER ? AppLocalization.of(context).getTranslatedValue("provide_complaint_against_seeker") :
                      AppLocalization.of(context).getTranslatedValue("provide_complaint_against_provider"),
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
                              minLines: 10,
                              validator: (value) {

                                if(value == null || value.isEmpty) {
                                  return AppLocalization.of(context).getTranslatedValue("cant_be_empty");
                                }

                                return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(500),
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
  void onComplaintPostFailed(BuildContext context, String message) {

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void onComplaintSaved(BuildContext context, Complaint complaint) {

    Navigator.pop(context, ComplaintSubmit(complaint: complaint, message: AppLocalization.of(context).getTranslatedValue("complaint_post_success")));
  }


  void _validate(BuildContext context) {

    if(_formKey.currentState.validate()) {

      _presenter.submitComplaint(context, Complaint(jobId: widget._jobId, message: _controller.text));
    }
  }
}