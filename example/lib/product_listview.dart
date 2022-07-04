import 'package:chargebee_flutter_sdk/chargebee_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:chargebee_flutter_sdk/src/utils/progress_bar.dart';
import 'package:chargebee_flutter_sdk/src/utils/product.dart';

class ProductListView extends StatefulWidget {
  final List<Product> listProducts;

  const ProductListView(this.listProducts, {Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  ProductListViewState createState() => ProductListViewState(listProducts);
}

class ProductListViewState extends State<ProductListView> {
  late List<Product> listProducts;
  ProductListViewState(this.listProducts);

  late ProgressBarUtil mProgressBarUtil;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    mProgressBarUtil = ProgressBarUtil(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Play-Product List'),
        ),
        body: ListView.builder(
          itemCount: listProducts.length,
          itemBuilder: (context, pos) {
            return Card(
              child: ListTile(
                title: Text(listProducts[pos].id,
                    style: const TextStyle(
                      color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                subtitle: Text(listProducts[pos].price,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15)),
                trailing: const Text("Subscribe",
                    style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                onTap: () {
                  onItemClick(pos);
                },
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  onItemClick(int position) async {
    try {
      Product map = listProducts[position];
      _showCustomerIdDialog(context, map);
    } catch (e) {
      log('PlatformException : ${e.toString()}');
      print('exception  :${e.toString()}');
    }
  }

  Future<void> purchaseProduct(Product product) async {
    try {
      final result = (await Chargebee.purchaseProduct(product, customerId));
      if (kDebugMode) {
        print("subscription result : $result");
      }
      mProgressBarUtil.hideProgressDialog();

      if(result.status == "true"){
        _showSuccessDialog(context, "Success");
      }else{
        _showSuccessDialog(context, result.status);
      }
    }  catch (e) {
      log('PlatformException : ${e.toString()}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  final TextEditingController productIdTextFieldController =
      TextEditingController();
  String? customerId = "null";
  Future<void> _showCustomerIdDialog(
      BuildContext context, Product product) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please enter Customer ID'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  customerId = value;
                });
              },
              controller: productIdTextFieldController,
              decoration: const InputDecoration(hintText: "Customer ID"),
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
                    Navigator.pop(context);
                    mProgressBarUtil.showProgressDialog();
                    try {
                       purchaseProduct(product);
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

  Future<void> _showSuccessDialog(BuildContext context, String status) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Chargebee'),
            content: Text(status),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  mProgressBarUtil.hideProgressDialog();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
