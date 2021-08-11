import 'package:flutter/material.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io' show Platform;

class UpdateDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

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

              Icon(Icons.info, color: Colors.green, size: 30),

              SizedBox(width: 15,),

              Text(AppLocalization.of(context).getTranslatedValue("app_update"), style: Theme.of(context).textTheme.headline4),
            ],
          ),
        ),
        content: Text(AppLocalization.of(context).getTranslatedValue("app_update_msg"),
          textAlign: TextAlign.justify,
          style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        contentPadding: EdgeInsets.only(left: 30, top: 20, bottom: 20, right: 30),
        actionsPadding: EdgeInsets.only(right: 20, bottom: 10, top: 5),
        actions: <Widget> [

          FlatButton(
            color: Colors.lightBlueAccent,
            textColor: Colors.white,
            child: Text(AppLocalization.of(context).getTranslatedValue("update")),
            onPressed: () {

              Navigator.of(context).pop();
              _launchURL(Platform.isAndroid ? settings.value.playStoreUrl : settings.value.appStoreUrl);
            },
          ),
        ],
      ),
    );
  }


  Future<void> _launchURL(String url) async {

    if(await canLaunch(url)) {

      CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Launching URL", message: url);
      await launch(url);
    }
    else {

      CustomLogger.error(trace: CustomTrace(StackTrace.current), tag: "Failed To Launch URL", message: url);
      throw 'Could not launch $url';
    }
  }
}