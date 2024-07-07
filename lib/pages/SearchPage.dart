// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/Models/chatroomModel.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/chatRoompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Searchpage extends StatefulWidget {
  final Usermodel usermodel;
  final User firebaseuser;
  Searchpage({super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  TextEditingController searchcontroller = TextEditingController();
  //here we are finding whether user has previously chatted with the target user so return the previous chatroomModel otherwise create a new One
  Future<ChatroomModel?> getchatRoom(Usermodel targetuser) async{
    ChatroomModel chatroom;
QuerySnapshot querySnapshot=await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.usermodel.uid}",isEqualTo: true).where("participants.${targetuser.uid}",isEqualTo: true).get();
if(querySnapshot.docs.length>0)
  {//Fetch the exisisting chatroom
    var docdata=  querySnapshot.docs[0].data();
    ChatroomModel existingChatroom=ChatroomModel.fromMap(docdata as Map<String,dynamic>);
  chatroom=existingChatroom;

  }
else
  {//Create a new one
    ChatroomModel newchatroom=ChatroomModel(
      uuid.v1(),//chatroomId
      {
        widget.usermodel.uid.toString():true,
        targetuser.uid.toString():true
      },//participants
      "",//last msg
    [
      widget.usermodel.uid.toString(),
      targetuser.uid.toString()
    ],
    DateTime.now()
    );
    await FirebaseFirestore.instance.collection("chatrooms").doc(newchatroom.chatRoomid).set(newchatroom.toMap());
    chatroom=newchatroom;
    log("new Chatroom created");
  }
return chatroom;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchcontroller,
                decoration: InputDecoration(
                  labelText: "Enter Email Address",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  child: Text("Search",style: TextStyle(color: Colors.black),),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  onPressed: () {
                    setState(() {
                    });
                  }),
                  SizedBox(height: 20,),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchcontroller.text.trim(),isNotEqualTo: widget.usermodel.email)
                      .snapshots(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        //Need to convert data into QuerySnapshot
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;
                        if (datasnapshot.docs.isNotEmpty)
                        {
                        Map<String, dynamic> userMap = datasnapshot.docs[0].data() as Map<String, dynamic>;
                          //storing the map of details of user in searcheduser in form of map

                          Usermodel seracheduser = Usermodel.fromMap(userMap);
                          ChatroomModel? chatroommodel;
                          return ListTile(
                            onTap: ()async =>{
                               chatroommodel = await getchatRoom(seracheduser),
                              if(chatroommodel!=null)
                                {
                                  Navigator.pop(context),
                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context)
                                  {
                                    return Chatroompage(chatroomModel: chatroommodel!, targetuser: seracheduser, usermodel: widget.usermodel, firebaseuser: widget.firebaseuser,);
                                  }
                                  )
                                  )
                                }

                            } ,
                            
                            leading:CircleAvatar(
                              backgroundImage:NetworkImage(seracheduser.pic.toString()),
                              
                            ),
                            title: Text(seracheduser.fullname.toString()),
                            subtitle: Text(seracheduser.email.toString()),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        }
                        else
                        {
                          return Text("No user Found!");
                        }
                      } 
                      else if (snapshot.hasError) 
                      {
                        return Text("An Error Occurred");
                      } 
                      else 
                      {
                        return Text("No user Found!!");
                      }
                    }
                     else 
                     {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

