import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/presenter/JobPresenter.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/views/active_jobs.dart';

import 'local_notification.dart';

ValueNotifier<String> deviceToken = ValueNotifier("");

class FCMSetup with ChangeNotifier {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  LocalNotification _localNotification;

  void conFigureFirebase(BuildContext context) {

    _localNotification = LocalNotification();
    _localNotification.initializePlugin(context);

    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );

    _firebaseMessaging.getToken().then((token) {

      print(token);
      deviceToken.value = token;
      _firebaseMessaging.subscribeToTopic(Constants.TOPIC_ALL);
    });

    try {
      _firebaseMessaging.configure(
        onMessage: notificationOnMessage,
        onLaunch: notificationOnLaunch,
        onResume: notificationOnResume,
      );
    } catch (error) {
      print(error);
    }
  }

  void subscribeToTopic(String topic) {

    _firebaseMessaging.subscribeToTopic(topic);
  }

  Future notificationOnResume(Map<String, dynamic> message) async {

    print(message);

    if(message['data']['notification_id'] == Constants.NEW_JOB_POST) {

      _showActiveJob(message);
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {

    print(message);

    if(message['data']['notification_id'] == Constants.NEW_JOB_POST) {

      _showActiveJob(message);
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {

    print(message);

    String title = message['notification']['title'];
    String body = message['notification']['body'];

    if(message['data']['notification_id'] == Constants.NEW_JOB_POST) {

      _localNotification.generalNotification(_localNotification.jobChannelID, _localNotification.jobChannelName, _localNotification.jobChannelDescription, title, body);
      _showActiveJob(message);
    }
    else if(message['data']['notification_id'] == Constants.NEW_BID) {

      _localNotification.generalNotification(_localNotification.jobChannelID, _localNotification.jobChannelName, _localNotification.jobChannelDescription, title, body);
    }
    else if(message['data']['notification_id'] == Constants.BID_ACCEPT) {

      _localNotification.generalNotification(_localNotification.jobChannelID, _localNotification.jobChannelName, _localNotification.jobChannelDescription, title, body);
    }
    else if(message['data']['notification_id'] == Constants.JOB_CANCEL) {

      _localNotification.generalNotification(_localNotification.jobChannelID, _localNotification.jobChannelName, _localNotification.jobChannelDescription, title, body);
    }
    else if(message['data']['notification_id'] == Constants.JOB_COMPLETE) {

      _localNotification.generalNotification(_localNotification.jobChannelID, _localNotification.jobChannelName, _localNotification.jobChannelDescription, title, body);
    }
    else if(message['data']['notification_id'] == Constants.PAYMENT_CONFIRMATION) {

      _localNotification.generalNotification(_localNotification.paymentChannelID, _localNotification.paymentChannelName, _localNotification.paymentChannelDescription, title, body);
    }
    else if(message['data']['notification_id'] == Constants.PAY_COMMISSION) {

      _localNotification.generalNotification(_localNotification.paymentChannelID, _localNotification.paymentChannelName, _localNotification.paymentChannelDescription, title, body);
    }
  }


  void _showActiveJob(Map<String, dynamic> message) {

    try {
      Job job = Job.fromJson(message['data']);

      for(int i=0; i<settings.value.services.list.length; i++) {

        if(settings.value.services.list[i].id == job.serviceID) {

          job.service = settings.value.services.list[i];
          break;
        }
      }

      if(activeJobs.value.list.length == 0) {

        stackIndex.value = 1;
        stackIndex.notifyListeners();
      }

      activeJobs.value.list.add(job);
      activeJobs.value.list.sort((a,b) => b.date.compareTo(a.date));
      activeJobs.notifyListeners();
    }
    catch(e) {
      print(e);
    }
  }
}