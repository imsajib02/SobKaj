import 'dart:async';
import 'package:flutter/material.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:sobkaj/widgets/connection_alert.dart';

ValueNotifier<bool> isConnected = ValueNotifier(true);

class MyConnectivityChecker with ChangeNotifier {

  ConnectionAlert _connectionAlert;
  DataConnectionChecker _connectionChecker = DataConnectionChecker();

  StreamSubscription<DataConnectionStatus> _connectionStatus;

  MyConnectivityChecker({ConnectionAlert connectionAlert}) {

    if(connectionAlert != null) {
      this._connectionAlert = connectionAlert;
    }

    _connectionChecker.checkInterval = const Duration(milliseconds: 500);

    _connectionStatus = _connectionChecker.onStatusChange.listen((status) {

      switch(status) {

        case DataConnectionStatus.connected:
          isConnected.value = true;
          isConnected.notifyListeners();
          _onStatusChange();
          break;

        case DataConnectionStatus.disconnected:
          isConnected.value = false;
          isConnected.notifyListeners();
          _onStatusChange();
          break;
      }
    });
  }

  void removeStatusListener() {

    if(_connectionAlert != null) {

      _connectionAlert.controller.dispose();
    }

    _connectionStatus.cancel();
  }

  void _onStatusChange() {

    if(_connectionAlert != null) {

      if(isConnected.value && !_connectionAlert.controller.isCompleted) {

        _connectionAlert.controller.forward();
      }
      else if(_connectionAlert.controller.isCompleted) {

        _connectionAlert.controller.reverse();
      }
    }
  }
}