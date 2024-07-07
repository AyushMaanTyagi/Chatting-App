import 'package:chat_app/Models/UiHelper.dart';
import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/pages/Homepage.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailC=TextEditingController();
  TextEditingController passC=TextEditingController();

  void checkvalues()
  {
    String email=emailC.text.trim();
    String pass=passC.text.trim();
    if(email == ""||pass == "")
    {
      Uihelper.showAlertDialog(context,"Incomplete Data","Please fill all the values");
      
    }
    else
    {
      login(email, pass);
    }
  }
  void login(String email, String pass) async
  {
    UserCredential?credential;

    Uihelper.ShowLoadingdialog(context, "Logging in..");

    try
        {
          credential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
        }
        on FirebaseAuthException catch(e)
    {
        //to close the loading dialog when an error
        Navigator.pop(context);
        Uihelper.showAlertDialog(context,"An error occurred",e.message.toString());
      
    }
    if(credential!=null){
      String uid=credential.user!.uid;
      DocumentSnapshot userdata= await FirebaseFirestore.instance.collection("users").doc(uid).get();
      Usermodel usermodel=Usermodel.fromMap(userdata.data() as Map<String,dynamic>);

      if(pass==usermodel.password && email==usermodel.email)
        {
          Uihelper.ShowLoadingdialog(context, "Login Successful");
        }
        Navigator.popUntil(context,(Route)=>Route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)
        {
          return Homepage(usermodel: usermodel, firebaseuser: credential!.user!);
        }
        ),
      );
      
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
                    controller: passC,
                    obscureText: true,
                    decoration:const InputDecoration(
                      labelText: "Password"
                    )
                  ),
                  const SizedBox(height: 20,),
                  CupertinoButton(color:Theme.of(context).colorScheme.inversePrimary,
                      onPressed: (){
                        checkvalues();

                      }, child: const Text("Login")
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
            const Text("Don't have an account?",style: TextStyle(fontSize: 16),),
            CupertinoButton(child: const Text("Sign Up",style: TextStyle(fontSize: 16),), onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)
              {
                return const Signup();
              }
              ),
              );
            })
          ],
        ),
      ),
    );
  }
}
