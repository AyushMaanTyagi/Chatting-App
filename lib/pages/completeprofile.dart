
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/Models/UiHelper.dart';
import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/pages/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
class CompleteProfile extends StatefulWidget {
  //to fetch userModel details
final Usermodel usermodel;
//to upload detais in firebase User
final User firebaseuser;
const CompleteProfile({super.key, required this.usermodel, required this.firebaseuser});
  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
    File? imageFile;
  TextEditingController fname=TextEditingController();

void checkvalues()
{
  String fullname=fname.text.trim();
  if(fullname == ""||imageFile == null)
    {
      //log("Please fill the Required details");
      Uihelper.showAlertDialog(context,"Incomplete Data","Please fill all the values");
    }
  else
    {
      log("uploading data1");
      uploadData();
    }
}

void uploadData()async{
  //Firebase provides UploadTask as a variable type to upolad any file for the user in firebase storage so as to retrieve it from the database;

Uihelper.ShowLoadingdialog(context, "Uploading Image");

UploadTask uploadTask=FirebaseStorage.instance.ref("profilepic").child(widget.usermodel.uid.toString()).putFile(imageFile!);
TaskSnapshot snapshot=await uploadTask;

 String?Imageurl=await snapshot.ref.getDownloadURL();
String? Fullname=fname.text.trim();


//updating the values of Usermodel class for fullname and Profilepic which was not updated at signup time
widget.usermodel.fullname=Fullname;
widget.usermodel.pic=Imageurl;

//uploading the data to fireStore users collection under uid document ,setting in the form of map;

await FirebaseFirestore.instance.collection("users").doc(widget.usermodel.uid).set(widget.usermodel.toMap()).then((onValue){
  log("Data Uploaded!!");
  });

Navigator.popUntil(context,(Route)=>Route.isFirst);
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context)
      {
        return Homepage(usermodel: widget.usermodel, firebaseuser: widget.firebaseuser);
      }
      ));

}
  void selectImage(ImageSource source)async{
    XFile? pickedImage=await ImagePicker().pickImage(source: source);
    if (pickedImage!=null)
      {
        cropimage(pickedImage);
      }
  }
  void cropimage(XFile file)async{
    CroppedFile? croppedImage= await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio:CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20,
    );
    if(croppedImage!=null)
      {
        setState(() {
          imageFile=File(croppedImage.path);
        });

      }
  }


  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Upload Profile Pic"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectImage(ImageSource.gallery);
            },
            leading: const Icon(Icons.photo_album),
            title: const Text("Select from gallery"),
          ),
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectImage(ImageSource.camera);
            },
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take a Photo"),
          )
        ],
      ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle:true,
          title: const Text("Complete Profile",style: TextStyle(color: Colors.white,fontSize: 25)),
      ),
body: Center(
  child: SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 40
      ),
      child: ListView(
      children: [
        const SizedBox(height: 20,),
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            showPhotoOptions();
          },

          child:  CircleAvatar(
            radius: 60,
            backgroundImage:(imageFile!=null)? FileImage(imageFile!):null,
            child: (imageFile==null)?Icon(Icons.person,size: 60,):null,
          ),
        ),
        const SizedBox(height: 20,),
         TextField(
          controller: fname,
          decoration: InputDecoration(
          labelText: "Full Name",
        ),),
        const SizedBox(height: 20,),
      CupertinoButton(color: Theme.of(context).colorScheme.secondary,child: const Text("Submit"), onPressed: ()
      {
        checkvalues();
      })
      ],
      ),
    ),
  ),
),
    );
  }
}
