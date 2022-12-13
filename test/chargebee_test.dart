import 'dart:convert';
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
  });
}
