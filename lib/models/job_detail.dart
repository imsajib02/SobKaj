class JobDetail {

  String id;
  String jobID;
  String image;

  JobDetail({this.id, this.jobID, this.image});

  JobDetail.fromJson(Map<String, dynamic> json) {

    id = json['id'] == null ? "" : json['id'].toString();

    try {
      jobID = json['job_id'] == null ? "" : json['job_id'].toString();
    }
    catch(error) {}

    try {
      image = json['image'] == null ? "" : json['image'];
    }
    catch(error) {}
  }
}


class JobDetails {

  List<JobDetail> list;

  JobDetails({this.list});

  JobDetails.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((detail) {

        list.add(JobDetail.fromJson(detail));
      });
    }
  }
}