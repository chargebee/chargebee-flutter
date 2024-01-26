import 'dart:async';
import 'dart:developer';

import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/Constants.dart';
import 'package:chargebee_flutter_sdk_example/alertDialog.dart';
import 'package:chargebee_flutter_sdk_example/items_listview.dart';
import 'package:chargebee_flutter_sdk_example/network_connectivity.dart';
import 'package:chargebee_flutter_sdk_example/product_ids_listview.dart';
import 'package:chargebee_flutter_sdk_example/product_listview.dart';
import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Chargebee-Flutter SDK'),
      );
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController siteNameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController sdkKeyController = TextEditingController();
  final TextEditingController iosDdkKeyController = TextEditingController();
  final TextEditingController productIdTextFieldController =
      TextEditingController();

  List<Product> products = [];
  late List<String> cbMenu = Constants.menu;
  late String siteName = '', apiKey = '', androidSdkKey = '', iosSdkKey = '';
  late String productIDs;
  late String userInput;
  late ProgressBarUtil mProgressBarUtil;

  final Map<String, String> queryParams = {
    'channel': 'play_store',
    'customer_id': 'abc'
  }; // sample query params for retrieveSubscriptions
  final Map<String, String> params = {
    'subscriptionId': 'AzZlGJTC9U3tw4nF'
  }; // eg. query params for entitlements
  final Map<String, String> itemsQueryParams = {
    'limit': '10',
    'channel[is]': 'play_store'
  }; // eg. query params for getAllItems, limit- default=100, min=1, max=100
  final Map<String, String> plansQueryParams = {
    'limit': '5',
    'channel[is]': 'play_store'
  }; // eg. query params for getAllPlans
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';

  _MyHomePageState();

  @override
  void initState() {
    super.initState();
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string =
              _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          debugPrint(string);
          _verifyLocalCache();
          _configure();
          break;
        case ConnectivityResult.wifi:
          string =
              _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          debugPrint(string);
          _verifyLocalCache();
          _configure();
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
          debugPrint(string);
      }
    });
  }

  _verifyLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final productId = prefs.getString('productId');
    final products = <String>['$productId'];
    if (productId != null) {
      retrieveProducts(products);
    } else {
      debugPrint('Local cache empty!');
    }
  }

  _configure() async {
    /// For both iOS and Android
    authentication('your-site', 'publishable_api_key', 'iOS ResourceID/SDK Key',
         'Android ResourceID/SDK Key',);
  }

  Future<void> retrieveProducts(List<String> productIDsList) async {
    try {
      final products = await Chargebee.retrieveProducts(productIDsList);
      debugPrint('result : $products');
      if (products.isNotEmpty &&
          products.first.subscriptionPeriod.unit.isNotEmpty &&
          products.first.subscriptionPeriod.numberOfUnits != 0) {
        validateReceipt(products.first.id);
      } else {
        validateNonSubscriptionReceipt(products.first.id);
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mProgressBarUtil = ProgressBarUtil(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargebee- Flutter SDK Example'),
      ),
      body: ListView.builder(
        itemCount: cbMenu.length,
        itemBuilder: (context, pos) => Card(
          child: ListTile(
            title: Text(cbMenu[pos]),
            onTap: () {
              onItemClick(cbMenu[pos]);
            },
          ),
        ),
      ),
    );
  }

  onItemClick(String menuItem) {
    switch (menuItem) {
      case Constants.config:
        showAuthenticationDialog(context);
        break;

      case Constants.getProducts:
        showSkProductDialog(context);
        break;

      case Constants.getSubscriptionStatus:
        mProgressBarUtil.showProgressDialog();
        retrieveSubscriptions(queryParams);
        break;
      case Constants.getProductIdentifiers:
        mProgressBarUtil.showProgressDialog();
        retrieveProductIdentifers();
        break;
      case Constants.getEntitlements:
        mProgressBarUtil.showProgressDialog();
        retrieveEntitlements(params);
        break;
      case Constants.getAllPlans:
        mProgressBarUtil.showProgressDialog();
        retrieveAllPlans(plansQueryParams);
        break;
      case Constants.getAllItems:
        mProgressBarUtil.showProgressDialog();
        retrieveAllItems(itemsQueryParams);
        break;
      case Constants.restorePurchase:
        mProgressBarUtil.showProgressDialog();
        restorePurchases();
        break;
      case Constants.showManageSubscriptions:
        Chargebee.showManageSubscriptionsSettings();
        break;
      default:
        break;
    }
  }

  Future<void> authentication(
    String siteName,
    String apiKey, [
    String? iosSdkKey = '',
    String? androidSdkKey = '',
  ]) async {
    try {
      await Chargebee.configure(siteName, apiKey, iosSdkKey, androidSdkKey);
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
    }
  }

  Future<void> getProducts(List<String> productIDsList) async {
    try {
      products = await Chargebee.retrieveProducts(productIDsList);
      debugPrint('result : $products');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      if (products.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ProductListView(products, title: 'Google Play-Product List'),
          ),
        );
      } else {
        _showDialog(context, 'Items not available to buy');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  Future<void> retrieveProductIdentifers() async {
    try {
      final queryparam = <String, String>{'limit': '10'};
      final result = await Chargebee.retrieveProductIdentifiers(queryparam);
      log('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }

      if (result.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ProductIdentifiersView(
              result,
              title: 'Product Identifiers List',
            ),
          ),
        );
      } else {
        _showDialog(context, 'Product Ids not avilable in chargebee');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  Future<void> retrieveSubscriptions(Map<String, String> queryparam) async {
    try {
      final result = await Chargebee.retrieveSubscriptions(queryparam);
      debugPrint('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      if (result.isNotEmpty) {
        _showDialog(context, 'Subscriptions retrieved successfully!');
      } else {
        _showDialog(context, 'Subscription not found in Chargebee System');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      _showDialog(context, '${e.message}');
    }
  }

  Future<void> retrieveEntitlements(Map<String, String> queryparam) async {
    try {
      final result = await Chargebee.retrieveEntitlements(queryparam);
      debugPrint('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }

      if (result.isNotEmpty) {
        final entitlement = result.first.cbEntitlement;
        debugPrint('${entitlement?.subscriptionId}');
        debugPrint('${entitlement?.featureId}');
        debugPrint('${entitlement?.featureName}');
        debugPrint('${entitlement?.featureType}');
        debugPrint('${entitlement?.name}');
        debugPrint('${entitlement?.value}');
        debugPrint('${entitlement?.isOverridden}');
        debugPrint('${entitlement?.isEnabled}');
        _showDialog(context, 'entitlements retrieved successfully!');
      } else {
        _showDialog(context, 'Entitlements not found in system');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      _showDialog(context, '${e.message}');
    }
  }

  Future<void> retrieveAllPlans(Map<String, String> queryparam) async {
    try {
      final result = await Chargebee.retrieveAllPlans(queryparam);
      debugPrint('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      final name = <String>[];
      if (result.isNotEmpty) {
        for (final cbPlan in result) {
          name.add(cbPlan != null ? cbPlan.name! : 'null');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ItemsView(name, title: 'List Plans'),
          ),
        );
      } else {
        _showDialog(context, 'Plans not available in chargebee');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      _showDialog(context, '${e.message}');
    }
  }

  Future<void> retrieveAllItems(Map<String, String> queryparam) async {
    try {
      final result = await Chargebee.retrieveAllItems(queryparam);
      debugPrint('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }

      final name = <String>[];
      if (result.isNotEmpty) {
        for (final cbItem in result) {
          name.add(cbItem != null ? cbItem.name! : 'null');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ItemsView(name, title: 'List Items'),
          ),
        );
      } else {
        _showDialog(context, 'Items not available in chargebee');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      _showDialog(context, '${e.message}');
    }
  }

  Future<void> restorePurchases() async {
    try {
      final customer = CBCustomer(
        'Test123',
        'CB',
        'Test',
        'cbTest@chargebee.com',
      );
      final result = await Chargebee.restorePurchases(true, customer);
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      if (result.isNotEmpty) {
        for (final subscription in result) {
          if (subscription.storeStatus == StoreStatus.active) {
            debugPrint('Active Subscriptions : $subscription');
          } else {
            debugPrint('All Subscriptions : $subscription');
          }
        }
        _showDialog(
            context, '${result.length} Purchases Restored Successfully');
      } else {
        _showDialog(context, 'Purchase not found to restore');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  Future<void> validateReceipt(String productId) async {
    try {
      final customer = CBCustomer(
        '',
        '',
        '',
        '',
      );
      final result = await Chargebee.validateReceipt(productId, customer);
      debugPrint('subscription result : $result');
      debugPrint('subscription id : ${result.subscriptionId}');
      debugPrint('plan id : ${result.planId}');
      debugPrint('subscription status : ${result.status}');
      mProgressBarUtil.hideProgressDialog();

      /// if validateReceipt success, clear the cache
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('productId');
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  Future<void> validateNonSubscriptionReceipt(String productId) async {
    try {
      const productType = ProductType.non_consumable;
      final customer = CBCustomer(
        '',
        '',
        '',
        '',
      );
      final result = await Chargebee.validateReceiptForNonSubscriptions(
          productId, productType, customer);
      debugPrint('subscription result : $result');
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  _showDialog(BuildContext context, String message) {
    final alert = BaseAlertDialog('Chargebee', message);
    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  showSkProductDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please enter Product Ids(Comma separated)'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                productIDs = value.trim();
              });
            },
            controller: productIdTextFieldController,
            decoration: const InputDecoration(hintText: "Product ID's"),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                textStyle: const TextStyle(fontStyle: FontStyle.normal),
              ),
              child: const Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontStyle: FontStyle.normal),
              ),
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  try {
                    Navigator.pop(context);
                    debugPrint('productIds from user : $productIDs');
                    mProgressBarUtil.showProgressDialog();

                    final listItems = productIDs.split(',');
                    getProducts(listItems);
                    productIdTextFieldController.clear();
                  } catch (e) {
                    log('error : ${e.toString()}');
                  }
                });
              },
            ),
          ],
        ),
      );

  Future<void> showAuthenticationDialog(BuildContext context) async =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chargebee'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    siteName = value;
                  });
                },
                controller: siteNameController,
                decoration: const InputDecoration(hintText: 'Site Name'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    apiKey = value;
                  });
                },
                controller: apiKeyController,
                decoration: const InputDecoration(hintText: 'API Key'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    iosSdkKey = value;
                  });
                },
                controller: iosDdkKeyController,
                decoration: const InputDecoration(
                  hintText: 'iOS SDK Key',
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    androidSdkKey = value;
                  });
                },
                controller: sdkKeyController,
                decoration: const InputDecoration(
                  hintText: 'Android SDK Key',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                textStyle: const TextStyle(fontStyle: FontStyle.normal),
              ),
              child: const Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontStyle: FontStyle.normal),
              ),
              child: const Text('Initialize'),
              onPressed: () {
                Navigator.pop(context);
                debugPrint(
                  'app details : $siteName, $apiKey, $androidSdkKey, $iosSdkKey',
                );
                authentication(
                  siteName,
                  apiKey,
                  iosSdkKey,
                  androidSdkKey,
                );
              },
            )
          ],
        ),
      );
}
