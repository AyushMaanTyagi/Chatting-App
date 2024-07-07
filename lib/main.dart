import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/Models/firebaseHelper.dart';
import 'package:chat_app/pages/Homepage.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


var uuid=Uuid();
 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentuser=FirebaseAuth.instance.currentUser;
  if(currentuser==null)
    {
      runApp(const MyApp());
    }
  else
    {
      Usermodel? thisUsermodel=await Firebasehelper.getUsermodelById(currentuser.uid);
      if(thisUsermodel !=null)
        {

          runApp( MyAppLoggedIn(firebaseuser: currentuser, usermodel: thisUsermodel));
        }

    }
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme:ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 45, 255)),
        useMaterial3: true
      ),
      home: const LoginPage(),
    );
  }
}

//Already Logged In
class MyAppLoggedIn extends StatelessWidget {
   final User firebaseuser;
   final Usermodel usermodel;
  const MyAppLoggedIn({super.key, required this.firebaseuser, required this.usermodel});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
          colorScheme:ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 34, 45, 255)),
          useMaterial3: true
      ),
      home: Homepage(usermodel: usermodel, firebaseuser: firebaseuser),
    );
  }
}

