import 'package:flutter/material.dart';

class BaseAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  const BaseAlertDialog(this.title, this.content, {Key? key}) : super(key: key);

  final TextStyle textStyle = const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(
        title,
        style: textStyle,
      ),
      content: Text(
        content,
        style: textStyle,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
}
