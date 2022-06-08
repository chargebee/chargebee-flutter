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

class Product {
  String id;
  String price;
  String title;
  Product(this.id, this.price, this.title);

  factory Product.fromJson(dynamic json) {
    print(json);
    print(json['productId'] as String);

    return Product(json['productId'] as String, json['productPrice'] as String,
        json['productTitle'] as String);
  }
}

class PurchaseResult {
  String subscriptionId;
  String status;
  PurchaseResult(this.subscriptionId, this.status);

  factory PurchaseResult.fromJson(dynamic json) {
    return PurchaseResult(json['id'] as String, json['status'] as String);
  }
}
