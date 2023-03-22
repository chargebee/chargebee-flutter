import 'dart:io';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:chargebee_flutter/src/models/item.dart';
import 'package:chargebee_flutter/src/models/plan.dart';
import 'package:chargebee_flutter/src/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);
  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Configure the app details with your site, publishableApiKey and sdkKey
  /// [site] site which created in chargebee. eg. xxx.chargebee.com
  /// [publishableApiKey] Chargebee API Key
  /// [iosSdkKey] Cconnect the app store with Chargebee and get the iOS sdk key
  /// [androidSdkKey] Cconnect the app store with Chargebee and get the Android sdk key
  static Future<void> configure(String site, String publishableApiKey,
      [String? iosSdkKey = "", androidSdkKey = ""]) async {
    if (_isIOS) {
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

  /// Get the product/sku details from Play console/ App Store
  /// [productIDs] list of actual product ids which created in App Store Connect/Google Play Store
  static Future<List<Product>> retrieveProducts(List<String> productIDs) async {
    List<Product> products = [];
    final result = await platform.invokeMethod(
        Constants.mGetProducts, {Constants.productIDs: productIDs});
    if (result.isNotEmpty) {
      for (var i = 0; i < result.length; i++) {
        var obj = result[i].toString();
        Product product = Product.fromJson(jsonDecode(obj));
        products.add(product);
      }
    }
    return products;
  }

  /// Buy the product with/without customer Id
  /// [product] product information that trying to purchase the subscription
  /// [customerId] it can be optional. if passed, the subscription will be created by using customerId in chargebee
  /// if not passed, the value of customerId is same as SubscriptionId
  static Future<PurchaseResult> purchaseProduct(Product product,
      [String? customerId = ""]) async {
    if (customerId == null) customerId = "";
    String purchaseResult = await platform.invokeMethod(
        Constants.mPurchaseProduct,
        {Constants.product: product.id, Constants.customerId: customerId});
    if (purchaseResult.isNotEmpty) {
      return PurchaseResult.fromJson(jsonDecode(purchaseResult.toString()));
    } else {
      return PurchaseResult(purchaseResult, purchaseResult, purchaseResult);
    }
  }

  /// Get the subscription details from chargebee system
  /// [queryParams] After purchase the product, fetch the subscription details by using query params like {"customer_id": "abc"}
  static Future<List<Subscripton?>> retrieveSubscriptions(
      Map<String, String> queryParams) async {
    List<Subscripton> subscriptions = [];
    if (_isIOS) {
      String result = await platform.invokeMethod(
          Constants.mSubscriptionMethod, queryParams);
      List jsonData = jsonDecode(result.toString());
      if (jsonData.isNotEmpty) {
        for (var value in jsonData) {
          var wrapper = SubscriptonList.fromJson(value);
          subscriptions.add(wrapper.subscripton!);
        }
      }
    } else {
      String result = await platform.invokeMethod(
          Constants.mSubscriptionMethod, queryParams);
      List jsonData = jsonDecode(result);
      if (jsonData.isNotEmpty) {
        for (var value in jsonData) {
          var wrapper = SubscriptonList.fromJsonAndroid(value);
          subscriptions.add(wrapper.subscripton!);
        }
      }
    }
    return subscriptions;
  }

  /// Get Apple/Google Product ID's from chargebee system
  /// [queryParams] pass the params(Eg. {"limit": "10"}) and fetch the list of product identifiers from chargebee
  @Deprecated('This method will be removed in upcoming release, Use retrieveProductIdentifiers instead')
  static Future<List<String>> retrieveProductIdentifers(
      [Map<String, String>? queryParams]) async {
    return retrieveProductIdentifiers(queryParams);
  }

  /// Get Apple/Google Product ID's from chargebee system
  /// [queryParams] pass the params(Eg. {"limit": "10"}) and fetch the list of product identifiers from chargebee
  static Future<List<String>> retrieveProductIdentifiers(
      [Map<String, String>? queryParams]) async {
    String result =
    await platform.invokeMethod(Constants.mProductIdentifiers, queryParams);
    return CBProductIdentifierWrapper.fromJson(jsonDecode(result)).productIdentifiersList;
  }

  /// Get entitlement details from chargebee system
  /// [queryParams] queryParams - eg. {"subscriptionId": "XXXXXXX"}
  /// Get the list of entitlements associated with the subscription.
  static Future<List<String>> retrieveEntitlements(
      Map<String, String> queryParams) async {
    String result =
        await platform.invokeMethod(Constants.mGetEntitlements, queryParams);
    return CBEntitlementWrapper.fromJson(jsonDecode(result)).entitlementsList;
  }

  /// Get the list of items from chargebee system
  /// [queryParams] queryParams - eg. {"limit": "10"}
  /// Fetch Items associated with a subscription
  static Future<List<CBItem?>> retrieveAllItems(
      [Map<String, String>? queryParams]) async {
    List itemsFromServer = [];
    List<CBItem> listItems = [];
    if (_isIOS) {
      String result =
          await platform.invokeMethod(Constants.mRetrieveAllItems, queryParams);
      itemsFromServer = jsonDecode(result);
      for (var value in itemsFromServer) {
        var wrapper = CBItemsList.fromJson(value);
        listItems.add(wrapper.cbItem!);
      }
    } else {
      String result =
          await platform.invokeMethod(Constants.mRetrieveAllItems, queryParams);
      itemsFromServer = jsonDecode(result);
      for (var value in itemsFromServer) {
        var wrapper = CBItemsList.fromJsonAndroid(value);
        listItems.add(wrapper.cbItem!);
      }
    }
    return listItems;
  }

  /// Get the list of plans from chargebee system
  /// [queryParams] queryParams - eg. {"limit": "10"}
  /// Fetch plans associated with a subscription
  static Future<List<CBPlan?>> retrieveAllPlans(
      [Map<String, String>? queryParams]) async {
    List plansFromServer = [];
    List<CBPlan> listPlans = [];
    if (_isIOS) {
      String result =
          await platform.invokeMethod(Constants.mRetrieveAllPlans, queryParams);
      plansFromServer = jsonDecode(result);
      for (var value in plansFromServer) {
        var wrapper = CBPlansList.fromJson(value);
        listPlans.add(wrapper.cbPlan!);
      }
    } else {
      String result =
          await platform.invokeMethod(Constants.mRetrieveAllPlans, queryParams);
      plansFromServer = jsonDecode(result);
      for (var value in plansFromServer) {
        var wrapper = CBPlansList.fromJsonAndroid(value);
        listPlans.add(wrapper.cbPlan!);
      }
    }
    return listPlans;
  }
}
