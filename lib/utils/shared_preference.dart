import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sobkaj/localization/localization_constrants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobkaj/models/user.dart';

class MySharedPreference {

  Future<SharedPreferences> _prefs;

  static const String LANGUAGE_CODE = "bhj6GF4Bu7gY";
  static const String LOGGED_USER = "gG5DTRD6chG";
  static const String FIRST_OPEN = "bbJHFVf56rtG";
  static const String LOGIN_TIME = "jbdeifyffuy";

  MySharedPreference() {
    _prefs = SharedPreferences.getInstance();
  }


  Future<Locale> saveLanguageCode(String languageCode) async {

    final SharedPreferences prefs = await _prefs;
    await prefs.setString(LANGUAGE_CODE, languageCode);

    return getLocale(languageCode);
  }


  Future<Locale> getLanguageCode() async {

    final SharedPreferences prefs = await _prefs;
    String languageCode = prefs.getString(LANGUAGE_CODE) ?? ENGLISH;

    return getLocale(languageCode);
  }


  Future<void> setLoginTime(DateTime dateTime) async {

    final SharedPreferences prefs = await _prefs;
    await prefs.setString(LOGIN_TIME, dateTime.toString());
  }


  Future<DateTime> getLoginTime() async {

    final SharedPreferences prefs = await _prefs;

    DateTime dateTime;

    if(prefs.containsKey(LOGIN_TIME)) {

      String data = await prefs.get(LOGIN_TIME);
      dateTime = DateTime.parse(data);
    }

    return dateTime;
  }


  Future<void> setCurrentUser(User user) async {

    final SharedPreferences prefs = await _prefs;
    await prefs.setString(LOGGED_USER, json.encode(user.toJson()));
  }


  Future<User> getUser() async {

    final SharedPreferences prefs = await _prefs;
    User user = User();

    if(prefs.containsKey(LOGGED_USER)) {

      var data = json.decode(await prefs.get(LOGGED_USER));
      user = User.fromJson(data);
    }

    return user;
  }


  onFirstOpened() async {

    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(FIRST_OPEN, false);
  }


  Future<bool> isOpenedFirst() async {

    final SharedPreferences prefs = await _prefs;

    if(prefs.containsKey(FIRST_OPEN)) {

      bool val = prefs.getBool(FIRST_OPEN);
      return val;
    }

    return true;
  }


  Future<Set<String>> getAllKeys() async {

    final SharedPreferences prefs = await _prefs;
    return prefs.getKeys();
  }


  Future<bool> clearAllData() async {

    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }


  Future remove(String key) async {

    final SharedPreferences prefs = await _prefs;

    if(prefs.containsKey(key)) {
      await prefs.remove(key);
    }
  }
}