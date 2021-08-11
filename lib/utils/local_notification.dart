import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';

//add permissions in manifest
//add the receiver in manifest
//add necessary code in AppDelegate.swift/AppDelete.m

class LocalNotification {

  BuildContext context;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  PackageInfo packageInfo;

  String jobChannelID;
  String paymentChannelID;
  String generalChannelID;
  String accountChannelID;

  String jobChannelName = "Job";
  String paymentChannelName = "Payment";
  String generalChannelName = "General";
  String accountChannelName = "Account";

  String jobChannelDescription = "Notitfications related to jobs.";
  String paymentChannelDescription = "Notification related to payments.";
  String generalChannelDescription = "General notifications.";
  String accountChannelDescription = "Your account related notifications.";

  Future initializePlugin(BuildContext context) async {

    this.context = context;
    packageInfo = await PackageInfo.fromPlatform();

    jobChannelID = packageInfo.packageName + "job";
    paymentChannelID = packageInfo.packageName + "payment";
    generalChannelID = packageInfo.packageName + "general";
    accountChannelID = packageInfo.packageName + "account";

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid = AndroidInitializationSettings('notification_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: didReceiveLocalNotification,
    );

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }


  Future selectNotification(String payload) async {

    showDialog(
      context: context,
      builder: (_) {

        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }


  Future<void> didReceiveLocalNotification(int id, String title, String body, String payload) async {

    // iOS does not support notification when app is in foreground
    // so show the notification contents as an dialog

    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(

        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }


  Future<void> generalNotification(String channelID, String channelName, String channelDescription, String title, String body) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelID, channelName, channelDescription,
        importance: Importance.Max,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([500, 1000, 500, 2000]),
        enableLights: true,
        visibility: NotificationVisibility.Public, //shows notification on lock screen
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
        priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show((Random().nextInt(300) + Random().nextInt(150) - Random().nextInt(180)) * Random().nextInt(5), title, body, platformChannelSpecifics);
  }


  Future<void> notificationWithSound(String channelID, String channelName, String channelDescription) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelID, channelName, channelDescription,
        importance: Importance.Max,
        sound: RawResourceAndroidNotificationSound('slow_spring_board'),
        priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(sound: "slow_spring_board.aiff");

    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }


  Future<void> notificationWithDefaultSound(String channelID, String channelName, String channelDescription) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelID, channelName, channelDescription,
        importance: Importance.Max,
        priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }


  Future<void> notificationWithoutSound(String channelID, String channelName, String channelDescription) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(

        channelID, channelName, channelDescription,
        playSound: false,
        importance: Importance.Max,
        priority: Priority.High
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(presentSound: false);

    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
  }


  Future<void> scheduleNotification() async {

    var scheduledNotificationDateTime = DateTime.now().add(Duration(hours: 1));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('your other channel id',
        'your other channel name', 'your other channel description');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }


  Future<void> periodicNotification() async {

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('repeating channel id',
        'repeating channel name', 'repeating description');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.Hourly, platformChannelSpecifics);
  }


  Future<void> dailyNotification() async {

    var time = Time(10, 0, 0);

    var androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name', 'repeatDailyAtTime description');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately ${time.hour}:${time.minute}:${time.second}',
        time,
        platformChannelSpecifics);
  }


  Future<void> weeklyNotification() async {

    var time = Time(10, 0, 0);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('show weekly channel id',
        'show weekly channel name', 'show weekly description');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately ${time.hour}:${time.minute}:${time.second}',
        Day.Monday,
        time,
        platformChannelSpecifics);
  }


  Future<List<PendingNotificationRequest>> getPendingNotificationList() async {

    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }


  Future<void> groupNotification() async {

    String groupKey = 'com.android.example.WORK_EMAIL';
    String groupChannelId = 'grouped channel id';
    String groupChannelName = 'grouped channel name';
    String groupChannelDescription = 'grouped channel description';

    if(Platform.isAndroid) {

      AndroidNotificationDetails firstNotificationAndroidSpecifics = AndroidNotificationDetails(
          groupChannelId, groupChannelName, groupChannelDescription,
          importance: Importance.Max,
          priority: Priority.High,
          groupKey: groupKey);

      NotificationDetails firstNotificationPlatformSpecifics = NotificationDetails(firstNotificationAndroidSpecifics, null);

      await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
          'You will not believe...', firstNotificationPlatformSpecifics);

      AndroidNotificationDetails secondNotificationAndroidSpecifics = AndroidNotificationDetails(
          groupChannelId, groupChannelName, groupChannelDescription,
          importance: Importance.Max,
          priority: Priority.High,
          groupKey: groupKey);

      NotificationDetails secondNotificationPlatformSpecifics = NotificationDetails(secondNotificationAndroidSpecifics, null);

      await flutterLocalNotificationsPlugin.show(
          2,
          'Jeff Chang',
          'Please join us to celebrate the...',
          secondNotificationPlatformSpecifics);

      // create the summary notification required for older devices that pre-date Android 7.0 (API level 24)
      List<String> lines = List<String>();
      lines.add('Alex Faarborg  Check this out');
      lines.add('Jeff Chang    Launch Party');

      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
          lines,
          contentTitle: '2 new messages',
          summaryText: 'janedoe@example.com');

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          groupChannelId, groupChannelName, groupChannelDescription,
          styleInformation: inboxStyleInformation,
          groupKey: groupKey,
          setAsGroupSummary: true);

      NotificationDetails platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, null);

      await flutterLocalNotificationsPlugin.show(
          3, 'Attention', 'Two new messages', platformChannelSpecifics);
    }
  }


  Future<void> cancelNotification(int id) async {

    await flutterLocalNotificationsPlugin.cancel(id);
  }


  Future<void> cancelAllNotification() async {

    await flutterLocalNotificationsPlugin.cancelAll();
  }


  Future<bool> wasAppLaunched() async {

    var notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return notificationAppLaunchDetails.didNotificationLaunchApp;
  }
}