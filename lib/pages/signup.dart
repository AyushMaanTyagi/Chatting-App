import 'package:chat_app/Models/UiHelper.dart';
import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailC=TextEditingController();
  TextEditingController PassC=TextEditingController();
  TextEditingController CPass=TextEditingController();
void checkValues()
{
  String email=emailC.text.trim();
  String pass=PassC.text.trim();
  String cpass=CPass.text.trim();

  if(email == ""||pass == ""||cpass == "")
    {
      
      Uihelper.showAlertDialog(context, "Incomplete Data", "Please fill all the values");
    }
  else if(pass!=cpass)
  {
    Uihelper.showAlertDialog(context,"Password Mismatch","password do not match");
    
  }
  else
    {
      signup(email, pass);
    }
}

void signup(String email,String password) async
{
  UserCredential?credential;
  Uihelper.ShowLoadingdialog(context, "Creating New account");
  try {
    credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    Uihelper.showAlertDialog(context,"An error occurred",e.code.toString());
  }
  if (credential != null) {
    String uniqueid = credential.user!.uid;
    Usermodel newuser = Usermodel(
        email: email,
        uid: uniqueid,
        password: password,
        fullname: "",
        pic: ""
    );
    await FirebaseFirestore.instance.collection("users").doc(uniqueid).set(
        newuser.toMap()).then((onValue) {
      print("new user crreatd");
      Navigator.popUntil(context, (Route)=>Route.isFirst);
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              usermodel: newuser, firebaseuser: credential!.user!);
        }
        ),
      );
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 40
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("My Meet App",style:TextStyle(color:Theme.of(context).colorScheme.inversePrimary ,fontSize:40 ,fontWeight:FontWeight.bold ),),
                    const SizedBox(height:10),
                    TextField(
                      controller: emailC,
                      decoration: const InputDecoration(
                          labelText: "Email Address"
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextField(
                      controller: PassC,
                        obscureText: true,
                        decoration:const InputDecoration(
                            labelText: "Password"
                        )
                    ),
                    const SizedBox(height: 10,),
                    TextField(
                      controller: CPass,
                        obscureText: true,
                        decoration:const InputDecoration(
                            labelText: "Confirm Password"
                        )
                    ),
                    const SizedBox(height: 20,),
                    CupertinoButton(color:Theme.of(context).colorScheme.inversePrimary,
                        onPressed: (){
                          checkValues();
                        }, child: const Text("Sign Up")
                    )
                  ],
                ),
              ),
            ),
          )
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?",style: TextStyle(fontSize: 16),),
            CupertinoButton(child: const Text("Login",style: TextStyle(fontSize: 16),), onPressed: (){
              Navigator.pop(context);
            })
          ],
        ),
      ),
    );
  }
}
