import 'package:chat_app/Models/UiHelper.dart';
import 'package:chat_app/Models/Usermodel.dart';
import 'package:chat_app/Models/chatroomModel.dart';
import 'package:chat_app/Models/firebaseHelper.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/SearchPage.dart';
import 'package:chat_app/pages/chatRoompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final Usermodel usermodel;
  final User firebaseuser;
  const Homepage(
      {super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text("My Meet App"),
        actions: [
          IconButton(onPressed: ()async{
            await FirebaseAuth.instance.signOut();
          Navigator.popUntil(context, (Route)=>Route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)
          {
            return LoginPage();
          }
          ));},
           icon:Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
        child: Container(
          //Stream will ftech the list of users invloved with the curent users
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms").where("users",arrayContains: widget.usermodel.uid).orderBy("createdon")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatroomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatroomSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        //Each of the chatroom model values like participants ,chatroom Id,lastMessage will fteced by chatroomModel as Map
                        ChatroomModel chatroomModel = ChatroomModel.fromMap(
                            chatroomSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        //fetching the participants of the current doc-> chatroom
                        Map<String, dynamic>? participants =
                            chatroomModel.participants;
                        //fetching only the participants keys in list form
                        List<String> ParticipantsKeys =
                            participants!.keys.toList();
                        ParticipantsKeys.remove(widget.usermodel.uid);

                        return FutureBuilder(
                            future: Firebasehelper.getUsermodelById(
                                ParticipantsKeys[0]),
                            builder: (context, userdata) {
                              if (userdata.connectionState ==
                                  ConnectionState.done) {
                                if (userdata.data != null) {
                                  Usermodel targetuser =
                                      userdata.data as Usermodel;
                                  return ListTile(
                                    onTap: () => {
                                      Navigator.push(context,
                                      MaterialPageRoute(builder:(context){
                                        return Chatroompage(chatroomModel: chatroomModel, targetuser: targetuser, usermodel: widget.usermodel, firebaseuser: widget.firebaseuser);
                                      } 
                                      )
                                      )
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetuser.pic.toString()),
                                    ),
                                    title: Text(targetuser.fullname.toString()),
                                    subtitle:(chatroomModel.lastMessage.toString()!="")? Text(
                                        chatroomModel.lastMessage.toString()):Text("Say hi to Your new Friend",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text("No Recent Chats"),
                  );
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Searchpage(
                usermodel: widget.usermodel, firebaseuser: widget.firebaseuser);
          }));
         
        },
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(
            //color: Colors.blue,
            Icons.search),
      ),
    );
  }
}
