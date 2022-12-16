import 'dart:io';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:chargebee_flutter/src/utils/item.dart';
import 'package:chargebee_flutter/src/utils/plan.dart';
import 'package:chargebee_flutter/src/utils/product.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);

/* Configure the app details with chargebee system */
  static Future<void> configure(String site, String publishableApiKey,
      [String? iosSdkKey = "", androidSdkKey = ""]) async {
      if (Platform.isIOS) {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: iosSdkKey
        };

        await platform.invokeMethod(Constants.mAuthentication, args);
      } else {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: androidSdkKey,
        };
        await platform.invokeMethod(Constants.mAuthentication, args);
      }
  }

  /* Get the product/sku details from Play console/ App Store */
  static Future<List<Product>> retrieveProducts(
      List<String> productIDs) async {
     List<Product> products = [];
     final result = await platform.invokeMethod(Constants.mGetProducts,
          {Constants.productIDs: productIDs});
      if (result.isNotEmpty) {
        for (var i = 0; i < result.length; i++) {
          var obj = result[i].toString();
          Product product = Product.fromJson(jsonDecode(obj));
          products.add(product);
        }
      }
      return products;
  }

  /* Buy the product with/without customer Id */
  static Future<PurchaseResult> purchaseProduct(Product product,
      [String? customerId=""]) async {
      if (customerId == null) customerId = "";
      String purchaseResult = await platform.invokeMethod(
          Constants.mPurchaseProduct,
          {Constants.product: product.id, Constants.customerId: customerId});
      if (purchaseResult.isNotEmpty) {
        return PurchaseResult.fromJson(jsonDecode(purchaseResult.toString()));
      } else {
        return PurchaseResult(purchaseResult,purchaseResult, purchaseResult);
      }
  }

  /* Get the subscription details from chargebee system */
  static Future<List<Subscripton?>> retrieveSubscriptions(
      Map<String, String> queryParams) async {
    List<Subscripton> subscriptions = [];
    if (Platform.isIOS) {
        String result = await platform.invokeMethod(
            Constants.mSubscriptionMethod, queryParams);
        List jsonData = jsonDecode(result.toString());
        if(jsonData.isNotEmpty) {
          for (var value in jsonData) {
            var wrapper = SubscriptonList.fromJson(value);
            subscriptions.add(wrapper.subscripton!);
          }
        }
    } else {
        String result = await platform.invokeMethod(
            Constants.mSubscriptionMethod, queryParams);
        List jsonData = jsonDecode(result);
        if(jsonData.isNotEmpty) {
          for (var value in jsonData) {
            var wrapper = SubscriptonList.fromJsonAndroid(value);
            subscriptions.add(wrapper.subscripton!);
          }
        }
    }
    return subscriptions;
  }

  /* Get Apple/Google Product ID's from chargebee system */
  static Future<List> retrieveProductIdentifers(
      [Map<String, String>? queryParams]) async {
      String result = await platform.invokeMethod(
          Constants.mProductIdentifiers, queryParams);
      return jsonDecode(result);
  }

  /* Get entitlement details from chargebee system */
  static Future<List> retrieveEntitlements(
      Map<String, String> queryParams) async {
        String result = await platform.invokeMethod(
            Constants.mGetEntitlements, queryParams);
        return jsonDecode(result);
  }

  /* Get the list of items from chargebee system */
  static Future<List<CBItem?>> retrieveAllItems(
      [Map<String, String>? queryParams]) async {
    List itemsFromServer = [];
    List<CBItem> listItems = [];
    if (Platform.isIOS) {
        String result = await platform.invokeMethod(
            Constants.mRetrieveAllItems, queryParams);
        itemsFromServer = jsonDecode(result);
        for (var value in itemsFromServer) {
          var wrapper = CBItemsList.fromJson(value);
          listItems.add(wrapper.cbItem!);
        }
    } else {
        String result = await platform.invokeMethod(
            Constants.mRetrieveAllItems, queryParams);
        itemsFromServer = jsonDecode(result);
        for (var value in itemsFromServer) {
          var wrapper = CBItemsList.fromJsonAndroid(value);
          listItems.add(wrapper.cbItem!);
        }
    }
    return listItems;
  }
  /* Get the list of plans from chargebee system */
  static Future<List<CBPlan?>> retrieveAllPlans(
      [Map<String, String>? queryParams]) async {
    List plansFromServer = [];
    List<CBPlan> listPlans = [];
    if (Platform.isIOS) {
        String result = await platform.invokeMethod(
            Constants.mRetrieveAllPlans, queryParams);
        plansFromServer = jsonDecode(result);
        for (var value in plansFromServer) {
          var wrapper = CBPlansList.fromJson(value);
          listPlans.add(wrapper.cbPlan!);
        }
    } else {
        String result = await platform.invokeMethod(
            Constants.mRetrieveAllPlans, queryParams);
        plansFromServer = jsonDecode(result);
        for (var value in plansFromServer) {
          var wrapper = CBPlansList.fromJsonAndroid(value);
          listPlans.add(wrapper.cbPlan!);
        }
    }
    return listPlans;
  }
}
