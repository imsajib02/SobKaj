import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/shared_preference.dart';
import 'package:sobkaj/widgets/login_expired.dart';

class AuthExpiry {

  MySharedPreference _preference = MySharedPreference();
  Timer _timer;

  Future<void> start(BuildContext context) async {

    Timer.periodic(Duration(seconds: 2), (timer) async {

      _timer = timer;

      DateTime loginTime = await _preference.getLoginTime();

      if(loginTime != null) {

        int diff = DateTime.now().difference(loginTime).inMinutes;

        if(diff >= currentUser.value.accessToken.expiryTime) {

          stop();

          await _preference.remove(MySharedPreference.LOGGED_USER);
          await _preference.remove(MySharedPreference.LOGIN_TIME);

          currentUser.value = null;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {

              return LoginExpired();
            },
          );
        }
      }
    });
  }


  void stop() {

    if(_timer != null && _timer.isActive) {

      _timer.cancel();
    }
  }
}