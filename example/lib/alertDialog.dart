import 'dart:ui';
import 'package:flutter/material.dart';


class BaseAlertDialog extends StatelessWidget {
  String title;
  String content;

  BaseAlertDialog(this.title, this.content);
  TextStyle textStyle = TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: new Text(title,style: textStyle,),
          content: new Text(content, style: textStyle,),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
  }
}

