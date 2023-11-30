import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ChargebeeTest chargebeeTest;

  group('end-to-end-test', () {
    testWidgets('Chargebee sdk integration test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      chargebeeTest = ChargebeeTest(tester);
      await chargebeeTest.configureAndLaunchApp();
      await chargebeeTest.retrieveProductIdentifiersWithoutParam();
      await chargebeeTest.retrieveProductIdentifiersWithParam();
      await chargebeeTest.retrieveProducts();
      await chargebeeTest.purchaseProducts_withCustomerId();
      await chargebeeTest.purchaseProduct_withCustomerInfo();
      await chargebeeTest.purchaseProducts_withoutCustomerInfo();
      await chargebeeTest.retrieveSubscriptions();
      await chargebeeTest.retrieveEntitlements();
      await chargebeeTest.retrieveAllItems();
      await chargebeeTest.retrieveAllPlans();
      await chargebeeTest.restorePurchases(true);
    });
  });
}

class ChargebeeTest {
  final WidgetTester tester;
  final platformName = Chargebee.platform.name;
  late Product product;
  final productIdForiOS = 'chargebee.pro.ios';
  final productIdForAndroid = 'merchant.premium.android';
  late List<String> productList;

  ChargebeeTest(this.tester);

  Future<void> configureAndLaunchApp() async {
    const siteName = 'cb-test';
    const apiKey = 'test_****';
    const iosSDKKey = 'cb-****';
    const androidSDKKey = 'cb-****';
    await tester.pumpAndSettle();
    try {
      tester.printToConsole('Start configuring app with chargebee');
      await Chargebee.configure(siteName, apiKey, iosSDKKey, androidSDKKey);
      tester.printToConsole('Configuration done successfully!');
    } on PlatformException catch (e) {
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
    tester.printToConsole('Fetch store specific product Ids from chargebee');
    try {
      final list = await Chargebee.retrieveProductIdentifiers();
      expect(list.isNotEmpty, true);
      tester.printToConsole('Product Ids retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveProductIdentifiersWithParam() async {
    tester.printToConsole(
        'Fetch store specific product Ids from chargebee with params',);
    try {
      final list = await Chargebee.retrieveProductIdentifiers({'limit': '10'});
      debugPrint('list: $list');
      expect(list.isNotEmpty, true);
      tester.printToConsole('Product Ids retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveProducts() async {
    tester.printToConsole('Fetch product details from store(apple or google)');
    if (platformName == 'ios') {
      productList = [productIdForiOS];
    } else {
      productList = [productIdForAndroid];
    }
    try {
      final product = await Chargebee.retrieveProducts(productList);
      debugPrint('Product : $product');
      expect(product.isNotEmpty, true);
      tester.printToConsole('Products retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Product _getProduct(String productId) => product = Product(
        productId,
        0.0,
        'priceString',
        'title',
        'currencyCode',
        SubscriptionPeriod.fromMap(
            {'periodUnit': 'month', 'numberOfUnits': 3},),);
  final customer = CBCustomer(
    'abc_flutter_test',
    'fn',
    'ln',
    'abc@gmail.com',
  );

  Future<void> purchaseProducts_withCustomerId() async {
    tester.printToConsole('Starting to subscribe the product');

    if (platformName == 'ios') {
      _getProduct(productIdForiOS);
    } else {
      _getProduct(productIdForAndroid);
    }

    try {
      final result = await Chargebee.purchaseProduct(product, customer: customer);
      debugPrint('purchase result: $result');
      expect(result.status, 'true');
      tester.printToConsole('Product subscribed successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> purchaseProducts_withoutCustomerInfo() async {
    tester.printToConsole('Starting to subscribe the product');

    if (platformName == 'ios') {
      _getProduct(productIdForiOS);
    } else {
      _getProduct(productIdForAndroid);
    }

    try {
      final result = await Chargebee.purchaseProduct(product);
      debugPrint('purchase result: $result');
      expect(result.status, 'true');
      tester.printToConsole('Product subscribed successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> purchaseProduct_withCustomerInfo() async {
    tester.printToConsole('Starting to subscribe the product');
    if (platformName == 'ios') {
      _getProduct(productIdForiOS);
    } else {
      _getProduct(productIdForAndroid);
    }
    try {
      final result = await Chargebee.purchaseProduct(product, customer: customer);
      debugPrint('purchase result: $result');
      expect(result.status, 'true');
      tester.printToConsole('Product subscribed successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveSubscriptions() async {
    tester.printToConsole('Start retrieving subscriptions');
    try {
      final subscriptions = await Chargebee.retrieveSubscriptions(
          {'channel': 'play_store', 'customer_id': 'abc'},);
      debugPrint('Subscriptions: $subscriptions');
      expect(subscriptions.isNotEmpty, true);
      tester.printToConsole('Subscription retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveEntitlements() async {
    tester.printToConsole('Start retrieving entitlements');
    try {
      final entitlements = await Chargebee.retrieveEntitlements(
          {'subscriptionId': 'AzZlGJTC9U3tw4nF'},);
      debugPrint('Entitlements : $entitlements');
      expect(entitlements.isNotEmpty, true);
      tester.printToConsole('Entitlements retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveAllItems() async {
    tester.printToConsole('Start retrieving all items');
    try {
      final subscriptions = await Chargebee.retrieveAllItems(
          {'limit': '5', 'channel[is]': 'play_store'},);
      debugPrint('Items : $subscriptions');
      expect(subscriptions.isNotEmpty, true);
      tester.printToConsole('Items retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> retrieveAllPlans() async {
    tester.printToConsole('Start retrieving all plans');
    try {
      final subscriptions = await Chargebee.retrieveAllPlans(
          {'limit': '5', 'channel[is]': 'app_store'},);
      debugPrint('Plans : $subscriptions');
      expect(subscriptions.isNotEmpty, true);
      tester.printToConsole('Plans retrieved successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

  Future<void> restorePurchases(bool includeInActivePurchase) async {
    tester.printToConsole('Start restore purchases and sync with Chargebee');
    try {
      final subscriptions = await Chargebee.restorePurchases(includeInActivePurchase);
      debugPrint('Purchases : $subscriptions');
      expect(subscriptions.isNotEmpty, true);
      tester.printToConsole('Purchases restored successfully!');
    } on PlatformException catch (e) {
      fail('Error: ${e.message}');
    }
  }

}
