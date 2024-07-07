class Usermodel{
  String? pic;
  String? uid;
  String? email;
  String? fullname;
  String?password;

  Usermodel({this.email,this.fullname,this.pic,this.uid,this.password});

  Usermodel.fromMap(Map<String,dynamic>map)
  {
    email=map["email"];
    fullname=map["fullname"];
    pic=map["pic"];
    uid=map["uid"];
    password=map["password"];
  }
  Map<String,dynamic> toMap(){
    return{
      "uid":uid,
      "fullname":fullname,
      "pic":pic,
      "email":email,
      "password":password
    };

  }

}