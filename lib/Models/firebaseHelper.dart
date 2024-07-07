import 'package:cloud_firestore/cloud_firestore.dart';

import 'Usermodel.dart';

class Firebasehelper{
static Future<Usermodel?>getUsermodelById(String uid) async{
Usermodel? usermodel;
DocumentSnapshot snapshot=await FirebaseFirestore.instance.collection("users").doc(uid).get();
if(snapshot.data() !=null)
  {
  usermodel=Usermodel.fromMap(snapshot.data() as Map<String,dynamic>);
  }
return usermodel;
}

}