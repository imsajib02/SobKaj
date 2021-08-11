import 'package:flutter/material.dart';
import 'package:sobkaj/presenter/setting_presenter.dart';
import 'package:package_info/package_info.dart';
import 'package:sobkaj/widgets/update_dialog.dart';

class UpdateCheck {

  static Future<void> checkForUpdate(BuildContext context) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    try {

      if(settings.value != null && settings.value.appVersionCode != null && settings.value.appVersionCode.isNotEmpty) {

        if(int.parse(settings.value.appVersionCode) > int.parse(packageInfo.buildNumber)) {

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {

              return UpdateDialog();
            },
          );
        }
      }
    }
    catch(error) {

      print(error);
    }
  }
}