import 'dart:developer';
import 'dart:io';
import 'package:chargebee_flutter_sdk/src/constants.dart';
import 'package:chargebee_flutter_sdk/src/model/cb_product.dart';
import 'package:chargebee_flutter_sdk/src/model/sku_Item.dart';
import 'package:chargebee_flutter_sdk/src/utils/cb_support.dart';
import 'package:flutter/services.dart';

class ChargebeeFlutterMethods {
  static const platform = MethodChannel(Constants.methodChannelName);

  static Future<void> authentication(
      String siteName, String apiKey, String sdkKey) async {
    try {
      if (Platform.isIOS) {
        final args = {
          Constants.siteName: siteName,
          Constants.apiKey: apiKey,
          Constants.sdkKey: sdkKey
        };

        await platform.invokeMethod(Constants.mAuthentication, args);
      } else {
        final args = {
          Constants.siteName: siteName,
          Constants.apiKey: apiKey,
          Constants.sdkKey: sdkKey
        };
        await platform.invokeMethod(Constants.mAuthentication, args);
      }
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
  }

  static Future<List<Map<String, dynamic>>> getProductIdList(
      List<String> listID) async {
    List<Object?> result = [];
    List<Map<String, dynamic>> cbProductList = [];

    try {
      result = await platform
          .invokeMethod(Constants.mGetProducts, {Constants.productIDs: listID});

      if (Platform.isIOS) {
        print('result  : $result');
      } else {
        for (var i = 0; i < result.length; i++) {
          CBProduct output = CBMapper.cbProductsFromJson(result[i].toString());

          Map<String, dynamic> map = output.toJson();

          cbProductList.add(map);
        }
        print('ProductList  : $cbProductList');
      }
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
    return cbProductList;
  }

  static Future<Map<dynamic, dynamic>> purchaseProduct(
      Map<String, dynamic> product, String customerId) async {
    Map<dynamic, dynamic> result = {};

    print('product  : $product');
    print('customerId  : $customerId');

    SkuDetailsWrapper skuProperties = product["skuDetails"];
    String skuDetails = skuProperties.skuDetails;
    Map<String, dynamic> map = {
      "skuDetails": skuDetails,
      "customerId": customerId
    };

    try {
      result = await platform
          .invokeMethod(Constants.mPurchaseProduct, {Constants.product: map});

      if (Platform.isIOS) {
        print('result from flutter plugIn: $result');
      } else {
        print('result from flutter plugIn  : $result');
      }

      return result;
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
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
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
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
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
  }

  static Future<List<Object?>> retrieveSubscriptions(
      Map<String, dynamic> queryParams) async {
    List<Object?> result = [];
    try {
      log('PlatformException : $queryParams');
      result =
          await platform.invokeMethod('retrieveSubscriptions', queryParams);
      print('result  : $result');
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
    return result;
  }
}
