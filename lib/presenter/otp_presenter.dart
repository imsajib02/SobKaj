import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/otp_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/time_out.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/digit_translator.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_overlay_loader.dart';

ValueNotifier<int> resendingToken = ValueNotifier(0);
ValueNotifier<String> verificationID = ValueNotifier("");
ValueNotifier<TimeOut> timeOut = ValueNotifier(TimeOut(time: 60, timeInBangla: ""));

class OtpPresenter with ChangeNotifier {

  OtpContract _contract;
  Connectivity _connectivity;

  MyOverlayLoader _myOverlayLoader;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthCredential _authCredential;
  Timer _timer;

  OtpPresenter(this._contract, this._connectivity);


  void sendOTP(BuildContext context, User user, String type) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      String phoneNumber = "+88" + user.phone;

      _myOverlayLoader = MyOverlayLoader(context);
      Overlay.of(context).insert(_myOverlayLoader.loader);

      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 0),
        verificationCompleted: (authCredential) {},
        verificationFailed: (authException) {

          print(authException.message);

          _myOverlayLoader.loader.remove();
          _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_send_otp"));
        },
        codeSent: (verificationId, [token]) {

          resendingToken.value = token;
          resendingToken.notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {

          _myOverlayLoader.loader.remove();

          verificationID.value = verificationId;
          verificationID.notifyListeners();

          _onOtpSent(type, user);
        },
      );
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void _onOtpSent(String type, User user) {

    switch(type) {

      case Constants.SIGN_UP:
        _contract.onSignUpOtpSent();
        break;

      case Constants.PHONE_VERIFY:
        break;

      case Constants.NEW_PHONE_VERIFY:
        _contract.onNewPhoneVerifyOtpSent(user);
        break;

      case Constants.PASSWORD_RESET:
        _contract.onResetPasswordOtpSent();
        break;
    }
  }


  Future<void> startCountDown() async {

    timeOut.value.time = 60;
    timeOut.value.timeInBangla = await DigitTranslator.toBangla(timeOut.value.time);

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {

      if(timeOut.value.time == 0) {

        timer.cancel();
      }
      else if(timeOut.value.time > 0) {

        timeOut.value.time = timeOut.value.time - 1;
        timeOut.value.timeInBangla = await DigitTranslator.toBangla(timeOut.value.time);
        timeOut.notifyListeners();
      }
    });
  }


  void resendCode(BuildContext context, String phone) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      if(resendingToken.value != null) {

        String phoneNumber = "+88" + phone;

        _myOverlayLoader = MyOverlayLoader(context);
        Overlay.of(context).insert(_myOverlayLoader.loader);

        _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 0),
          forceResendingToken: resendingToken.value,
          verificationCompleted: (authCredential) {},
          verificationFailed: (authException) {

            print(authException.message);

            _myOverlayLoader.loader.remove();
            _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_resend_otp"));
          },
          codeSent: (verificationId, [token]) {

            resendingToken.value = token;
            resendingToken.notifyListeners();
          },
          codeAutoRetrievalTimeout: (verificationId) {

            _myOverlayLoader.loader.remove();

            verificationID.value = verificationId;
            verificationID.notifyListeners();

            startCountDown();
          },
        );
      }
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void verifyCode(BuildContext context, String code) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _authCredential = PhoneAuthProvider.getCredential(verificationId: verificationID.value, smsCode: code);

      _myOverlayLoader = MyOverlayLoader(context);
      Overlay.of(context).insert(_myOverlayLoader.loader);

      _firebaseAuth.signInWithCredential(_authCredential).then((authResult) async {

        if(authResult.user != null) {

          _contract.onOtpVerified(context, _myOverlayLoader.loader);
        }
        else {

          _myOverlayLoader.loader.remove();
          _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_verify_otp"));
        }
      }).catchError((error) async {

        _myOverlayLoader.loader.remove();

        if(error.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {

          _contract.onInvalidOtp(context);
        }
        else {

          _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_verify_otp"));
        }
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void stopCountDown() {

    if(_timer != null && _timer.isActive) {

      _timer.cancel();
    }
  }
}