import 'dart:convert';
import 'package:chargebee_flutter/src/utils/cb_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chargebee_flutter/src/chargebee.dart';
import 'package:chargebee_flutter/src/constants.dart';

void main() {
  const MethodChannel channel = MethodChannel('chargebee_flutter');
  TestWidgetsFlutterBinding.ensureInitialized();
  final String siteName = "SITE_NAME";
  final String apiKey = "API_KEY";
  final String iosSDKKey = "iOS SDK Key";
  final String androidSDKKey = "Android SDK Key";

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
      await Chargebee.configure(
        site: siteName,
        publishableApiKey: apiKey,
        iosSdkKey: iosSDKKey,
      );
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
      await Chargebee.configure(
        site: siteName,
        publishableApiKey: apiKey,
        androidSdkKey: androidSDKKey,
      );
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
        throw PlatformException(code: "Dummy");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
          () => Chargebee.configure(
                site: siteName,
                publishableApiKey: apiKey,
                iosSdkKey: iosSDKKey,
              ),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveProductIdentifers', () {
    test('returns the list of Product Identifiers', () async {
      final productIdentifiersString =
          """["chargebee.price.change","chargebee.premium.android","merchant.start.android"]""";
      channelResponse = productIdentifiersString;
      // debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      Map<String, String> queryparam = {"limit": "100"};
      final productIdentifiers =
          await Chargebee.retrieveProductIdentifers(queryparam);
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
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      Map<String, String> queryparam = {"limit": "100"};
      await expectLater(() => Chargebee.retrieveProductIdentifers(queryparam),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveAllItems', () {
    final itemsString = """[
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
    ]""";
    test('returns the list of items on iOS', () async {
      channelResponse = itemsString;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final Map<String, String> itemsQueryParams = {
        "limit": "10",
        "sort_by[desc]": "Standard",
        "channel[is]": "app_store"
      };
      final result = await Chargebee.retrieveAllItems(itemsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllItems, arguments: itemsQueryParams)
      ]);
      // we have 1 item in itemsString above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final Map<String, String> itemsQueryParams = {
        "limit": "10",
        "sort_by[desc]": "Standard",
        "channel[is]": "app_store"
      };
      await expectLater(() => Chargebee.retrieveAllItems(itemsQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('returns the list of items on Android', () async {
      channelResponse = itemsString;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final Map<String, String> itemsQueryParams = {
        "limit": "10",
        "sort_by[desc]": "Standard",
        "channel[is]": "play_store"
      };
      final result = await Chargebee.retrieveAllItems(itemsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllItems, arguments: itemsQueryParams)
      ]);
      // we have 1 item in itemsString above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final Map<String, String> itemsQueryParams = {
        "limit": "10",
        "sort_by[desc]": "Standard",
        "channel[is]": "app_store"
      };
      await expectLater(() => Chargebee.retrieveAllItems(itemsQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveSubscriptions', () {
    final Map<String, String> getSubsQueryParams = {
      "channel": "app_store",
      "customer_id": "imay-flutter"
    };
    final subscriptionsListAndroidString = """
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
    """;
    final subscriptionsListiOSString = """
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
    """;
    test('retrieves subscriptions successfully on iOS', () async {
      channelResponse = subscriptionsListiOSString;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final result = await Chargebee.retrieveSubscriptions(getSubsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mSubscriptionMethod,
            arguments: getSubsQueryParams)
      ]);
      // we have 1 item in subscriptionsListString above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await expectLater(
          () => Chargebee.retrieveSubscriptions(getSubsQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('retrieves subscriptions successfully on Android', () async {
      channelResponse = subscriptionsListAndroidString;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = await Chargebee.retrieveSubscriptions(getSubsQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mSubscriptionMethod,
            arguments: getSubsQueryParams)
      ]);
      // we have 1 item in subscriptionsListString above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
          () => Chargebee.retrieveSubscriptions(getSubsQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveEntitlements', () {
    final Map<String, String> getEntitlementsParams = {
      "subscriptionId": "2000000226631982"
    };
    final entitlementsListString = """
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
    """;
    test('retrieves entitlements successfully', () async {
      channelResponse = entitlementsListString;
      final result =
          await Chargebee.retrieveEntitlements(getEntitlementsParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mGetEntitlements,
            arguments: getEntitlementsParams)
      ]);
      // we have 1 item in entitlementsListString above
      expect(result.length, 1);
    });

    test('handles exception', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      await expectLater(
          () => Chargebee.retrieveEntitlements(getEntitlementsParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveAllPlans', () {
    test('returns the list of plans on iOS', () async {
      final plansStringiOS = """[
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
      ]""";
      channelResponse = plansStringiOS;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final Map<String, String> plansQueryParams = {
        "sort_by[desc]": "Standard",
        "channel[is]": "app_store"
      };
      final result = await Chargebee.retrieveAllPlans(plansQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllPlans, arguments: plansQueryParams)
      ]);
      // we have 1 item in plansStringiOS above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final Map<String, String> plansQueryParams = {
        "sort_by[desc]": "Standard",
        "channel[is]": "app_store"
      };
      await expectLater(() => Chargebee.retrieveAllPlans(plansQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('returns the list of plans on Android', () async {
      final plansStringAndroid = """[
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
      ]""";
      channelResponse = plansStringAndroid;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final Map<String, String> plansQueryParams = {
        "sort_by[desc]": "Standard",
        "channel[is]": "play_store"
      };
      final result = await Chargebee.retrieveAllPlans(plansQueryParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mRetrieveAllPlans, arguments: plansQueryParams)
      ]);
      // we have 1 item in plansStringAndroid above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw PlatformException(
            code: "PlatformError", message: "An error occured");
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final Map<String, String> plansQueryParams = {
        "sort_by[desc]": "Standard",
        "channel[is]": "play_store"
      };
      await expectLater(() => Chargebee.retrieveAllPlans(plansQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });
}
