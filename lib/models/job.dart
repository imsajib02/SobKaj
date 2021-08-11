import 'package:sobkaj/models/job_detail.dart';
import 'package:sobkaj/models/job_service.dart';
import 'package:sobkaj/models/payment.dart';
import 'package:sobkaj/models/user.dart';

import 'bid.dart';

class Job {

  String id;
  String date;
  String time;
  String serviceID;
  String providerID;
  User provider;
  String phone;
  String seekerID;
  String title;
  String description;
  String fee;
  String paidFee;
  String address;
  String location;
  String guestName;
  String rating;
  String status;
  bool providerComplained;
  bool seekerComplained;
  String deletable;
  Payment payment;
  User seeker;
  JobService service;
  Bid bid;
  JobDetails details = JobDetails(list: List());

  Job({this.id, this.date, this.time, this.serviceID, this.providerID,
    this.phone, this.seekerID, this.title, this.description, this.fee,
    this.address, this.location, this.guestName, this.rating, this.status,
    this.deletable, this.seeker, this.service, this.details, this.bid, this.paidFee, this.provider, this.providerComplained, this.seekerComplained, this.payment});

  Job.fromJson(Map<dynamic, dynamic> json) {

    id = json['id'] == null ? "" : json['id'].toString();
    date =  json['date'] == null ? "" : json['date'].toString();
    time =  json['time'] == null ? "" : json['time'].toString();
    phone =  json['phone'] == null ? "" : json['phone'].toString();

    try{

      serviceID =  json['service_category_id'] == null ? "" : json['service_category_id'].toString();
    }
    catch(error) {}

    try{

      service =  json['services'] == null ? JobService() : JobService.fromJson(json['services']);
    }
    catch(error) {}

    try{

      bid =  json['job_applieds'] == null ? Bid() : Bid.fromJson(json['job_applieds']);
    }
    catch(error) {}

    try{

      seeker =  json['seeker'] == null ? (json['seeker_id'] == null ? User() : User.fromJson(json['seeker_id'])) : User.fromJson(json['seeker']);
    }
    catch(error) {}

    try{

      payment =  json['payments'] == null ? (json['payment'] == null ? Payment() : Payment.fromJson(json['payment'])) : Payment.fromJson(json['payments']);
    }
    catch(error) {}

    try{

      providerID =  json['provider_id'] == null ? "" : json['provider_id'].toString();
    }
    catch(error) {}

    try{

      provider =  json['provider'] == null ? (json['provider_id'] == null ? User() : User.fromJson(json['provider_id'])) : User.fromJson(json['provider']);
    }
    catch(error) {}

    try{

      seekerID =  json['seeker_id'] == null ? "" : json['seeker_id'].toString();
    }
    catch(error) {}

    title =  json['job_title'] == null ? "" : json['job_title'];
    description =  json['job_info'] == null ? "" : json['job_info'];
    fee =  json['job_fee'] == null ? "" : json['job_fee'].toString();
    paidFee =  json['job_fee_paid'] == null ? "" : json['job_fee_paid'].toString();

    try{

      address =  json['address'] == null ? "" : json['address'].toString();
    }
    catch(error) {}

    location =  json['location'] == null ? "" : json['location'];

    try{

      guestName =  json['guest_name'] == null ? "" : json['guest_name'];
    }
    catch(error) {}

    try{

      rating =  json['rating'] == null ? "" : json['rating'].toString();
    }
    catch(error) {}

    try{

      status =  json['status'] == null ? "" : json['status'].toString();
    }
    catch(error) {}

    try{

      deletable =  json['deletable'] == null ? "" : json['deletable'].toString();
    }
    catch(error) {}

    try{

      details = json['jobDetails'] == null ? (json['jobdetails'] == null ? JobDetails(list: List()) : JobDetails.fromJson(json['jobdetails'])) : JobDetails.fromJson(json['jobDetails']);
    }
    catch(error) {}

    try{

      providerComplained =  json['provider_complaint'] == null ? false : json['provider_complaint'] as bool;
    }
    catch(error) {}

    try{

      seekerComplained =  json['seeker_complaint'] == null ? false : json['seeker_complaint'] as bool;
    }
    catch(error) {}
  }
}



class Jobs {

  List<Job> list;

  Jobs({this.list});

  Jobs.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((job) {

        list.add(Job.fromJson(job));
      });
    }
  }
}