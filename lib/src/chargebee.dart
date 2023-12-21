import 'dart:convert';
import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);
  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Sets up Chargebee SDK with site, API key and SDK key for Android and iOS.
  ///
  /// [site] site Chargebee site.
  /// Example: If the Chargebee domain url is https://mobile-test.chargebee.com, then the site value is 'mobile-test'.
  ///
  /// [publishableApiKey] publishableApiKey Publishable API key generated for your Chargebee Site.
  /// Refer: https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key.
  ///
  /// [iosSdkKey] iosSdkKey iOS SDK key.
  /// Refer: https://www.chargebee.com/docs/1.0/mobile-playstore-notifications.html#app-id.
  ///
  /// [androidSdkKey] androidSdkKey Android SDK key.
  /// Refer: https://www.chargebee.com/docs/1.0/mobile-app-store-product-iap.html#connection-keys_app-id.
  ///
  /// Throws an [PlatformException] in case of configure api fails.
  static Future<void> configure(
    String site,
    String publishableApiKey, [
    String? iosSdkKey = '',
    androidSdkKey = '',
  ]) async {
    if (_isIOS) {
      final args = {
        Constants.siteName: site,
        Constants.apiKey: publishableApiKey,
        Constants.sdkKey: iosSdkKey,
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

  /// Retrieves products from Google/Apple Store for give product identifiers.
  ///
  /// [productIDs] The list of product identifiers to be passed to productIDs.
  /// Example: ['cbtest'].
  ///
  /// The list of [Product] object be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<Product>> retrieveProducts(List<String> productIDs) async {
    final products = <Product>[];
    final List result = await platform.invokeMethod(
      Constants.mGetProducts,
      {Constants.productIDs: productIDs},
    );
    if (result.isNotEmpty) {
      for (var i = 0; i < result.length; i++) {
        final obj = result[i].toString();
        final product = Product.fromJson(jsonDecode(obj));
        products.add(product);
      }
    }
    return products;
  }

  /// Buy the product with/without customer id.
  ///
  /// [product] product object to be passed.
  ///
  /// [customerId] it can be optional.
  /// if passed, the subscription will be created by using customerId in chargebee.
  /// if not passed, the value of customerId is same as SubscriptionId.
  ///
  /// If purchase success [PurchaseResult] object be returned.
  /// Throws an [PlatformException] in case of failure.
  @Deprecated(
    'This method will be removed in upcoming release, Use purchaseStoreProduct API instead',
  )
  static Future<PurchaseResult> purchaseProduct(
    Product product, [
    String? customerId = '',
  ]) async {
    final map = _convertToMap(product, customerId: customerId);
    return _purchaseResult(map);
  }

  /// Buy the product with/without customer data.
  ///
  /// [product] product object to be passed.
  ///
  /// [customer] it can be optional.
  /// if passed, the subscription will be created by using customerId in chargebee.
  /// if not passed, the value of customerId is same as SubscriptionId.
  ///
  /// If purchase success [PurchaseResult] object be returned.
  /// Throws an [PlatformException] in case of failure.
  static Future<PurchaseResult> purchaseStoreProduct(
    Product product, {
    CBCustomer? customer,
  }) async {
    final map = _convertToMap(product, customer: customer);
    return _purchaseResult(map);
  }

  static Future<PurchaseResult> _purchaseResult(Map params) async {
    final String purchaseResult = await platform.invokeMethod(
      Constants.mPurchaseProduct,
      params,
    );
    if (purchaseResult.isNotEmpty) {
      return PurchaseResult.fromJson(jsonDecode(purchaseResult.toString()));
    } else {
      return PurchaseResult(purchaseResult, purchaseResult, purchaseResult);
    }
  }

  /// This method will be used to show Manage Subscriptions Settings in your App,
  ///
  /// [productId] it is optional.
  ///
  /// [applicationId] it is optional. packageName/bundleId of the app
  static Future<void> showManageSubscriptionsSettings([
    String? productId = '',
    String? applicationId = '',
  ]) async {
    await platform.invokeMethod(
      Constants.mShowManageSubscriptionsSettings,
      {Constants.productId: productId, Constants.applicationId: applicationId},
    );
  }

  /// Buy the non-subscription product with/without customer data.
  ///
  /// [product] product object to be passed.
  ///
  /// [productType] One time Product Type. Consumable or Non-Consumable
  /// [customer] it can be optional.
  /// if passed, the subscription will be created by using customerId in chargebee.
  /// if not passed, the value of customerId is same as SubscriptionId.
  ///
  /// If purchase success [NonSubscriptionPurchaseResult] object be returned.
  /// Throws an [PlatformException] in case of failure.
  static Future<NonSubscriptionPurchaseResult> purchaseNonSubscriptionProduct(
    Product product,
    ProductType productType, [
    CBCustomer? customer,
  ]) async {
    final params = {
      Constants.product: product.id,
      Constants.customerId: customer?.id ?? '',
      Constants.firstName: customer?.firstName ?? '',
      Constants.lastName: customer?.lastName ?? '',
      Constants.email: customer?.email ?? '',
      Constants.productType: productType.name,
    };
    String purchaseResult = await platform.invokeMethod(
      Constants.mPurchaseNonSubscriptionProduct,
      params,
    );
    if (purchaseResult.isNotEmpty) {
      purchaseResult = purchaseResult.toString();
    }
    return NonSubscriptionPurchaseResult.fromJson(jsonDecode(purchaseResult));
  }

  /// Retrieves the subscriptions by customer_id or subscription_id.
  ///
  /// [queryParams] The map value to be passed as queryParams.
  /// Example: {"customer_id": "abc"}.
  ///
  /// The list of [Subscripton] object be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<Subscripton?>> retrieveSubscriptions(
    Map<String, String> queryParams,
  ) async {
    final subscriptions = <Subscripton>[];
    if (_isIOS) {
      final String result = await platform.invokeMethod(
        Constants.mSubscriptionMethod,
        queryParams,
      );
      final List jsonData = jsonDecode(result.toString());
      if (jsonData.isNotEmpty) {
        for (final value in jsonData) {
          final wrapper = SubscriptonList.fromJson(value);
          subscriptions.add(wrapper.subscripton!);
        }
      }
    } else {
      final String result = await platform.invokeMethod(
        Constants.mSubscriptionMethod,
        queryParams,
      );
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

  /// Retrieves available product identifiers.
  ///
  /// [queryParams] The map value to be passed as queryParams.
  /// Example: {"limit": "10"}.
  ///
  /// The list of product identifiers be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  @Deprecated(
    'This method will be removed in upcoming release, Use retrieveProductIdentifiers instead',
  )
  static Future<List<String>> retrieveProductIdentifers([
    Map<String, String>? queryParams,
  ]) async =>
      retrieveProductIdentifiers(queryParams);

  /// Retrieves available product identifiers.
  ///
  /// [queryParams] The map value to be passed as queryParams.
  /// Example: {"limit": "10"}.
  ///
  /// The list of product identifiers be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<String>> retrieveProductIdentifiers([
    Map<String, String>? queryParams,
  ]) async {
    final String result =
        await platform.invokeMethod(Constants.mProductIdentifiers, queryParams);
    return CBProductIdentifierWrapper.fromJson(jsonDecode(result))
        .productIdentifiersList;
  }

  /// Retrieves entitlements for the subscription.
  ///
  /// [queryParams] The map value to be passed passed as queryParams.
  /// Example: {"subscriptionId": "XXXXXXX"}.
  ///
  /// The list of [CBEntitlementWrapper] object to be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<CBEntitlementWrapper>> retrieveEntitlements(
    Map<String, String> queryParams,
  ) async {
    final String result =
        await platform.invokeMethod(Constants.mGetEntitlements, queryParams);
    return CBEntitlementList.fromJson(jsonDecode(result)).entitlementsList;
  }

  /// Retrieves list of item object.
  ///
  /// [queryParams] The map value to be passed as queryParams.
  /// Example: {"limit": "10"}.
  ///
  /// The list of [CBItem] object be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<CBItem?>> retrieveAllItems([
    Map<String, String>? queryParams,
  ]) async {
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

  /// Retrieves list of plan object.
  ///
  /// [queryParams] The map value to be passed as queryParams.
  /// Example: {"limit": "10"}.
  ///
  /// The list of [CBPlan] object be returned if api success.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<CBPlan?>> retrieveAllPlans([
    Map<String, String>? queryParams,
  ]) async {
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

  /// Restores the subscriptions for the user logged in the device.
  ///
  /// [bool] includeInactivePurchases When set to true, the inactive purchases are also synced to Chargebee.
  ///
  /// The list of [CBRestoreSubscription] object be returned.
  /// Throws an [PlatformException] in case of failure.
  static Future<List<CBRestoreSubscription>> restorePurchases([
    bool includeInactivePurchases = false,
    CBCustomer? customer,
  ]) async {
    final restorePurchases = <CBRestoreSubscription>[];
    final params = {
      Constants.customerId: customer?.id ?? '',
      Constants.firstName: customer?.firstName ?? '',
      Constants.lastName: customer?.lastName ?? '',
      Constants.email: customer?.email ?? '',
      Constants.includeInactivePurchases: includeInactivePurchases,
    };
    final List result = await platform.invokeMethod(
      Constants.mRestorePurchase,
      params,
    );
    debugPrint('result $result');
    if (result.isNotEmpty) {
      for (var i = 0; i < result.length; i++) {
        final subscription =
            CBRestoreSubscription.fromJson(jsonDecode(result[i].toString()));
        restorePurchases.add(subscription);
      }
    }
    return restorePurchases;
  }

  /// This method will be used to validate the receipt of Subscriptions with Chargebee,
  /// when syncing with Chargebee fails after the successful purchase in Google Play Store.
  ///
  /// [productId] productId to be passed.
  ///
  /// [customer] customer object is optional.
  /// if passed, the subscription will be created with customer info provided in chargebee.
  /// if not passed, the value of customerId is same as subscriptionId.
  ///
  /// If validate receipt success [PurchaseResult] object be returned.
  /// Throws an [PlatformException] in case of failure.
  static Future<PurchaseResult> validateReceipt(
    String productId, [
    CBCustomer? customer,
  ]) async {
    var purchaseResult = PurchaseResult('', '', '');
    final params = {
      Constants.product: productId,
      Constants.customerId: customer?.id ?? '',
      Constants.firstName: customer?.firstName ?? '',
      Constants.lastName: customer?.lastName ?? '',
      Constants.email: customer?.email ?? '',
    };
    final String result = await platform.invokeMethod(
      Constants.mValidateReceipt,
      params,
    );
    if (result.isNotEmpty) {
      purchaseResult = PurchaseResult.fromJson(jsonDecode(result.toString()));
    }
    return purchaseResult;
  }

  /// This method will be used to validate the receipt of One Time Purchase with Chargebee,
  /// when syncing with Chargebee fails after the successful purchase in Google Play Store.
  ///
  /// [productId] productId to be passed.
  ///
  /// [productType] One time Product Type. Consumable or Non-Consumable
  /// [customer] it can be optional.
  /// if passed, the subscription will be created by using customerId in chargebee.
  /// if not passed, the value of customerId is same as SubscriptionId.
  ///
  /// If purchase success [NonSubscriptionPurchaseResult] object be returned.
  /// Throws an [PlatformException] in case of failure.
  static Future<NonSubscriptionPurchaseResult>
      validateReceiptForNonSubscriptions(
    String productId,
    ProductType productType, [
    CBCustomer? customer,
  ]) async {
    final params = {
      Constants.product: productId,
      Constants.customerId: customer?.id ?? '',
      Constants.firstName: customer?.firstName ?? '',
      Constants.lastName: customer?.lastName ?? '',
      Constants.email: customer?.email ?? '',
      Constants.productType: productType.name,
    };
    String purchaseResult = await platform.invokeMethod(
      Constants.mValidateReceiptForNonSubscriptions,
      params,
    );
    if (purchaseResult.isNotEmpty) {
      purchaseResult = purchaseResult.toString();
    }
    return NonSubscriptionPurchaseResult.fromJson(jsonDecode(purchaseResult));
  }

  static Map _convertToMap(
    Product product, {
    String? customerId = '',
    CBCustomer? customer,
  }) {
    String? id = '';
    if (customerId?.isNotEmpty ?? false) {
      id = customerId;
    } else if (customer?.id?.isNotEmpty ?? false) {
      id = customer?.id;
    }
    return {
      Constants.product: product.id,
      Constants.customerId: id,
      Constants.firstName: customer?.firstName ?? '',
      Constants.lastName: customer?.lastName ?? '',
      Constants.email: customer?.email ?? '',
    };
  }
}
