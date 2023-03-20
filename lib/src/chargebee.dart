import 'dart:io';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:chargebee_flutter/src/models/item.dart';
import 'package:chargebee_flutter/src/models/plan.dart';
import 'package:chargebee_flutter/src/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);
  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /* Configure the app details with chargebee system */
  static Future<void> configure(String site, String publishableApiKey,
      [String? iosSdkKey = '', androidSdkKey = '',]) async {
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

  /* Get the product/sku details from Play console/ App Store */
  static Future<List<Product>> retrieveProducts(List<String> productIDs) async {
    final products = <Product>[];
    final String result = await platform.invokeMethod(
        Constants.mGetProducts, {Constants.productIDs: productIDs},);
    if (result.isNotEmpty) {
      for (var i = 0; i < result.length; i++) {
        final obj = result[i].toString();
        final product = Product.fromJson(jsonDecode(obj));
        products.add(product);
      }
    }
    return products;
  }

  /* Buy the product with/without customer Id */
  static Future<PurchaseResult> purchaseProduct(Product product,
      [String? customerId = '',]) async {
    customerId ??= '';
    final String purchaseResult = await platform.invokeMethod(
        Constants.mPurchaseProduct,
        {Constants.product: product.id, Constants.customerId: customerId},);
    if (purchaseResult.isNotEmpty) {
      return PurchaseResult.fromJson(jsonDecode(purchaseResult.toString()));
    } else {
      return PurchaseResult(purchaseResult, purchaseResult, purchaseResult);
    }
  }

  /* Get the subscription details from chargebee system */
  static Future<List<Subscripton?>> retrieveSubscriptions(
      Map<String, String> queryParams,) async {
    final subscriptions = <Subscripton>[];
    if (_isIOS) {
      final String result = await platform.invokeMethod(
          Constants.mSubscriptionMethod, queryParams,);
      final List jsonData = jsonDecode(result.toString());
      if (jsonData.isNotEmpty) {
        for (final value in jsonData) {
          final wrapper = SubscriptonList.fromJson(value);
          subscriptions.add(wrapper.subscripton!);
        }
      }
    } else {
      final String result = await platform.invokeMethod(
          Constants.mSubscriptionMethod, queryParams,);
      final List jsonData = jsonDecode(result);
      if (jsonData.isNotEmpty) {
        for (final value in jsonData) {
          final wrapper = SubscriptonList.fromJsonAndroid(value);
          subscriptions.add(wrapper.subscripton!);
        }
      }
    }
    return subscriptions;
  }

  /* Get Apple/Google Product ID's from chargebee system */
  @Deprecated('This method will be removed in upcoming release, Use retrieveProductIdentifiers instead')
  static Future<List> retrieveProductIdentifers(
      [Map<String, String>? queryParams]) async {
    return retrieveProductIdentifiers(queryParams);
  }

/* Get Apple/Google Product ID's from chargebee system */
  static Future<List> retrieveProductIdentifiers(
      [Map<String, String>? queryParams]) async {
    String result =
    await platform.invokeMethod(Constants.mProductIdentifiers, queryParams);
    return jsonDecode(result);
  }

  /* Get entitlement details from chargebee system */
  static Future<List> retrieveEntitlements(
      Map<String, String> queryParams,) async {
    final String result =
        await platform.invokeMethod(Constants.mGetEntitlements, queryParams);
    return jsonDecode(result);
  }

  /* Get the list of items from chargebee system */
  static Future<List<CBItem?>> retrieveAllItems(
      [Map<String, String>? queryParams,]) async {
    var itemsFromServer = [];
    final listItems = <CBItem>[];
    if (_isIOS) {
      final String result =
          await platform.invokeMethod(Constants.mRetrieveAllItems, queryParams);
      itemsFromServer = jsonDecode(result);
      for (final value in itemsFromServer) {
        final wrapper = CBItemsList.fromJson(value);
        listItems.add(wrapper.cbItem!);
      }
    } else {
      final String result =
          await platform.invokeMethod(Constants.mRetrieveAllItems, queryParams);
      itemsFromServer = jsonDecode(result);
      for (final value in itemsFromServer) {
        final wrapper = CBItemsList.fromJsonAndroid(value);
        listItems.add(wrapper.cbItem!);
      }
    }
    return listItems;
  }

  /* Get the list of plans from chargebee system */
  static Future<List<CBPlan?>> retrieveAllPlans(
      [Map<String, String>? queryParams,]) async {
    var plansFromServer = [];
    final listPlans = <CBPlan>[];
    if (_isIOS) {
      final String result =
          await platform.invokeMethod(Constants.mRetrieveAllPlans, queryParams);
      plansFromServer = jsonDecode(result);
      for (final value in plansFromServer) {
        final wrapper = CBPlansList.fromJson(value);
        listPlans.add(wrapper.cbPlan!);
      }
    } else {
      final String result =
          await platform.invokeMethod(Constants.mRetrieveAllPlans, queryParams);
      plansFromServer = jsonDecode(result);
      for (final value in plansFromServer) {
        final wrapper = CBPlansList.fromJsonAndroid(value);
        listPlans.add(wrapper.cbPlan!);
      }
    }
    return listPlans;
  }
}
