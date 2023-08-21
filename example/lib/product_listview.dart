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
  String? productType;

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
                title: Text(
                  productId,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  productPrice + ' (currencyCode: ' + currencyCode + ')',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                trailing: const Text(
                  'Buy',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
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
      final product = listProducts[position];
      if (product.subscriptionPeriod.unit.isNotEmpty &&
          product.subscriptionPeriod.numberOfUnits != 0) {
        mProgressBarUtil.showProgressDialog();
        purchaseProduct(product);
      } else {
        _showDialog(context, product);
      }
    } on PlatformException catch (e) {
      debugPrint('${e.message}, ${e.details}');
    }
  }

  Future<void> purchaseProduct(Product product) async {
    try {
      final customer = CBCustomer(
        'abc_flutter_test',
        'fn',
        'ln',
        'abc@gmail.com',
      );
      final result = await Chargebee.purchaseProduct(product, customer: customer);
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
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
      if (e.code.isNotEmpty) {
        final responseCode = int.parse(e.code);
        if (responseCode >= 500 && responseCode <= 599) {
          /// Cache the productId in SharedPreferences if failed synching with Chargebee.
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('productId', product.id);

          /// validate the receipt
          validateReceipt(product.id);
        }
      }
    }
  }

  Future<void> purchaseNonSubscriptionProduct(
      Product product, ProductType productType) async {
    final customer = CBCustomer(
      'abc_flutter_test',
      'fn',
      'ln',
      'abc@gmail.com',
    );
    try {
      final result = await Chargebee.purchaseNonSubscriptionProduct(
          product = product, productType = productType, customer);
      debugPrint('subscription result : $result');
      debugPrint('invoice id : ${result.invoiceId}');
      debugPrint('charge id : ${result.chargeId}');
      debugPrint('customer id : ${result.customerId}');

      mProgressBarUtil.hideProgressDialog();

      if (result.invoiceId.isNotEmpty) {
        _showSuccessDialog(context, 'Success');
      } else {
        _showSuccessDialog(context, 'Failed');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
      if (e.code.isNotEmpty) {
        final responseCode = int.parse(e.code);
        if (responseCode >= 500 && responseCode <= 599) {
          /// Cache the productId in SharedPreferences if failed synching with Chargebee.
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('productId', product.id);

          /// validate the receipt
          validateNonSubscriptionReceipt(product.id, productType, customer);
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
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  Future<void> validateNonSubscriptionReceipt(String productId,
      ProductType productType, CBCustomer customer) async {
    try {
      final result = await Chargebee.validateReceiptForNonSubscriptions(
          productId, productType, customer);
      debugPrint('subscription result : $result');
      mProgressBarUtil.hideProgressDialog();

      if (result.invoiceId.isNotEmpty) {
        /// if validateReceipt success, clear the cache
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('productId');
        _showSuccessDialog(context, 'Success');
      } else {
        _showSuccessDialog(context, 'Failed');
      }
    } on PlatformException catch (e) {
      debugPrint(
          'Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
      mProgressBarUtil.hideProgressDialog();
    }
  }

  Future<void> _showDialog(
    BuildContext context,
    Product product,
  ) async =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please enter One Time Product Type'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                productType = value;
              });
            },
            controller: productIdTextFieldController,
            decoration: const InputDecoration(hintText: 'Product Type'),
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
                  Navigator.pop(context);
                  mProgressBarUtil.showProgressDialog();
                  try {
                    ProductType type;
                    if (productType != null) {
                      if (productType == ProductType.consumable.name) {
                        type = ProductType.consumable;
                      } else if (productType ==
                          ProductType.non_consumable.name) {
                        type = ProductType.non_consumable;
                      } else {
                        type = ProductType.non_renewing_subscription;
                      }
                      purchaseNonSubscriptionProduct(product, type);
                    }
                  } catch (e) {
                    log('error : ${e.toString()}');
                  }
                });
              },
            ),
          ],
        ),
      );

  Future<void> _showSuccessDialog(BuildContext context, String status) async =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chargebee'),
          content: Text(status),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                textStyle: const TextStyle(fontStyle: FontStyle.normal),
              ),
              child: const Text('OK'),
              onPressed: () {
                mProgressBarUtil.hideProgressDialog();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
}
