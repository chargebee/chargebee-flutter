import 'dart:async';
import 'dart:developer';
import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/product_ids_listview.dart';
import 'package:chargebee_flutter_sdk_example/product_listview.dart';
import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Constants.dart';
import 'alertDialog.dart';
import 'items_listview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(Constants.menu, title: 'Chargebee-Flutter SDK'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<String> cbMenu;
  final String title;

  const MyHomePage(this.cbMenu, {Key? key, required this.title})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(cbMenu);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.cbMenu);

  final TextEditingController siteNameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController sdkKeyController = TextEditingController();
  final TextEditingController iosDdkKeyController = TextEditingController();
  final TextEditingController productIdTextFieldController = TextEditingController();

  List<Product> products = [];
  late List<String> cbMenu;
  late String siteName="", apiKey="", androidSdkKey="", iosSdkKey = "";
  late String productIDs;
  late String userInput;
  late ProgressBarUtil mProgressBarUtil;

  final Map<String, String> queryParams = {"channel": "app_store", "customer_id":"abc"}; // sample query params for retrieveSubscriptions
  final Map<String, String> params = {"subscriptionId":"AzZlGJTC9U3tw4nF"}; // eg. query params for entitlements
  final Map<String, String> itemsQueryParams = {"limit": "10","channel[is]": "play_store"}; // eg. query params for getAllItems, limit- default=100, min=1, max=100
  final Map<String, String> plansQueryParams = {"limit": "5","channel[is]": "play_store"}; // eg. query params for getAllPlans

  @override
  void initState() {
    // For both iOS and Android
    authentication("your-site", "publishable_api_key", "iOS ResourceID/SDK Key", "Android ResourceID/SDK Key");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mProgressBarUtil = ProgressBarUtil(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chargebee- Flutter SDK Example"),
      ),
      body: ListView.builder(
        itemCount: cbMenu.length,
        itemBuilder: (context, pos) {
          return Card(
            child: ListTile(
              title: Text(cbMenu[pos]),
              onTap: () {
                onItemClick(cbMenu[pos]);
              },
            ),
          );
        },
      ),
    );
  }

  onItemClick(String menuItem) {
    switch (menuItem) {
      case Constants.CONFIG:
        showAuthenticationDialog(context);
        break;

      case Constants.GET_PRODUCTS:
        showSkProductDialog(context);
        break;

      case Constants.GET_SUBSCRIPTION_STATUS:
        mProgressBarUtil.showProgressDialog();
        retrieveSubscriptions(queryParams);
        break;
      case Constants.GET_PRODUCT_IDENTIFIERS:
        mProgressBarUtil.showProgressDialog();
        retrieveProductIdentifers();
        break;
      case Constants.GET_ENTITLEMENTS:
        mProgressBarUtil.showProgressDialog();
        retrieveEntitlements(params);
        break;
      case Constants.GET_PLANS:
        mProgressBarUtil.showProgressDialog();
        retrieveAllPlans(plansQueryParams);
        break;
      case Constants.GET_ITEMS:
        mProgressBarUtil.showProgressDialog();
        retrieveAllItems(itemsQueryParams);
        break;
      default:
        break;
    }
  }

  Future<void> authentication(String siteName, String apiKey, [String? iosSdkKey="",
      String? androidSdkKey = ""]) async {
    try {
      await Chargebee.configure(siteName, apiKey, iosSdkKey, androidSdkKey);
    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
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
              builder: (BuildContext context) => ProductListView(products,
                  title: 'Google Play-Product List'),
            ));
      } else {
        _showDialog(context, "Items not available to buy");
      }
    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  Future<void> retrieveProductIdentifers() async {
    try {
      Map<String, String> queryparam = {"limit":"10"};
      final result = await Chargebee.retrieveProductIdentifiers(queryparam);
      debugPrint('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }

      if (result.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ProductIdentifiersView(result,
                  title: 'Product Identifiers List'),
            ));
      } else {
        _showDialog(context, "Product Ids not avilable in chargebee");
      }

    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

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
      if (result.length > 0) {
        _showDialog(context, "Subscriptions retrieved successfully!");
      } else {
        _showDialog(context, "Subscription not found in Chargebee System");
      }
    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
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
        _showDialog(context, "entitlements retrieved successfully!");
      } else {
        _showDialog(context, "Entitlements not found in system");
      }

    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
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
      List<String> name = [];
      if (result.isNotEmpty) {
        for (var cbPlan in result) {
          name.add(cbPlan != null? cbPlan.name!: "null");
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ItemsView(name,
                  title: 'List Plans'),
            ));
      } else {
        _showDialog(context, "Plans not available in chargebee");
      }

    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
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

      List<String> name = [];
      if (result.isNotEmpty) {
        for (var cbItem in result) {
          name.add(cbItem != null? cbItem.name!: "null");
        }

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ItemsView(name,
                  title: 'List Items'),
            ));
      } else {
        _showDialog(context, "Items not available in chargebee");
      }

    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      _showDialog(context, '${e.message}');
    }
  }

  _showDialog(BuildContext context, String message) {
    BaseAlertDialog alert = BaseAlertDialog("Chargebee", message);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSkProductDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                    primary: Colors.white,
                    backgroundColor: Colors.red,
                    textStyle:
                    const TextStyle(fontStyle: FontStyle.normal)),
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    textStyle:
                    const TextStyle(fontStyle: FontStyle.normal)),

                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    try {
                      Navigator.pop(context);
                      debugPrint('productIds from user : $productIDs');
                      mProgressBarUtil.showProgressDialog();

                      List<String> listItems = productIDs.split(',');
                      getProducts(listItems);
                      productIdTextFieldController.clear();
                    } catch (e) {
                      log('error : ${e.toString()}');
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> showAuthenticationDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                  decoration: const InputDecoration(hintText: "Site Name"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      apiKey = value;
                    });
                  },
                  controller: apiKeyController,
                  decoration: const InputDecoration(hintText: "API Key"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      iosSdkKey = value;
                    });
                  },
                  controller: iosDdkKeyController,
                  decoration: const InputDecoration(hintText: "iOS SDK Key"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      androidSdkKey = value;
                    });
                  },
                  controller: sdkKeyController,
                  decoration: const InputDecoration(hintText: "Android SDK Key"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.red,
                    textStyle:
                    const TextStyle(fontStyle: FontStyle.normal)),
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    textStyle:
                    const TextStyle(fontStyle: FontStyle.normal)),
                child: const Text('Initialize'),
                onPressed: () {
                  Navigator.pop(context);
                  debugPrint('app details : $siteName, $apiKey, $androidSdkKey, $iosSdkKey');
                  authentication(siteName, apiKey, iosSdkKey, androidSdkKey);
                }
              )
            ]
          );
        });
  }

}
