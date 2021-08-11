import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/login_contract.dart';
import 'package:sobkaj/contract/profile_contract.dart';
import 'package:sobkaj/contract/signup_contract.dart';
import 'package:sobkaj/contract/user_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/localization/localization_constrants.dart';
import 'package:sobkaj/main.dart';
import 'package:sobkaj/models/access_token.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/utils/api_routes.dart';
import 'package:sobkaj/utils/constants.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:sobkaj/utils/fcm_setup.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_datetime.dart';
import 'package:sobkaj/utils/my_overlay_loader.dart';
import 'package:sobkaj/utils/shared_preference.dart';

ValueNotifier<User> currentUser = ValueNotifier(User());

class UserPresenter with ChangeNotifier {

  LoginContract _loginContract;
  SignUpContract _signUpContract;
  ProfileContract _profileContract;
  UserContract _userContract;
  Connectivity _connectivity;

  MySharedPreference _preference = MySharedPreference();
  MyOverlayLoader _myOverlayLoader;

  UserPresenter(Connectivity connectivity, {LoginContract loginContract, SignUpContract signUpContract,
    ProfileContract profileContract, UserContract userContract}) {

    this._connectivity = connectivity;

    if(loginContract != null) {
      this._loginContract = loginContract;
    }

    if(signUpContract != null) {
      this._signUpContract = signUpContract;
    }

    if(profileContract != null) {
      this._profileContract = profileContract;
    }

    if(userContract != null) {
      this._userContract = userContract;
    }
  }


  void login(BuildContext context, User user) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.post(

          Uri.encodeFull(APIRoute.LOGIN),
          body: user.toJson(),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Login", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            currentUser.value = User.fromJson(jsonData['data']['user']);
            currentUser.value.accessToken = AccessToken.fromJson(jsonData['data']);

            if(currentUser.value.accessToken != null && currentUser.value.accessToken.token != null) {

              _checkStatus(context);
            }
            else {

              _onLoginFailed(context);
            }
          }
          else {

            if(jsonData['errors']['login'] == Constants.INVALID_PHONE_OR_PASSWORD) {

              _loginContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("invalid_phone_or_pass"));
            }
            else {

              _onLoginFailed(context);
            }
          }
        }
        else if(response.statusCode == 401) {

          if(jsonData['message'] == Constants.UNAUTHORIZED) {

            _loginContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("unauthorized_request"));
          }
          else {

            _onLoginFailed(context);
          }
        }
        else {

          _onLoginFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _onLoginFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void _onLoginFailed(BuildContext context) {

    _loginContract.onFailed(context, AppLocalization.of(context).getTranslatedValue("failed_to_login"));
  }


  void validateUser(BuildContext context, String phone) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.get(

          Uri.encodeFull(APIRoute.USER + "?phone=$phone"),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "User", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            User user = User.fromJson(jsonData['data']['user']);

            if(user != null && user.id != null && user.id.isNotEmpty) {

              _userContract.onUserExists(context);
            }
            else {

              _userContract.onUserNotFound(context);
            }
          }
          else {

            if(jsonData['message'] == Constants.INVALID_USER) {

              _userContract.onUserNotFound(context);
            }
            else {

              _userContract.onValidateFailed(context);
            }
          }
        }
        else {

          _userContract.onValidateFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _userContract.onValidateFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  Future<void> signUp(BuildContext context, User user, OverlayEntry loader, bool hasFailed) async {

    if(isConnected.value) {

      if(hasFailed) {
        Overlay.of(context).insert(loader);
      }

      var request = http.MultipartRequest("POST", Uri.parse(APIRoute.REGISTER));

      request.fields['role_id'] = user.roleID;
      request.fields['name'] = user.name;
      request.fields['phone'] = user.phone;

      if(user.email != null && user.email.isNotEmpty) {
        request.fields['email'] = user.email;
      }

      request.fields['password'] = user.password;
      request.fields['birth_date'] = user.birthDate;
      request.fields['gender'] = user.gender;
      request.fields['providing_job'] = user.providingJobAs;
      request.fields['device_token'] = deviceToken.value;

      if(user.services != null && user.services.list.length > 0) {

        List<String> mList = [];

        user.services.list.forEach((service) {

          mList.add(service.id);
        });

        request.fields['services'] = json.encode(mList);
      }

      var multipartFile;

      if(user.attachment != null && user.attachment.isNotEmpty) {

        multipartFile = await http.MultipartFile.fromPath('attachment', user.attachment);
        request.files.add(multipartFile);
      }

      if(user.cvAttachment != null && user.cvAttachment.isNotEmpty) {

        multipartFile = await http.MultipartFile.fromPath('cv_attachment', user.cvAttachment);
        request.files.add(multipartFile);
      }

      Map<String, String> headers = {"Accept" : "application/json"};
      request.headers.addAll(headers);

      http.StreamedResponse streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Registration", message: response.body);

      var jsonData = json.decode(response.body);

      if(loader != null) {
        loader.remove();
      }

      if(response.statusCode == 200 || response.statusCode == 201) {

        if(jsonData['status']) {

          currentUser.value = User.fromJson(jsonData['data']['user']);
          currentUser.value.accessToken = AccessToken.fromJson(jsonData['data']);

          if(currentUser.value.accessToken != null && currentUser.value.accessToken.token != null) {

            _saveCredential();
            _subscribe(currentUser.value.roleID);
            _signUpContract.onSignUpSuccess();
          }
          else {

            _signUpContract.onSignUpFailed(context);
          }
        }
        else {

          if(jsonData['errors'] != null && jsonData['errors']['phone'] != null) {

            if(jsonData['errors']['phone'].first.toString() == Constants.PHONE_ALREADY_TAKEN) {

              _signUpContract.onInvalidData(context, AppLocalization.of(context).getTranslatedValue("phone_number_taken"));
            }
          }
          else if(jsonData['errors'] != null && jsonData['errors']['email'] != null) {

            if(jsonData['errors']['email'].first.toString() == Constants.EMAIL_ALREADY_TAKEN) {

              _signUpContract.onInvalidData(context, AppLocalization.of(context).getTranslatedValue("email_taken"));
            }
          }
          else {

            _signUpContract.onSignUpFailed(context);
          }
        }
      }
      else {

        _signUpContract.onSignUpFailed(context);
      }
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void _checkStatus(BuildContext context) {

    switch(currentUser.value.status) {

      case Constants.ACTIVE:
        _saveCredential();
        _loginContract.onSuccess();
        break;

      case Constants.INACTIVE:
        _loginContract.onAccountNotActive(context, AppLocalization.of(context).getTranslatedValue("account_inactive"));
        break;

      case Constants.SUSPENDED:
        _onSuspended(context);
        break;

      case Constants.CLOSED:
        _loginContract.onAccountNotActive(context, AppLocalization.of(context).getTranslatedValue("account_closed"));
        break;
    }
  }


  Future<void> _saveCredential() async {

    await FilePicker.clearTemporaryFiles();

    _preference.setCurrentUser(currentUser.value);
    _preference.setLoginTime(DateTime.now());
  }


  void _subscribe(String roleID) {

    switch(roleID) {

      case Constants.PROVIDER:
        FCMSetup().subscribeToTopic(Constants.TOPIC_PROVIDER);
        break;

      case Constants.SEEKER:
        FCMSetup().subscribeToTopic(Constants.TOPIC_SEEKER);
        break;
    }
  }


  void _onSuspended(BuildContext context) {

    DateTime suspendDate = DateTime.parse(currentUser.value.suspendDate);

    if(suspendDate != null) {

      if(DateTime.now().isAfter(suspendDate)) {

        _saveCredential();
        _loginContract.onSuccess();
      }
      else {

        String dateTime = MyDateTime.getLocaleDate(suspendDate);

        _loginContract.onAccountNotActive(context, MyApp.appLocale.languageCode == ENGLISH ? (
            AppLocalization.of(context).getTranslatedValue("account_suspended") + " " +
                AppLocalization.of(context).getTranslatedValue("till") + " " + dateTime) :
        (dateTime + " " + AppLocalization.of(context).getTranslatedValue("date") + " " +
            AppLocalization.of(context).getTranslatedValue("till") + AppLocalization.of(context).getTranslatedValue("account_suspended")));
      }
    }
  }


  void changePassword(BuildContext context, User user) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.post(

          Uri.encodeFull(APIRoute.CHANGE_PASSWORD),
          body: user.changePassword(),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Change Password", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status'] && jsonData['message'] == Constants.PASSWORD_CHANGED) {

            _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("password_changed"));
          }
          else {

            if(jsonData['message'] == Constants.CURRENT_PASSWORD_DOES_NOT_MATCH) {

              _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("current_password_dont_match"));
            }
            else {

              _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_changed_failed"));
            }
          }
        }
        else if(response.statusCode == 401) {

          if(jsonData['message'] == Constants.UNAUTHORIZED) {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("unauthorized_request"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_changed_failed"));
          }
        }
        else {

          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_changed_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_changed_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void changePhone(BuildContext context, User user, OverlayEntry loader, bool hasFailed) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      if(hasFailed) {
        Overlay.of(context).insert(loader);
      }

      var client = http.Client();

      try {

        client.post(

            Uri.encodeFull(APIRoute.UPDATE_PROFILE),
            body: user.phoneChange(),
            headers: {"Accept" : "application/json"}

        ).then((response) async {

          CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Change Phone", message: response.body);

          var jsonData = json.decode(response.body);

          if(response.statusCode == 200 || response.statusCode == 201) {

            if(jsonData['status']) {

              User user = User.fromJson(jsonData['data']['user']);
              currentUser.value.phone = user.phone;
              currentUser.notifyListeners();

              _preference.setCurrentUser(currentUser.value);
              _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("phone_changed"));
            }
            else {

              _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("phone_changed_failed"));
            }
          }
          else if(response.statusCode == 401) {

            if(jsonData['message'] == Constants.UNAUTHORIZED) {

              _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("unauthorized_request"));
            }
            else {

              _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("phone_changed_failed"));
            }
          }
          else if(response.statusCode == 500) {

            _profileContract.onPhoneNumberTaken(context);
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("phone_changed_failed"));
          }

        }).timeout(Duration(seconds: 5), onTimeout: () {

          client.close();
          _connectivity.onTimeout(context);

        }).whenComplete(() {

          loader.remove();

        }).catchError((error) {

          print(error);
          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("phone_changed_failed"));
        });
      }
      catch(error) {

        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("error_occurred"));
      }
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  Future<void> updateAvatar(BuildContext context, File file) async {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      Overlay.of(context).insert(_myOverlayLoader.loader);

      var request = http.MultipartRequest("POST", Uri.parse(APIRoute.UPDATE_PROFILE));

      request.fields['token'] = currentUser.value.accessToken.token;
      request.fields['update_id'] = currentUser.value.id;

      var multipartFile;

      if(file != null && file.path != null && file.path.isNotEmpty) {

        multipartFile = await http.MultipartFile.fromPath('avatar', file.path);
        request.files.add(multipartFile);
      }

      Map<String, String> headers = {"Accept" : "application/json"};
      request.headers.addAll(headers);

      http.StreamedResponse streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Avatar Update", message: response.body);

      var jsonData = json.decode(response.body);

      _myOverlayLoader.loader.remove();

      if(response.statusCode == 200 || response.statusCode == 201) {

        if(jsonData['status']) {

          User user = User.fromJson(jsonData['data']['user']);
          currentUser.value.avatar = user.avatar;
          currentUser.notifyListeners();

          _preference.setCurrentUser(currentUser.value);
          _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("avatar_changed"));
        }
        else {

          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("avatar_changed_failed"));
        }
      }
      else {

        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("avatar_changed_failed"));
      }
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void updateProfile(BuildContext context, User user) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'update_id': currentUser.value.id,
        'name': user.name,
      };

      if(user.email != null && user.email.isNotEmpty) {

        body['email'] = user.email;
      }

      if(user.address != null && user.address.isNotEmpty) {

        body['address'] = user.address;
      }

      client.post(

          Uri.encodeFull(APIRoute.UPDATE_PROFILE),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Profile Update", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            User user = User.fromJson(jsonData['data']['user']);

            currentUser.value.name = user.name;
            currentUser.value.email = user.email;
            currentUser.value.address = user.address;

            currentUser.notifyListeners();

            _preference.setCurrentUser(currentUser.value);
            _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("profile_updated"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("profile_updated_failed"));
          }
        }
        else if(response.statusCode == 401) {

          if(jsonData['message'] == Constants.UNAUTHORIZED) {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("unauthorized_request"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("profile_updated_failed"));
          }
        }
        else if(response.statusCode == 500) {

          _profileContract.onPhoneNumberTaken(context);
        }
        else {

          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("profile_updated_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("profile_updated_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void resetPassword(BuildContext context, User user) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.post(

          Uri.encodeFull(APIRoute.RESET_PASSWORD),
          body: user.resetPassword(),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Password Reset", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("password_reset_success"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_reset_failed"));
          }
        }
        else {

          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_reset_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("password_reset_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void updateServices(BuildContext context, List<JobService> services) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'update_id': currentUser.value.id,
      };

      if(services != null && services.length > 0) {

        List<String> mList = [];

        services.forEach((service) {

          mList.add(service.id);
        });

        body['services'] = json.encode(mList);
      }

      client.post(

          Uri.encodeFull(APIRoute.UPDATE_PROFILE),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Update Services", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            User user = User.fromJson(jsonData['data']['user']);

            currentUser.value.services = user.services;
            currentUser.notifyListeners();

            _preference.setCurrentUser(currentUser.value);
            _profileContract.onSuccess(context, AppLocalization.of(context).getTranslatedValue("service_update_success"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("service_update_failed"));
          }
        }
        else if(response.statusCode == 401) {

          if(jsonData['message'] == Constants.UNAUTHORIZED) {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("unauthorized_request"));
          }
          else {

            _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("service_update_failed"));
          }
        }
        else {

          _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("service_update_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _profileContract.onError(context, AppLocalization.of(context).getTranslatedValue("service_update_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  Future<void> updateSeekerLocation(Position position) async {

    final client = new http.Client();

    Map<String, dynamic> body = {
      'token': currentUser.value.accessToken.token,
      'update_id': currentUser.value.id,
      'location': position.latitude.toString() + "," + position.longitude.toString(),
    };

    client.post(

      Uri.encodeFull(APIRoute.UPDATE_PROFILE),
      body: body,
      headers: {"Accept" : "application/json"},

    ).then((response) {

      //print(response.body);

    }).timeout(Duration(seconds: 5), onTimeout: () {

      client.close();
    });
  }
}