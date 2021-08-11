import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/payment_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/payment.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/api_routes.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_overlay_loader.dart';
import 'package:http/http.dart' as http;

class PaymentPresenter {

  PaymentContract _contract;
  Connectivity _connectivity;

  MyOverlayLoader _myOverlayLoader;

  PaymentPresenter(this._contract, this._connectivity);


  void getPayouts(BuildContext context) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
      };

      client.post(

          Uri.encodeFull(APIRoute.PAYOUTS),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "All Payouts", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.NO_PAYOUT) {

              _contract.onPaymentFailed(context);
            }
            else {

              Payouts payouts = Payouts.fromJson(jsonData['data']['payoutList']);
              String totalDue = jsonData['data']['totalDue'].toString();

              _contract.showAllPayout(payouts, totalDue);
            }
          }
          else {

            _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_payouts"));
          }
        }
        else {

          _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_payouts"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _contract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_payouts"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }
}