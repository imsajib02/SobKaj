import 'package:sobkaj/presenter/user_presenter.dart';

class Complaint {

  String id;
  String jobId;
  String complainant;
  String accused;
  String message;
  String date;
  String createdAt;
  String updatedAt;

  Complaint({this.id, this.jobId, this.complainant, this.accused, this.date,
    this.createdAt, this.updatedAt, this.message});


  Complaint.fromJson(Map<String, dynamic> json) {

    id = json['id'] == null ? "" : json['id'].toString();

    try {
      jobId = json['job_id'] == null ? "" : json['job_id'].toString();
    }
    catch(error) {}

    try {
      complainant = json['complaint_user_id'] == null ? "" : json['complaint_user_id'].toString();
    }
    catch(error) {}

    try {
      accused = json['complaint_against_user_id'] == null ? "" : json['complaint_against_user_id'].toString();
    }
    catch(error) {}

    try {
      message = json['complaint_details'] == null ? "" : json['complaint_details'].toString();
    }
    catch(error) {}

    try {
      date = json['date'] == null ? "" : json['date'].rating();
    }
    catch(error) {}

    try {
      createdAt = json['created_at'] == null ? "" : json['created_at'].toString();
    }
    catch(error) {}

    try {
      updatedAt = json['updated_at'] == null ? "" : json['updated_at'].toString();
    }
    catch(error) {}
  }


  toJson() {

    return {
      "token" : currentUser.value.accessToken.token,
      "job_id" : jobId == null ? "" : jobId,
      "complaint" : message == null ? "" : message
    };
  }
}