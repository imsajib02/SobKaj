import 'package:sobkaj/models/user.dart';

class Bid {

  String id;
  String fee;
  String note;
  String jobId;
  String providerID;
  String seekerId;
  User seeker;
  String completeJobs;
  String status;
  String feeStatus;
  String createdAt;
  String updatedAt;

  Bid({this.id, this.fee, this.note, this.jobId, this.providerID, this.seekerId,
    this.seeker, this.completeJobs, this.status, this.createdAt,
    this.updatedAt, this.feeStatus});


  Bid.fromJson(Map<String, dynamic> json) {

    try {
      id = json['id'] == null ? "" : json['id'].toString();
    }
    catch(error) {}

    try {
      fee = json['proposed_job_fee'] == null ? "" : json['proposed_job_fee'].toString();
    }
    catch(error) {}

    try {
      note = json['description'] == null ? "" : json['description'];
    }
    catch(error) {}

    try {
      jobId = json['job_id'] == null ? "" : json['job_id'].toString();
    }
    catch(error) {}

    try {
      providerID = json['provider_id'] == null ? "" : json['provider_id'].toString();
    }
    catch(error) {}

    try {
      seekerId = json['seeker_id'] == null ? "" : json['seeker_id'].toString();
    }
    catch(error) {}

    try {
      seeker = json['seekers'] == null ? (json['seeker'] == null ? User() : User.fromJson(json['seeker'])) : User.fromJson(json['seekers']);
    }
    catch(error) {}

    try {
      status = json['status'] == null ? "" : json['status'].toString();
    }
    catch(error) {}

    try {
      feeStatus = json['job_fee_status'] == null ? "" : json['job_fee_status'].toString();
    }
    catch(error) {}

    try {
      completeJobs = json['seekerCompleteJob'] == null ? "" : json['seekerCompleteJob'].toString();
      seeker.jobsCompleted = completeJobs;
    }
    catch(error) {}

    try {
      createdAt = json['created_at'] == null ? "" : json['created_at'];
    }
    catch(error) {}

    try {
      updatedAt = json['updated_at'] == null ? "" : json['updated_at'];
    }
    catch(error) {}
  }
}


class Bids {

  List<Bid> list;

  Bids({this.list});

  Bids.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((bid) {

        list.add(Bid.fromJson(bid));
      });
    }
  }
}