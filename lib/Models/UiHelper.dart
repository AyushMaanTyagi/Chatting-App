import 'package:flutter/material.dart';

class Uihelper{
  static void ShowLoadingdialog(BuildContext context,String title){
    AlertDialog loadingDialog=AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30,),
            Text(title,style: TextStyle(fontSize: 20),)
          ],
        ),
      ),
    );
    showDialog(context: context, 
    barrierDismissible: false,//so that Loading dialog can not be removed unless this value be true
    builder: (context){
      return loadingDialog;
    });
  }


  static void showAlertDialog(BuildContext context,String title,content){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(content,style: TextStyle(fontSize: 15),),
      actions: [
        TextButton(
          onPressed: (){Navigator.pop(context);},
          child: Text("Ok"),
        )
      ],
    );

    showDialog(context: context, builder: (context)
    {
      return alertDialog;
    });
  }
}