// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/Models/chatroomModel.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatroompage extends StatefulWidget {
  final ChatroomModel chatroomModel;
  final Usermodel targetuser;
  final Usermodel usermodel;
  final User firebaseuser;
  const Chatroompage({super.key, required this.chatroomModel, required this.targetuser, required this.usermodel, required this.firebaseuser});

  @override
  State<Chatroompage> createState() => _ChatroompageState();
}

class _ChatroompageState extends State<Chatroompage> {
  TextEditingController messageC=TextEditingController();

  void sendmessage()async{
    String msg=messageC.text.trim();
    messageC.clear();
    if(msg !="")
      {// send message
        MessageModel messageModel=MessageModel(
          msgId: uuid.v1(),
          sender: widget.usermodel.uid,
          text: msg,
          seen: false,
          createdon: DateTime.now()
        );
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroomModel.chatRoomid).collection("messages").doc(messageModel.msgId).set(messageModel.toMap());
      log("message sent");
      widget.chatroomModel.lastMessage=msg;
     // widget.chatroomModel.currentDateTime=DateTime.now();
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroomModel.chatRoomid).set(widget.chatroomModel.toMap());
      }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Row(
        children: [
          CircleAvatar(backgroundColor: const Color.fromARGB(255, 200, 188, 188),
          backgroundImage:NetworkImage(widget.targetuser.pic.toString()) ,
          ),
          SizedBox(width: 10,),
          Text(widget.targetuser.fullname.toString())
        ],
      ),),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              //this is where the chats will go
              Expanded(
                child:Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10
                  ),
                  child: StreamBuilder(stream: FirebaseFirestore.instance.collection("chatrooms")
                      .doc(widget.chatroomModel.chatRoomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                      builder: (context,snapshot)
                      {
                    if(snapshot.connectionState==ConnectionState.active)
                      {
                  
                        if(snapshot.hasData)
                          {
                            QuerySnapshot datasnapshot=snapshot.data as QuerySnapshot;
                            return ListView.builder(
                              reverse: true,
                              itemCount: datasnapshot.docs.length,
                              itemBuilder: (context,index){
                                MessageModel currentMessage=MessageModel.fromMap(datasnapshot.docs[index].data() as Map<String,dynamic>);
                                return Row(
                                  mainAxisAlignment: (currentMessage.sender==widget.usermodel.uid)?MainAxisAlignment.end:MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      decoration: BoxDecoration(
                                      color: (currentMessage.sender==widget.usermodel.uid)?Color.fromARGB(107, 196, 193, 193):Theme.of(context).colorScheme.inversePrimary,
                                      borderRadius: BorderRadius.circular(5)  
                                      ),
                                      child: Text(currentMessage.text.toString())),
                                  ],
                                );
                              },
                            );
                  
                          }
                        else if(snapshot.hasError)
                          {
                            return Center(
                              child: Text("An error occurred ,please check your Internet Connection"),
                            );
                          }
                        else
                          {
                           return Center(
                              child: Text("Start a new Conversation"),
                            );
                          }
                      }
                    else
                      {
                       return Center(
                        child:  CircularProgressIndicator()
                        );
                      }
                      }
                      ),
                )

              ),

            Container(
              color: Colors.grey[500],
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5
            ),
              child: Row(
                children: [
                   Flexible(
                  child: TextField(
                    maxLines: null,
                    controller: messageC,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Message",
                    ),
                  ),
                  ),


                  IconButton(onPressed:(){
                  sendmessage();
                  },
                   icon:Icon(Icons.send,color: Theme.of(context).colorScheme.inversePrimary,)),
                ],
              ),
            )

            ],
          ),
        ),
      ),
    );
  }
}