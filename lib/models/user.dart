import 'dart:convert';

import 'package:sobkaj/models/access_token.dart';
import 'package:sobkaj/models/job_service.dart';

class User {

  String id;
  String roleID;
  String name;
  String phone;
  String email;
  String password;
  String confirmPassword;
  String newPassword;
  String avatar;
  String birthDate;
  String gender;
  String providingJobAs;
  String address;
  String location;
  String attachment;
  String cvAttachment;
  String status;
  String suspendDate;
  String deviceToken;
  String rating;
  String jobsCompleted;
  JobServices services = JobServices(list: List());
  AccessToken accessToken;

  User({this.id, this.roleID, this.name, this.phone, this.email,
    this.password, this.confirmPassword, this.newPassword, this.avatar,
    this.birthDate, this.gender, this.providingJobAs, this.address,
    this.location, this.attachment, this.cvAttachment, this.status,
    this.suspendDate, this.deviceToken, this.services, this.accessToken, this.rating, this.jobsCompleted});


  User.fromJson(Map<String, dynamic> json) {

    id = json['id'] == null ? "" : json['id'].toString();
    roleID =  json['role_id'] == null ? "" : json['role_id'].toString();
    name =  json['name'] == null ? "" : json['name'];
    phone =  json['phone'] == null ? "" : json['phone'];
    email =  json['email'] == null ? "" : json['email'];
    avatar =  json['avatar'] == null ? "" : json['avatar'];
    birthDate =  json['birth_date'] == null ? "" : json['birth_date'];
    gender =  json['gender'] == null ? "" : json['gender'];
    providingJobAs =  json['providing_job'] == null ? "" : json['providing_job'];
    address =  json['address'] == null ? "" : json['address'];
    location = json['location'] == null ? "" : json['location'];
    attachment = json['attachment'] == null ? "" : json['attachment'];
    cvAttachment = json['cv_attachment'] == null ? "" : json['cv_attachment'];
    status = json['status'] == null ? "" : json['status'];
    suspendDate = json['suspended_date'] == null ? "" : json['suspended_date'];
    deviceToken = json['device_token'] == null ? "" : json['device_token'];

    try {
      accessToken = json['access_token'] == null ? null : AccessToken.fromJson(json['access_token']);
    }
    catch(error) {}

    try {
      rating = json['rating'] == null ? "" : json['rating'];
    }
    catch(error) {}

    try {
      jobsCompleted = json['seeker_complete_job_count'] == null ? "" : json['seeker_complete_job_count'].toString();
    }
    catch(error) {}

    try {
      services = json['seeker_services'] == null ? JobServices(list: List()) : JobServices.fromJson(json['seeker_services']);
    }
    catch(error) {

      try {
        json['seeker_services'] == null ? services.list = List() :
        jsonDecode(json['seeker_services']).forEach((service) {

          services.list.add(JobService.fromJson(service));
        });
      }
      catch(error) {
        services = JobServices(list: List());
      }
    }
  }


  toJson() {

    return {
      "id" : id == null ? "" : id,
      "role_id" : roleID == null ? "" : roleID,
      "name" : name == null ? "" : name,
      "phone" : phone == null ? "" : phone,
      "email" : email == null ? "" : email,
      "password" : password == null ? "" : password,
      "avatar" : avatar == null ? "" : avatar,
      "birth_date" : birthDate == null ? "" : birthDate,
      "gender" : gender == null ? "" : gender,
      "providing_job" : providingJobAs == null ? "" : providingJobAs,
      "address" : address == null ? "" : address,
      "location" : location == null ? "" : location,
      "attachment" : attachment == null ? "" : attachment,
      "cv_attachment" : cvAttachment == null ? "" : cvAttachment,
      "status" : status == null ? "" : status,
      "suspended_date" : suspendDate == null ? "" : suspendDate,
      "device_token" : deviceToken == null ? "" : deviceToken,
      "access_token" : accessToken == null ? "" : accessToken.toJson(),
      "seeker_services" : services == null ? jsonEncode(JobServices(list: List()).list.map((service) => service.toJson()).toList()).toString() :
      jsonEncode(services.list.map((service) => service.toJson()).toList()).toString(),
    };
  }


  phoneChange() {

    return {
      "update_id" : id,
      "phone" : phone,
      "token" : accessToken.token
    };
  }


  changePassword() {

    return {
      "current_password" : password == null ? "" : password,
      "password" : newPassword == null ? "" : newPassword,
      "password_confirmation" : confirmPassword == null ? "" : confirmPassword,
      "token" : accessToken != null && accessToken.token != null ? accessToken.token : "",
    };
  }


  resetPassword() {

    return {
      "phone" : phone == null ? "" : phone,
      "password" : newPassword == null ? "" : newPassword,
      "password_confirmation" : confirmPassword == null ? "" : confirmPassword,
    };
  }


  update() {

    return {
      "name" : name,
      "email" : email,
      "address" : address,
      "token" : accessToken.token
    };
  }
}


class Users {

  List<User> list;

  Users({this.list});

  Users.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((user) {

        list.add(User.fromJson(user));
      });
    }
  }
}