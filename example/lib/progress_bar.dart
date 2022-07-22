
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ProgressBarUtil{

  static late ProgressDialog pr;

  ProgressBarUtil(BuildContext context){
    pr  = ProgressDialog(context);
  }
  void showProgressDialog() async {
    pr.style(
        message: 'Loading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        // textDirection: TextDirection.rtl,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );

    await pr.show();
  }

  void hideProgressDialog() async {
    await pr.hide();
  }

  bool isProgressBarShowing(){
    return pr.isShowing();
  }

}