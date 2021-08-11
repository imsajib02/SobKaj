class AccessToken {

  String token;
  String type;
  int expiryTime;

  AccessToken({this.token, this.type, this.expiryTime});


  AccessToken.fromJson(Map<String, dynamic> json) {

    token = json['access_token'] == null ? "" : json['access_token'];
    type = json['token_type'] == null ? "" : json['token_type'];

    try {
      expiryTime = json['expires_in'] == null ? 0 : int.parse(json['expires_in']);
    }
    catch(error) {
      expiryTime = json['expires_in'] == null ? 0 : json['expires_in'];
    }
  }


  toJson() {

    return {
      "access_token" : token == null ? "" : token,
      "token_type" : type == null ? "" : type,
      "expires_in" : expiryTime == null ? "0" : expiryTime.toString()
    };
  }
}