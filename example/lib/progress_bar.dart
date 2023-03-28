import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ProgressBarUtil {
  static late ProgressDialog pr;

  ProgressBarUtil(BuildContext context) {
    pr = ProgressDialog(context);
  }

  Future<void> showProgressDialog() async {
    pr.style(
        message: 'Loading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        // textDirection: TextDirection.rtl,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400,),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600,),
    );

    await pr.show();
  }

  Future<void> hideProgressDialog() async {
    await pr.hide();
  }

  bool isProgressBarShowing()=> pr.isShowing();

}
