/*
import 'dart:async';
import 'dart:developer';

import 'package:chargebee_flutter_sdk/src/constants.dart';
import 'package:flutter/services.dart';

class ChargebeeFlutterSdk {
  static const MethodChannel _channel = MethodChannel('chargebee_flutter_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> authentication() async {
    try {
      await _channel.invokeMethod(Constants.mAuthentication);

    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
  }
}*/

export 'src/chargebee.dart';