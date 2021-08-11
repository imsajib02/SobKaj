class JobService {

  String id;
  String name;
  String imageUrl;
  String status;
  String description;
  String price;
  String adminCommission;

  JobService({this.id, this.name, this.imageUrl, this.price, this.status, this.description, this.adminCommission});


  JobService.fromJson(Map<String, dynamic> json) {

    try {

      id = json['service_category_id'] != null ? json['service_category_id'].toString() : (json['id'] != null ?
      json['id'].toString() : "");
    }
    catch(error) {}

    name =  json['name'] == null ? "" : json['name'];

    try {
      status = json['status'] == null ? "" : json['status'].toString();
    }
    catch(error) {}

    try {
      imageUrl = json['image'] == null ? "" : json['image'];
    }
    catch(error) {}

    try {
      price = json['price'] == null ? "" : json['price'].toString();
    }
    catch(error) {}

    try {
      description = json['description'] == null ? "" : json['description'];
    }
    catch(error) {}

    try {
      adminCommission = json['ind_admin_commission'] == null ? "" : json['ind_admin_commission'].toString();
    }
    catch(error) {}
  }


  toJson() {

    return {
      "id" : id == null ? "" : id,
      "name" : name == null ? "" : name,
      "status" : status == null ? "" : status,
      "image" : imageUrl == null ? "" : imageUrl,
      "description" : description == null ? "" : description,
    };
  }
}


class JobServices {

  List<JobService> list;

  JobServices({this.list});

  JobServices.fromJson(dynamic data) {

    list = List();

    if(data != null) {

      data.forEach((service) {

        list.add(JobService.fromJson(service));
      });
    }
  }
}