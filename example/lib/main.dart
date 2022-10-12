import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/product_listview.dart';
import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Constants.dart';
import 'alertDialog.dart';
import 'package:chargebee_flutter/src/utils/product.dart';

import 'items_listview.dart';
import 'product_listview.dart';

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

  const MyHomePage(this.cbMenu, {Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(cbMenu);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.cbMenu);

  late List<String> cbMenu;

  List<Product> cbProductList = [];
  List<Product> products = [];

  final TextEditingController siteNameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController sdkKeyController = TextEditingController();
  final TextEditingController iosDdkKeyController = TextEditingController();
  late String siteName="", apiKey="", androidSdkKey="", iosSdkKey = "";

  final TextEditingController productIdTextFieldController =
      TextEditingController();
  late String productIDs;
  late Map<String, String> queryParams = {"channel": "app_store","customer_id":"imay-flutter"};
  late Map<String, String> itemsQueryParams = {"limit": "10","sort_by[desc]": "Standard","channel[is]": "play_store"};
  late Map<String, String> plansQueryParams = {"sort_by[desc]": "Standard","channel[is]": "app_store"};
  late String userInput;
  late ProgressBarUtil mProgressBarUtil;

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
      case Constants.getPlans:
        mProgressBarUtil.showProgressDialog();
        retrieveAllPlans(plansQueryParams);
        break;
      case Constants.getItems:
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
      log('PlatformException : ${e.message}');
    }
  }

  Future<void> getProductIdList(List<String> productIDsList) async {
    try {
      cbProductList = await Chargebee.retrieveProducts(productIDsList);
      log('result : $cbProductList');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      if (cbProductList.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ProductListView(cbProductList,
                  title: 'Google Play-Product List'),
            ));
      } else {
        log('Items not avilable to buy');
        _showDialog(context, "Items not avilable to buy");
      }
    } catch (e) {
      log('Exception : ${e.toString()}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
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
                      log('productIDs with comma from user : $productIDs');
                      mProgressBarUtil.showProgressDialog();

                      List<String> listItems = productIDs.split(',');
                      getProductIdList(listItems);
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


  Future<void> retrieveSubscriptions(Map<String, dynamic> queryparam) async {
    try {
      final result = await Chargebee.retrieveSubscriptions(queryparam);
      log('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      if (result.length > 0) {
        _showDialog(context, "Subscriptions retrieved successfully!");
      } else {
        log('Subscription not found in Chargebee System');
        _showDialog(context, "Subscription not found in Chargebee System");
      }
    } catch (e) {
      log('Exception : ${e.toString()}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
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
                  log('app details : $siteName, $apiKey, $androidSdkKey, $iosSdkKey');
                  authentication(siteName, apiKey, iosSdkKey, androidSdkKey);
                }
              )
            ]
          );
        });
  }

  Future<void> retrieveAllPlans(Map<String, dynamic> queryparam) async {
    try {
      final result = await Chargebee.retrieveAllPlans(queryparam);
      log('result : $result');

      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
      // if (result !=null) {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (BuildContext context) => ItemsView(result,
      //             title: 'List Plans'),
      //       ));
      // } else {
      //   log('Plans not avilable in chargebee');
      //   _showDialog(context, "Plans not avilable in chargebee");
      // }

    } catch (e) {
      log('Exception : ${e.toString()}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  Future<void> retrieveAllItems(Map<String, dynamic> queryparam) async {
    try {
      final result = await Chargebee.retrieveAllItems(queryparam);
      print('result : $result');

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
        log('Items not avilable in chargebee');
        _showDialog(context, "Items not avilable in chargebee");
      }

    } catch (e) {
      log('Exception : ${e.toString()}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }
}
