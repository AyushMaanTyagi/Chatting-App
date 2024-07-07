class ChatroomModel{
  String?chatRoomid;
  Map<String,dynamic>?participants;
 List<dynamic>?users;
  String? lastMessage;
  DateTime? createdon;
  ChatroomModel( this.chatRoomid,this.participants,this.lastMessage,this.users,this.createdon);

  ChatroomModel.fromMap(Map<String,dynamic>map){
    chatRoomid=map["chatRoomid"];
    participants=map["participants"];
    lastMessage=map["lastmessage"];
    createdon=map["createdon"].toDate();
    users=map["users"] ;
  }
 Map<String,dynamic> toMap(){
return{
  "chatRoomid":chatRoomid,
  "participants":participants,
  "lastmessage":lastMessage,
  "createdon":createdon,
  "users":users
};
  }
}