import 'dart:developer';
import 'dart:io';
import 'package:chargebee_flutter_sdk/src/constants.dart';
import 'package:chargebee_flutter_sdk/src/utils/cb_exception.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../chargebee_flutter_sdk.dart';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);

  static Future<void> configure(
      String site, String publishableApiKey, [String? sdkKey = "", packageName=""]) async {
    try {
      if (Platform.isIOS) {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: sdkKey
        };

        await platform.invokeMethod(Constants.mAuthentication, args);
      } else {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: sdkKey,
          Constants.packageName: packageName
        };
        await platform.invokeMethod(Constants.mAuthentication, args);
      }
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
  }

  /* Get the product/sku details from Play console/ App Store */
  static Future<List<Product>> getProductIdList(List<String> listID) async {
    List<Object?> result = [];
    List<Product> products = [];
    try {
      result = await platform
          .invokeMethod(Constants.mGetProducts, {Constants.productIDs: listID});
      if(result.isNotEmpty){
        for (var i = 0; i < result.length; i++) {
          var obj = result[i].toString();
          Product product = Product.fromJson(jsonDecode(obj));
          products.add(product);
        }
      }
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
    return products;
  }

  /* Buy the product with/without customer Id */
  static Future<PurchaseResult> purchaseProduct(
      Product product, [String? customerId]) async {

    String jsonString = await platform.invokeMethod(Constants.mPurchaseProduct,
        {Constants.product: product.id, Constants.customerId: customerId});
    if(jsonString.isNotEmpty){
      return PurchaseResult.fromJson(jsonDecode(jsonString.toString()));
    }else{
      return PurchaseResult("", jsonString);
    }

  }
  /* Get the subscription details from chargebee system */
  static Future<List<Object?>> retrieveSubscriptions(
      String queryParams) async {
    List<dynamic> result = [];
    if (Platform.isIOS) {
      try {
        result = await platform.invokeMethod(Constants.mSubscriptionMethod,
            {Constants.customerId: queryParams});
        log('result : $result');

        return result;
      } on CBException catch (e) {
        log('CBException : ${e.message}');
      }
    }else{
      try {
        result = await platform.invokeMethod(Constants.mSubscriptionMethod, {Constants.customerId: queryParams});
        log('result : $result');
        return result;
      } on CBException catch (e) {
        log('CBException : ${e.message}');
      }
    }
    return result;
  }


  static Future<void> retrieveAllItems() async {
    String result;
    try {
      await platform.invokeMethod('retrieveAllItems').then((value) {
        result = value.toString();
        log('retrieveItems : $result');
        List<String> listItems = result.split(',');
      });
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
  }

  Future<void> retrieveAllPlans() async {
    String result;
    try {
      await platform.invokeMethod('retrieveAllPlans').then((value) {
        result = value.toString();
        log('retrieveAllPlans : $result');
        List<String> listItems = result.split(',');
      });
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
  }

  static Future<Map<String, String>> PurchaseProductNew(queryParams) async {
    var result = <String, String>{};
    try {
      log('PlatformException : $queryParams');
      result = await platform.invokeMethod('purchaseProduct', queryParams);
      print('result  : $result');
      return result;
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
    return result;
  }

  static Future<List<Object?>> getProducts(List<String> listID) async {
    List<Object?> result = [];
    try {
      result = await platform
          .invokeMethod(Constants.mGetProducts, {Constants.productIDs: listID});
      print('result  : $result');
      return result;
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
    return result;
  }
}
