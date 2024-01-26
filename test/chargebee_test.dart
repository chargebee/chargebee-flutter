import 'dart:convert';

import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('chargebee_flutter');
  TestWidgetsFlutterBinding.ensureInitialized();
  const siteName = 'SITE_NAME';
  const apiKey = 'API_KEY';
  const iosSDKKey = 'iOS SDK Key';
  const androidSDKKey = 'Android SDK Key';

  late dynamic channelResponse;
  final callStack = <MethodCall>[];

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      callStack.add(methodCall);
      return channelResponse;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    callStack.clear();
    channelResponse = null;
  });

  group('configure', () {
    test('works for iOS', () async {
      channelResponse = true;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await Chargebee.configure(siteName, apiKey, iosSDKKey);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mAuthentication,
          arguments: <String, dynamic>{
            Constants.siteName: siteName,
            Constants.apiKey: apiKey,
            Constants.sdkKey: iosSDKKey
          },
        )
      ]);
    });

    test('works for android', () async {
      channelResponse = true;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await Chargebee.configure(siteName, apiKey, '', androidSDKKey);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mAuthentication,
          arguments: <String, dynamic>{
            Constants.siteName: siteName,
            Constants.apiKey: apiKey,
            Constants.sdkKey: androidSDKKey
          },
        )
      ]);
    });

    test('handles exception', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(code: 'Dummy');
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
        () => Chargebee.configure(siteName, apiKey, iosSDKKey),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveProductIdentifers', () {
    test('returns the list of Product Identifiers', () async {
      const productIdentifiersString =
          '''["chargebee.price.change","chargebee.premium.android","merchant.start.android"]''';
      channelResponse = productIdentifiersString;
      final queryparam = <String, String>{'limit': '100'};
      final productIdentifiers =
          await Chargebee.retrieveProductIdentifiers(queryparam);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mProductIdentifiers,
          arguments: queryparam,
        )
      ]);
      expect(productIdentifiers, jsonDecode(productIdentifiersString));
    });

    test('handles exception', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final queryparam = <String, String>{'limit': '100'};
      await expectLater(
        () => Chargebee.retrieveProductIdentifiers(queryparam),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveProducts', () {
    final queryparam = <String>['merchant.pro.android'];
    const map = '''{
      "currencyCode": "USD",
      "subscriptionPeriod": {
        "periodUnit": "year",
        "numberOfUnits": 1
      },
      "productPriceString": "9.99",
      "productId": "chargebee.pro.ios",
      "productPrice": 9.9900000000000002,
      "productTitle": "Pro Plan"
    }''';
    final retrieveProductsResult = [map];

    test('returns the list of Product for Android', () async {
      channelResponse = retrieveProductsResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final result = await Chargebee.retrieveProducts(queryparam);
        expect(callStack, <Matcher>[
          isMethodCall(
            Constants.mGetProducts,
            arguments: {Constants.productIDs: queryparam},
          )
        ]);
        expect(result.isNotEmpty, true);
      } on PlatformException catch (e) {
        debugPrint('exception: ${e.message}');
      }
    });

    test('returns the list of Product for iOS', () async {
      channelResponse = retrieveProductsResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.retrieveProducts(queryparam);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mGetProducts,
          arguments: {Constants.productIDs: queryparam},
        )
      ]);
      expect(result.isNotEmpty, true);
    });

    test('handles exception', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: 'PlatformError', message: 'An error occured',);
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(() => Chargebee.retrieveProducts(queryparam),
          throwsA(isA<PlatformException>()),);
      channel.setMockMethodCallHandler(null);
    });
  });

  group('purchaseProduct', () {
    final map = <String, dynamic>{'unit': 'year', 'numberOfUnits': 1};
    final product = Product(
      'merchant.pro.android',
      1500.00,
      '1500.00',
      'title',
      'INR',
      SubscriptionPeriod.fromMap(map),
    );
    const purchaseResult =
        '''{"subscriptionId":"cb-dsd", "planId":"test", "status":"active"}''';
    final customer = CBCustomer(
      'abc',
      '',
      '',
      '',
    );
    final params = {
      Constants.product: product.id,
      Constants.customerId: customer.id ?? '',
      Constants.firstName: customer.firstName ?? '',
      Constants.lastName: customer.lastName ?? '',
      Constants.email: customer.email ?? '',
    };
    test('returns subscription result for Android', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseProduct(product, 'abc');
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments: params,
        )
      ]);
      expect(result.status, 'active');
    });

    test('returns subscription result for iOS', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.purchaseProduct(product, 'abc');
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments: params,
        )
      ]);
      expect(result.status, 'active');
    });

    test('subscribed with customer id for Android', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseProduct(product, 'abc');
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments:  params,
        )
      ]);
      expect(result.status, 'active');
    });

    test('subscribed with customer id for iOS', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseProduct(product, 'abc');
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments: params,
        )
      ]);
      expect(result.status, 'active');
    });

    test('subscribed with customer info for Android', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseStoreProduct(product, customer: CBCustomer('abc_flutter_test', 'flutter', 'test', 'abc@gmail.com'));
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments: {
            Constants.product: product.id,
            Constants.customerId: 'abc_flutter_test',
            Constants.firstName: 'flutter',
            Constants.lastName: 'test',
            Constants.email: 'abc@gmail.com',
          },
        )
      ]);
      expect(result.status, 'active');
    });

    test('subscribed with customer info for iOS', () async {
      channelResponse = purchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseStoreProduct(product, customer: CBCustomer('abc_flutter_test', 'flutter', 'test', 'abc@gmail.com'));
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseProduct,
          arguments: {
            Constants.product: product.id,
            Constants.customerId: 'abc_flutter_test',
            Constants.firstName: 'flutter',
            Constants.lastName: 'test',
            Constants.email: 'abc@gmail.com',
          },
        )
      ]);
      expect(result.status, 'active');
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: 'PlatformError', message: 'An error occured',);
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(() => Chargebee.purchaseProduct(product),
          throwsA(isA<PlatformException>()),);
      channel.setMockMethodCallHandler(null);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: 'PlatformError', message: 'An error occured',);
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(() => Chargebee.purchaseProduct(product),
          throwsA(isA<PlatformException>()),);
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveAllItems', () {
    const itemsString = '''[
      {
        "item": {
          "channel": "app_store",
          "enabled_for_checkouts": false,
          "enabled_in_portal": false,
          "external_name": "monthly.120",
          "id": "monthly.120",
          "is_giftable": false,
          "is_shippable": false,
          "itemApplicability": "restricted",
          "item_family_id": "apple-app-store",
          "metered": false,
          "name": "monthly.120",
          "object": "item",
          "resource_version": 1668687472606,
          "status": "active",
          "type": "plan",
          "updated_at": 1668687472,
          "description": "test_description"
        }
      }
    ]''';
    test('returns the list of items on iOS', () async {
      channelResponse = itemsString;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final itemsQueryParams = <String, String>{
        'limit': '10',
        'sort_by[desc]': 'Standard',
        'channel[is]': 'app_store'
      };
      final result = await Chargebee.retrieveAllItems(itemsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllItems, arguments: itemsQueryParams)
      ]);

      /// we have 1 item in itemsString above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final itemsQueryParams = <String, String>{
        'limit': '10',
        'sort_by[desc]': 'Standard',
        'channel[is]': 'app_store'
      };
      await expectLater(
        () => Chargebee.retrieveAllItems(itemsQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('returns the list of items on Android', () async {
      channelResponse = itemsString;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final itemsQueryParams = <String, String>{
        'limit': '10',
        'sort_by[desc]': 'Standard',
        'channel[is]': 'play_store'
      };
      final result = await Chargebee.retrieveAllItems(itemsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllItems, arguments: itemsQueryParams)
      ]);

      /// we have 1 item in itemsString above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final itemsQueryParams = <String, String>{
        'limit': '10',
        'sort_by[desc]': 'Standard',
        'channel[is]': 'app_store'
      };
      await expectLater(
        () => Chargebee.retrieveAllItems(itemsQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveSubscriptions', () {
    final getSubsQueryParams = <String, String>{
      'channel': 'app_store',
      'customer_id': 'imay-flutter'
    };
    const subscriptionsListAndroidString = '''
        [
          {
            "cb_subscription": {
              "activated_at": "1657543430",
              "current_term_end": "1670946599",
              "current_term_start": "1670860199",
              "customer_id": "imay-flutter",
              "plan_amount": "399.0",
              "status": "ACTIVE",
              "subscription_id": "2000000102582433"
            }
          }
        ]
    ''';
    const subscriptionsListiOSString = '''
        [
          {
            "cb_subscription": {
              "activated_at": 1657543430,
              "current_term_end": 1670946599,
              "current_term_start": 1670860199,
              "customer_id": "imay-flutter",
              "plan_amount": "399.0",
              "status": "ACTIVE",
              "subscription_id": "2000000102582433"
            }
          }
        ]
    ''';
    test('retrieves subscriptions successfully on iOS', () async {
      channelResponse = subscriptionsListiOSString;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.retrieveSubscriptions(getSubsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mSubscriptionMethod,
          arguments: getSubsQueryParams,
        )
      ]);

      /// we have 1 item in subscriptionsListString above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
        () => Chargebee.retrieveSubscriptions(getSubsQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('retrieves subscriptions successfully on Android', () async {
      channelResponse = subscriptionsListAndroidString;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.retrieveSubscriptions(getSubsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mSubscriptionMethod,
          arguments: getSubsQueryParams,
        )
      ]);

      /// we have 1 item in subscriptionsListString above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
        () => Chargebee.retrieveSubscriptions(getSubsQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveEntitlements', () {
    final getEntitlementsParams = <String, String>{
      'subscriptionId': '2000000226631982'
    };
    const entitlementsListString = '''
        [
          {
            "subscription_entitlement": {
              "feature_description": "Test feature for SDK testing",
              "feature_id": "test-feature",
              "feature_name": "Test Feature",
              "feature_type": "SWITCH",
              "is_enabled": true,
              "is_overridden": true,
              "name": "Available",
              "subscription_id": "2000000226631982",
              "value": "true"
            }
          }
        ]
    ''';
    test('retrieves entitlements successfully', () async {
      channelResponse = entitlementsListString;
      final result =
          await Chargebee.retrieveEntitlements(getEntitlementsParams);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mGetEntitlements,
          arguments: getEntitlementsParams,
        )
      ]);

      /// we have 1 item in entitlementsListString above
      expect(result.length, 1);
    });

    test('handles exception', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      await expectLater(
        () => Chargebee.retrieveEntitlements(getEntitlementsParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveAllPlans', () {
    test('returns the list of plans on iOS', () async {
      const plansStringiOS = '''[
        {
          "plan": {
              "addon_applicability": "all",
              "channel": "app_store",
              "charge_model": "flat_fee",
              "currency_code": "USD",
              "enabled_in_hosted_pages": false,
              "enabled_in_portal": false,
              "free_quantity": 0,
              "giftable": false,
              "id": "test_3-USD",
              "is_shippable": false,
              "name": "test_3-USD",
              "object": "plan",
              "period": 1,
              "period_unit": "day",
              "price": 399,
              "pricing_model": "flat_fee",
              "resource_version": 1666989853313,
              "setup_cost": 0,
              "show_description_in_invoices": false,
              "show_description_in_quotes": false,
              "status": "active",
              "taxable": true,
              "updated_at": 1666989853
          }
        }
      ]''';
      channelResponse = plansStringiOS;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final plansQueryParams = <String, String>{
        'sort_by[desc]': 'Standard',
        'channel[is]': 'app_store'
      };
      final result = await Chargebee.retrieveAllPlans(plansQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllPlans, arguments: plansQueryParams)
      ]);

      /// we have 1 item in plansStringiOS above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final plansQueryParams = <String, String>{
        'sort_by[desc]': 'Standard',
        'channel[is]': 'app_store'
      };
      await expectLater(
        () => Chargebee.retrieveAllPlans(plansQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('returns the list of plans on Android', () async {
      const plansStringAndroid = '''[
        {
          "plan": {
              "addonApplicability": "all",
              "channel": "play_store",
              "chargeModel": "flat_fee",
              "currencyCode": "USD",
              "enabledInHostedPages": false,
              "enabledInPortal": false,
              "freeQuantity": 0,
              "giftable": false,
              "id": "test_3-USD",
              "invoiceName": "test_3-USD",
              "isShippable": false,
              "name": "test_3-USD",
              "object": "plan",
              "period": 1,
              "periodUnit": "day",
              "price": 399,
              "pricingModel": "flat_fee",
              "resourceVersion": 1666989853313,
              "setup_cost": 0,
              "showDescriptionInInvoices": false,
              "showDescriptionInQuotes": false,
              "status": "active",
              "taxable": true,
              "updatedAt": 1666989853
          }
        }
      ]''';
      channelResponse = plansStringAndroid;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final plansQueryParams = <String, String>{
        'sort_by[desc]': 'Standard',
        'channel[is]': 'play_store'
      };
      final result = await Chargebee.retrieveAllPlans(plansQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllPlans, arguments: plansQueryParams)
      ]);

      /// we have 1 item in plansStringAndroid above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final plansQueryParams = <String, String>{
        'sort_by[desc]': 'Standard',
        'channel[is]': 'play_store'
      };
      await expectLater(
        () => Chargebee.retrieveAllPlans(plansQueryParams),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('restorePurchases', () {
    const map = '''{
      "subscriptionId": "2000000291590740",
      "planId": "New007",
      "storeStatus": "cancelled"
    }''';
    final restorePurchaseResult = [map];

    test('returns the list of Restored Subscription for Android', () async {
      channelResponse = restorePurchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final customer = CBCustomer(
          'test-user',
          'test',
          'user',
          'test-user@email.com',
        );
        final result = await Chargebee.restorePurchases(true, customer);
        final expectedArguments = {
          Constants.customerId: 'test-user',
          Constants.firstName: 'test',
          Constants.lastName: 'user',
          Constants.email: 'test-user@email.com',
          Constants.includeInactivePurchases: true,
        };
        expect(callStack, <Matcher>[
          isMethodCall(
            Constants.mRestorePurchase,
            arguments: expectedArguments,
          )
        ]);
        expect(result.isNotEmpty, true);
      } on PlatformException catch (e) {
        debugPrint('exception: ${e.message}');
      }
    });

    test('returns the list of Restored Subscription for iOS', () async {
      channelResponse = restorePurchaseResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final customer = CBCustomer(
        'test-user',
        'test',
        'user',
        'test-user@email.com',
      );
      final expectedArguments = {
        Constants.customerId: 'test-user',
        Constants.firstName: 'test',
        Constants.lastName: 'user',
        Constants.email: 'test-user@email.com',
        Constants.includeInactivePurchases: true,
      };
      final result = await Chargebee.restorePurchases(true, customer);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mRestorePurchase,
          arguments: expectedArguments,
        )
      ]);
      expect(result.isNotEmpty, true);
    });

    test('handles exception for iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
        () => Chargebee.restorePurchases(true),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('handles exception for Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
        () => Chargebee.restorePurchases(true),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('validateReceipt', () {
    const subscriptionResult = '''{
      "subscriptionId": "2000000291590740",
      "planId": "New007",
      "status": "active"
    }''';

    test('returns the subscription result for Android', () async {
      channelResponse = subscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final params = {
          Constants.product: 'chargebee.pro.android',
          Constants.customerId: '',
          Constants.firstName: '',
          Constants.lastName: '',
          Constants.email: '',
        };
        final result = await Chargebee.validateReceipt('chargebee.pro.android');
        expect(callStack, <Matcher>[
          isMethodCall(
            Constants.mValidateReceipt,
            arguments: params,
          )
        ]);
        expect(result.status, 'active');
      } on PlatformException catch (e) {
        debugPrint('exception: ${e.message}');
      }
    });

    test('returns the subscription result for iOS', () async {
      channelResponse = subscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final params = {
        Constants.product: 'test',
        Constants.customerId: '',
        Constants.firstName: '',
        Constants.lastName: '',
        Constants.email: '',
      };
      final result = await Chargebee.validateReceipt('test');
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mValidateReceipt,
          arguments: params,
        )
      ]);
      expect(result.status, 'active');
    });

    test('handles exception for iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
            () => Chargebee.validateReceipt('test'),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('handles exception for Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
            () => Chargebee.validateReceipt('chargebee.pro.android'),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });

  group('purchaseNonSubscriptionProduct', () {
    final map = <String, dynamic>{'unit': 'year', 'numberOfUnits': 1};
    final product = Product(
      'merchant.pro.android',
      1500.00,
      '1500.00',
      'title',
      'INR',
      SubscriptionPeriod.fromMap(map),
    );
    final customer = CBCustomer('', '', '', '',);
    const consumableProductType = ProductType.consumable;
    const nonConsumableProductType = ProductType.non_consumable;
    const nonSubscriptionResult =
    '''{"invoiceId":"cb-dsd", "chargeId":"test-plan", "customerId":"abc"}''';
    final params = {
      Constants.product: product.id,
      Constants.customerId: customer.id ?? '',
      Constants.firstName: customer.firstName ?? '',
      Constants.lastName: customer.lastName ?? '',
      Constants.email: customer.email ?? '',
      Constants.productType: nonConsumableProductType.name,
    };

    test('returns one time purchase(non_consumable) result for Android', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product,nonConsumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: params,
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('returns one time purchase(consumable) result for Android', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product,consumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: {
            Constants.product: product.id,
            Constants.customerId: customer.id ?? '',
            Constants.firstName: customer.firstName ?? '',
            Constants.lastName: customer.lastName ?? '',
            Constants.email: customer.email ?? '',
            Constants.productType: consumableProductType.name,
          },
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('returns one time purchase(non_consumable) result for iOS', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: params,
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('returns one time purchase(consumable) result for iOS', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product, consumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: {
            Constants.product: product.id,
            Constants.customerId: customer.id ?? '',
            Constants.firstName: customer.firstName ?? '',
            Constants.lastName: customer.lastName ?? '',
            Constants.email: customer.email ?? '',
            Constants.productType: consumableProductType.name,
          },
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('returns one time purchase(non_renewing_subscription) result for iOS', () async {
      const nonConsumableProductType = ProductType.non_renewing_subscription;
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: {
            Constants.product: product.id,
            Constants.customerId: customer.id ?? '',
            Constants.firstName: customer.firstName ?? '',
            Constants.lastName: customer.lastName ?? '',
            Constants.email: customer.email ?? '',
            Constants.productType: ProductType.non_renewing_subscription.name,
          },
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });


    test('one time purchase with customer info for Android', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType, customer);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: params,
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('one time purchase with customer info for iOS', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType, customer);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mPurchaseNonSubscriptionProduct,
          arguments: params,
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError', message: 'An error occured',);
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(() => Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType, customer),
        throwsA(isA<PlatformException>()),);
      channel.setMockMethodCallHandler(null);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError', message: 'An error occured',);
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(() => Chargebee.purchaseNonSubscriptionProduct(product, nonConsumableProductType, customer),
        throwsA(isA<PlatformException>()),);
      channel.setMockMethodCallHandler(null);
    });
  });

  group('validateReceiptForNonSubscriptions', () {
    final product = Product(
      'merchant.pro.android',
      1500.00,
      '1500.00',
      'title',
      'INR',
       SubscriptionPeriod.fromMap({'periodUnit': 'month', 'numberOfUnits': 1}),
    );
    const consumableProductType = ProductType.consumable;
    const nonConsumableProductType = ProductType.non_consumable;
    const nonSubscriptionResult =
    '''{"invoiceId":"cb-dsd", "chargeId":"test-plan", "customerId":"abc"}''';
    final params = {
      Constants.product: product.id,
      Constants.customerId: '',
      Constants.firstName: '',
      Constants.lastName: '',
      Constants.email: '',
      Constants.productType: nonConsumableProductType.name,
    };

    test('returns the one time purchase result for Android', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final result = await Chargebee.validateReceiptForNonSubscriptions(product.id, nonConsumableProductType);
        expect(callStack, <Matcher>[
          isMethodCall(
            Constants.mValidateReceiptForNonSubscriptions,
            arguments: params,
          )
        ]);
        expect(result.invoiceId.isNotEmpty, true);
        expect(result.chargeId.isNotEmpty, true);
        expect(result.customerId.isNotEmpty, true);
      } on PlatformException catch (e) {
        debugPrint('exception: ${e.message}');
      }
    });

    test('returns the one time purchase result for iOS', () async {
      channelResponse = nonSubscriptionResult;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.validateReceiptForNonSubscriptions(product.id, nonConsumableProductType);
      expect(callStack, <Matcher>[
        isMethodCall(
          Constants.mValidateReceiptForNonSubscriptions,
          arguments: params,
        )
      ]);
      expect(result.invoiceId.isNotEmpty, true);
      expect(result.chargeId.isNotEmpty, true);
      expect(result.customerId.isNotEmpty, true);
    });

    test('handles exception for iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
            () => Chargebee.validateReceiptForNonSubscriptions(product.id, nonConsumableProductType),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });

    test('handles exception for Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
          code: 'PlatformError',
          message: 'An error occured',
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
            () => Chargebee.validateReceiptForNonSubscriptions(product.id, nonConsumableProductType),
        throwsA(isA<PlatformException>()),
      );
      channel.setMockMethodCallHandler(null);
    });
  });
}
