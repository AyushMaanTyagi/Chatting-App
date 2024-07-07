class MessageModel{
  String? msgId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel({this.text,this.createdon,this.seen,this.sender,this.msgId});
  MessageModel.fromMap(Map<String,dynamic>map)
  {
    sender=map["sender"];
    text=map["text"];
    seen=map["seen"];
    createdon=map["createdon"].toDate();
    msgId=map["messageID"];
  }
  Map<String,dynamic>toMap()
  {
    return{
      "sender":sender,
      "text":text,
      "seen":seen,
      "createdon":createdon,
      "messageID":msgId
    };
  }

}