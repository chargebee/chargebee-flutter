import 'dart:convert';
import 'package:chargebee_flutter/src/utils/cb_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chargebee_flutter/src/chargebee.dart';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:platform/platform.dart';

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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
      await Chargebee.configure(siteName, apiKey, "", androidSDKKey);
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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      await expectLater(() => Chargebee.configure(siteName, apiKey, iosSDKKey),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });

  group('retrieveProductIdentifers', () {
    test('returns the list of Product Identifiers on iOS', () async {
      final productIdentifiersString =
          """["chargebee.price.change","chargebee.premium.android","merchant.start.android"]""";
      channelResponse = productIdentifiersString;
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
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

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      Map<String, String> queryparam = {"limit": "100"};
      await expectLater(() => Chargebee.retrieveProductIdentifers(queryparam),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('returns the list of Product Identifiers on Android', () async {
      final productIdentifiersString =
          """["chargebee.price.change","chargebee.premium.android","merchant.start.android"]""";
      channelResponse = productIdentifiersString;
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
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

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      final Map<String, dynamic> itemsQueryParams = {
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
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      final Map<String, dynamic> itemsQueryParams = {
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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
      final Map<String, dynamic> itemsQueryParams = {
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
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
      final Map<String, dynamic> itemsQueryParams = {
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
    final Map<String, dynamic> getSubsQueryParams = {
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
              "status": "ACTIVE"
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
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
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
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      await expectLater(
          () => Chargebee.retrieveSubscriptions(getSubsQueryParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('retrieves subscriptions successfully on Android', () async {
      channelResponse = subscriptionsListAndroidString;
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
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
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
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
    test('retrieves entitlements successfully on iOS', () async {
      channelResponse = entitlementsListString;
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      final result =
          await Chargebee.retrieveEntitlements(getEntitlementsParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mGetEntitlements,
            arguments: getEntitlementsParams)
      ]);
      // we have 1 item in entitlementsListString above
      expect(result.length, 1);
    });

    test('handles exception on iOS', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.iOS);
      await expectLater(
          () => Chargebee.retrieveEntitlements(getEntitlementsParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });

    test('retrieves entitlements successfully on Android', () async {
      channelResponse = entitlementsListString;
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
      final result =
          await Chargebee.retrieveEntitlements(getEntitlementsParams);
      expect(callStack, <Matcher>[
        isMethodCall(Constants.mGetEntitlements,
            arguments: getEntitlementsParams)
      ]);
      // we have 1 item in entitlementsListString above
      expect(result.length, 1);
    });

    test('handles exception on Android', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        throw CBException(code: "PlatformError", message: "An error occured");
      });
      Chargebee.localPlatform = FakePlatform(operatingSystem: Platform.android);
      await expectLater(
          () => Chargebee.retrieveEntitlements(getEntitlementsParams),
          throwsA(isA<PlatformException>()));
      channel.setMockMethodCallHandler(null);
    });
  });
}
