import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/home_contract.dart';
import 'package:sobkaj/contract/setting_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/localization/localization_constrants.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/settings.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/api_routes.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:sobkaj/utils/fcm_setup.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/utils/shared_preference.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

ValueNotifier<Settings> settings = ValueNotifier(Settings());

class SettingPresenter with ChangeNotifier {

  SettingContract _settingContract;
  HomeContract _homeContract;
  Connectivity _connectivity;

  MySharedPreference _preference = MySharedPreference();

  SettingPresenter(Connectivity connectivity, {SettingContract settingContract, HomeContract homeContract}) {

    this._connectivity = connectivity;

    if(settingContract != null) {

      this._settingContract = settingContract;
    }

    if(homeContract != null) {

      this._homeContract = homeContract;
    }
  }


  Future<void> getSettings(BuildContext context) async {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      String url = "";

      currentUser.value = await _preference.getUser();

      if(currentUser.value != null && currentUser.value.id != null) {

        url = APIRoute.SETTINGS + "?id=" + currentUser.value.id;
      }
      else {

        url = APIRoute.SETTINGS;
      }

      client.get(

          Uri.encodeFull(url),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Settings", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            settings.value = Settings.fromJson(jsonData['data']['settings']);
            _checkStatus(context);
          }
          else {

            _settingContract.onFailed(context);
          }
        }
        else {

          _settingContract.onFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _settingContract.onFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  Future<void> _checkStatus(BuildContext context) async {

    if(settings.value.accountStatus != null && settings.value.accountStatus.isNotEmpty) {

      switch(settings.value.accountStatus) {

        case Constants.ACTIVE:
          _checkTokenExpiry();
          break;

        case Constants.INACTIVE:
          _settingContract.onAccountNotActive(context, AppLocalization.of(context).getTranslatedValue("account_inactive"));
          break;

        case Constants.SUSPENDED:
          _onSuspended(context);
          break;

        case Constants.CLOSED:
          _settingContract.onAccountNotActive(context, AppLocalization.of(context).getTranslatedValue("account_closed"));
          break;
      }
    }
    else {

      _settingContract.onUserNotFound();
    }
  }


  void _onSuspended(BuildContext context) {

    DateTime suspendDate = DateTime.parse(settings.value.suspendDate);

    if(suspendDate != null) {

      if(DateTime.now().isAfter(suspendDate)) {

        _settingContract.onUserNotFound();
      }
      else {

        String dateTime = MyDateTime.getLocaleDate(suspendDate);

        _settingContract.onAccountNotActive(context, MyApp.appLocale.languageCode == ENGLISH ? (
            AppLocalization.of(context).getTranslatedValue("account_suspended") + " " +
                AppLocalization.of(context).getTranslatedValue("till") + " " + dateTime) :
        (dateTime + " " + AppLocalization.of(context).getTranslatedValue("date") + " " +
            AppLocalization.of(context).getTranslatedValue("till") + AppLocalization.of(context).getTranslatedValue("account_suspended")));
      }
    }
  }


  Future<void> _checkTokenExpiry() async {

    DateTime loginTime = await _preference.getLoginTime();

    if(loginTime != null) {

      int diff = DateTime.now().difference(loginTime).inMinutes;

      if(diff >= currentUser.value.accessToken.expiryTime) {

        _settingContract.onTokenExpired();
      }
      else {

        _settingContract.onUserFound();
      }
    }
  }


  Future<void> getHomeData(BuildContext context) async {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'device_token': deviceToken.value,
      };

      client.post(

          Uri.encodeFull(APIRoute.DASHBOARD),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Daashboard", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Jobs jobs = Jobs.fromJson(jsonData['data']['allData']['upcomingJob']);
            JobServices services = JobServices.fromJson(jsonData['data']['allData']['recommendedServices']);
            Users seekers = Users.fromJson(jsonData['data']['allData']['popularSeeker']);

            _homeContract.onDataFound(jobs, services, seekers);
          }
          else {

            _homeContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_data"));
          }
        }
        else {

          _homeContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_data"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _homeContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_data"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }
}