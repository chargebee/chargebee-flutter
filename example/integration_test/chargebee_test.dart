import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final String siteName = "cb-test";
  final String apiKey = "test_****";
  final String iosSDKKey = "cb-*****";
  final String androidSDKKey = "cb-*****";

  ChargebeeTest chargebeeTest;
  group('end-to-end-test', () {
    testWidgets('Chargebee sdk test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      chargebeeTest = new ChargebeeTest(tester);
      await chargebeeTest.configureAndLaunchApp();
      await chargebeeTest.retrieveProductIdentifiersWithoutParam();
      await chargebeeTest.retrieveProductIdentifiersWithParam();
      await chargebeeTest.retrieveProducts();
    });
  });
}

class ChargebeeTest {
  final WidgetTester tester;
  ChargebeeTest(this.tester);

  Future<void> configureAndLaunchApp() async {
    final String siteName = "cb-imay-test";
    final String apiKey = "test_EojsGoGFeHoc3VpGPQDOZGAxYy3d0FF3";
    final String iosSDKKey = "cb-njjoibyzbrhyjg7yz4hkwg2ywq";
    final String androidSDKKey = "cb-wpkheixkuzgxbnt23rzslg724y";
    await tester.pumpAndSettle();
    try {
      tester.printToConsole('Start configuring app with chargebee');
      await Chargebee.configure(siteName, apiKey, iosSDKKey, androidSDKKey);
      tester.printToConsole('Configuration done successfully!');
    } on PlatformException catch(e){
      fail('Error message: ${e.message}');
    }
    expect(find.text('Configure'), findsOneWidget);
    expect(find.text('Get Products'), findsOneWidget);
    expect(find.text('Get Subscription Status'), findsOneWidget);
    expect(find.text('Get Product Identifiers'), findsOneWidget);
    expect(find.text('Get Entitlements'), findsOneWidget);
    expect(find.text('Get Plans'), findsOneWidget);
    expect(find.text('Get Items'), findsOneWidget);
  }

  Future<void> retrieveProductIdentifiersWithoutParam() async {
    tester.printToConsole('Fetch store specific products from chargebee');
    try {
      final list = await Chargebee.retrieveProductIdentifers();
      expect(list.isNotEmpty, true);
      await tester.pumpAndSettle(Duration(seconds: 10));
    } on PlatformException catch(e){
      fail('Error: ${e.message}');
    }
    tester.printToConsole('Store specific products retrieved successfully!');
  }

  Future<void> retrieveProductIdentifiersWithParam() async {
    tester.printToConsole('Fetch store specific products from chargebee with params');
    try {
      final list = await Chargebee.retrieveProductIdentifers({"limit":"10"});
      expect(list.isNotEmpty, true);
      await tester.pumpAndSettle(Duration(seconds: 10));
    } on PlatformException catch(e){
      fail('Error: ${e.message}');
    }

    tester.printToConsole('Store specific products retrieved successfully!');
  }

  Future<void> retrieveProducts() async {
    tester.printToConsole('Fetch product details from store(apple or google)');
      List<String> productList = ['merchant.pro.android'];
      try {
        final list = await Chargebee.retrieveProducts(productList);
        debugPrint('list: $list');
        expect(list.isNotEmpty, true);
      } on PlatformException catch(e){
        fail('Error: ${e.message}');
      }
    tester.printToConsole('Products retrieved from store successfully!');

  }
}