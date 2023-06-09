import 'dart:developer';

import 'package:chargebee_flutter/chargebee_flutter.dart';
import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListView extends StatefulWidget {
  final List<Product> listProducts;
  final String title;

  const ProductListView(this.listProducts, {Key? key, required this.title})
      : super(key: key);

  @override
  ProductListViewState createState() => ProductListViewState(listProducts);
}

class ProductListViewState extends State<ProductListView> {
  late List<Product> listProducts;
  late var productPrice = '';
  late var productId = '';
  late var currencyCode = '';
  late ProgressBarUtil mProgressBarUtil;
  final TextEditingController productIdTextFieldController =
      TextEditingController();
  String? customerId = '';

  ProductListViewState(this.listProducts);

  @override
  Widget build(BuildContext context) {
    mProgressBarUtil = ProgressBarUtil(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
        ),
        body: ListView.builder(
          itemCount: listProducts.length,
          itemBuilder: (context, pos) {
            productPrice = listProducts[pos].priceString;
            productId = listProducts[pos].id;
            currencyCode = listProducts[pos].currencyCode;
            return Card(
              child: ListTile(
                title: Text(productId,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,),),
                subtitle: Text(
                    productPrice +
                        ' (currencyCode: ' +
                        currencyCode +
                        ')',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 15,),),
                trailing: const Text('Subscribe',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,),),
                onTap: () {
                  onItemClick(pos);
                },
              ),
            );
          },),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  onItemClick(int position) async {
    try {
      final map = listProducts[position];
      _showCustomerIdDialog(context, map);
    } on PlatformException catch (e) {
      debugPrint('${e.message}, ${e.details}');
    }
  }

  Future<void> purchaseProduct(Product product) async {
    try {
      final result = await Chargebee.purchaseProduct(product, customerId);
      debugPrint('subscription result : $result');
      debugPrint('subscription id : ${result.subscriptionId}');
      debugPrint('plan id : ${result.planId}');
      debugPrint('subscription status : ${result.status}');

      mProgressBarUtil.hideProgressDialog();

      if (result.status == 'true') {
        _showSuccessDialog(context, 'Success');
      } else {
        _showSuccessDialog(context, result.subscriptionId);
      }
    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      if (e.code.isNotEmpty) {
        final responseCode = int.parse(e.code);
        if (responseCode >= 500 && responseCode <=599 ) {
          /// Cache the productId in SharedPreferences if failed synching with Chargebee.
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('productId',product.id);
          /// validate the receipt
          validateReceipt(product.id);
        }
      }
    }
  }

  Future<void> validateReceipt(String product) async {
    try {
      final result = await Chargebee.validateReceipt(product);
      debugPrint('subscription result : $result');
      mProgressBarUtil.hideProgressDialog();

      if (result.status == 'true') {
        /// if validateReceipt success, clear the cache
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('productId');
        _showSuccessDialog(context, 'Success');
      } else {
        _showSuccessDialog(context, result.subscriptionId);
      }
    } on PlatformException catch (e) {
      debugPrint('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  Future<void> _showCustomerIdDialog(
      BuildContext context, Product product,) async => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Please enter Customer ID'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  customerId = value;
                });
              },
              controller: productIdTextFieldController,
              decoration: const InputDecoration(hintText: 'Customer ID'),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(fontStyle: FontStyle.normal),),
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
                    textStyle: const TextStyle(fontStyle: FontStyle.normal),),
                child: const Text('OK'),
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
          ),);

  Future<void> _showSuccessDialog(BuildContext context, String status) async => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Chargebee'),
            content: Text(status),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontStyle: FontStyle.normal),),
                child: const Text('OK'),
                onPressed: () {
                  mProgressBarUtil.hideProgressDialog();
                  Navigator.pop(context);
                },
              ),
            ],
          ),);
}
