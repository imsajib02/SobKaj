import 'package:sobkaj/presenter/user_presenter.dart';

class Review {

  String id;
  String rating;
  String review;
  String jobId;
  String providerID;
  String seekerID;
  String status;
  String dateTime;
  String createdAt;
  String updatedAt;

  Review({this.id, this.rating, this.review, this.jobId, this.dateTime, this.createdAt, this.updatedAt});

  Review.fromJson(Map<String, dynamic> json) {

    id = json['id'] == null ? "" : json['id'].toString();

    try {
      rating = json['rating'] == null ? "" : json['rating'].toString();
    }
    catch(error) {}

    try {
      review = json['review'] == null ? "" : json['review'];
    }
    catch(error) {}

    try {
      jobId = json['job_id'] == null ? "" : json['job_id'].toString();
    }
    catch(error) {}

    try {
      providerID = json['provider_id'] == null ? "" : json['provider_id'].rating();
    }
    catch(error) {}

    try {
      seekerID = json['seeker_id'] == null ? "" : json['seeker_id'].toString();
    }
    catch(error) {}

    try {
      status = json['status'] == null ? "" : json['status'].toString();
    }
    catch(error) {}

    try {
      dateTime = json['date_time'] == null ? "" : json['date_time'];
    }
    catch(error) {}

    try {
      createdAt = json['created_at'] == null ? "" : json['created_at'].toString();
    }
    catch(error) {}

    try {
      updatedAt = json['updated_at'] == null ? "" : json['updated_at'];
    }
    catch(error) {}
  }

  toJson() {

    return {
      "token" : currentUser.value.accessToken.token,
      "job_id" : jobId == null ? "" : jobId,
      "rating" : rating == null ? "" : rating,
      "review" : review == null ? "" : review,
    };
  }
}


class Reviews {

  List<Review> list;

  Reviews({this.list});

  Reviews.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((review) {

        list.add(Review.fromJson(review));
      });
    }
  }
}