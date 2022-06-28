import 'dart:async';
import 'dart:developer';
import 'package:chargebee_flutter_sdk/chargebee_flutter_sdk.dart';
import 'package:chargebee_flutter_sdk_example/product_listview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Constants.dart';
import 'package:chargebee_flutter_sdk/src/utils/progress_bar.dart';
import 'alertDialog.dart';

import 'dart:convert';

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
  late String siteNameText, apiKeyText, sdkKeyText;

  final TextEditingController productIdTextFieldController =
      TextEditingController();
  late String productIDs;
  late String queryParams;

  late ProgressBarUtil mProgressBarUtil;

  @override
  void initState() {
    // For Android
    authentication("cb-imay-test","test_EojsGoGFeHoc3VpGPQDOZGAxYy3d0FF3",
        "cb-wpkheixkuzgxbnt23rzslg724y", "com.chargebee.example");
    // For iOS
    // authentication("cb-imay-test","test_EojsGoGFeHoc3VpGPQDOZGAxYy3d0FF3",
    //     "cb-njjoibyzbrhyjg7yz4hkwg2ywq");
    //initPlatformState();
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

  onItemClick(String menuItem) async {
    switch (menuItem) {
      case Constants.config:
        {
          showAuthenticationDialog(context);
        }
        break;

      case Constants.getProducts:
        {
          showSkProductDialog(context);
        }
        break;

      case Constants.getSubscriptionStatus:
        {
          showSubscriptionDialog(context);
        }
        break;
      case Constants.purchase:
        {
          purchase(cbProductList.first, "12345");
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
  }

  Future<void> authentication(
      String siteName, String apiKey, [String? sdkKey, packageName]) async {
    try {
      await Chargebee.configure(siteName, apiKey, sdkKey);
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
    }
  }

  Future<void> getProductIdList(List<String> productIDsList) async {

    try {
      cbProductList =
          await Chargebee.getProductIdList(productIDsList);
      log('result : ${cbProductList}');

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
      }else{
        log('Items not avilable to buy');
        _showDialog(context);
      }
    } on PlatformException catch (e) {
      log('PlatformException : ${e.message}');
      if (mProgressBarUtil.isProgressBarShowing()) {
        mProgressBarUtil.hideProgressDialog();
      }
    }
  }

  _showDialog(BuildContext context) {
    BaseAlertDialog  alert = BaseAlertDialog("Chargebee","Items not avilable to buy");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> showSkProductDialog(BuildContext context) async {
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
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    try {
                      Navigator.pop(context);
                      log('productIDs with comma from user : $productIDs');
                      mProgressBarUtil.showProgressDialog();

                       List<String> listItems = productIDs.split(',');
                       getProductIdList(listItems);
                      //getProducts();
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

  Future<void> showSubscriptionDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please enter the queryParameters'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  queryParams = value;
                });
              },
              controller: productIdTextFieldController,
              decoration: const InputDecoration(hintText: " key value pair"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    try {
                      Navigator.pop(context);
                      log('QueryParam from user : $queryParams');
                      mProgressBarUtil.showProgressDialog();
                      // Map param = json.decode(queryParams);
                      // ChargebeeFlutterMethods.retrieveSubscriptions( {"status": "is_active"});
                      subscriptionStatus();
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

  Future<void> subscriptionStatus() async {
    List<Object?> subscriptionsList = [];
    subscriptionsList = await Chargebee.retrieveSubscriptions(
        {"status": "active", "customer_id": "12345"}) as List<Object?>;
    log('Subs List : $subscriptionsList');
  }

  Future<void> getProducts() async {
    cbProductList = await Chargebee.getProductIdList(["chargebee.premium.ios"]);
    log('product List : $cbProductList');
    print(cbProductList.first.id);
  }

  Future<void> purchase(Product product, String customerID) async {
    //Saftey
    log('Product List : $products');
    PurchaseResult result;

    result = await Chargebee.purchaseProduct(product, customerID);

    print(result.subscriptionId);
    print(result.status);
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
                      siteNameText = value;
                    });
                  },
                  controller: siteNameController,
                  decoration: const InputDecoration(hintText: "Site Name"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      apiKeyText = value;
                    });
                  },
                  controller: apiKeyController,
                  decoration: const InputDecoration(hintText: "API Key"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      sdkKeyText = value;
                    });
                  },
                  controller: sdkKeyController,
                  decoration: const InputDecoration(hintText: "SDK Key"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Initialize'),
                onPressed: () {
                  Navigator.pop(context);
                  log('app details : $siteNameText, $apiKeyText, $sdkKeyText');
                  authentication(siteNameText, apiKeyText, sdkKeyText);
                  //});
                },
              ),
            ],
          );
        });
  }

  Completer _myCompleter = Completer();
  Future startSomething() {
    // show a user dialog or an image picker or kick off a polling function
    return _myCompleter.future;
  }
  void endSomething() {
    _myCompleter.complete();
  }
}
