import 'package:chargebee_flutter_sdk/chargebee_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:chargebee_flutter_sdk/src/utils/progress_bar.dart';


class ProductListView extends StatefulWidget {
  final List<Map<String, dynamic>> listProducts;

  const ProductListView(this.listProducts,{Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ProductListViewState createState() => ProductListViewState(listProducts);
}


class ProductListViewState extends State<ProductListView> {

  late List<Map<String, dynamic>> listProducts;
  ProductListViewState(this.listProducts);

  late ProgressBarUtil mProgressBarUtil;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  @override
  Widget build(BuildContext context) {
    mProgressBarUtil  = ProgressBarUtil(context);
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
                title: Text(
                    listProducts[pos]['productTitle'], style: const TextStyle(
                    color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),

                trailing: const Text("Subscribe", style: TextStyle(
                    color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () {
                  print('onTap() ');
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
      print('position  :$position');
      Map<String, dynamic> map = listProducts[position];
      print('map  :$map');
      _showCustomerIdDialog(context, map);

    } catch (e) {
        log('PlatformException : ${e.toString()}');
        print('exception  :${e.toString()}');
      }
  }


  Future<void> purchaseProduct(Map<String, dynamic> product) async {
    print("customerId : $customerId");

    try {
      Map<dynamic, dynamic> result = (await ChargebeeFlutterMethods.purchaseProduct(product, customerId));
      if (kDebugMode) {
        print("subscription result : $result");
      }
      if(mProgressBarUtil.isProgressBarShowing()){
        mProgressBarUtil.hideProgressDialog();
      }
      String status = result["status"].toString();
      print("status : $status");
      if(status !=null && status == "true"){
        _showSuccessDialog(context, "Success");
      }else{
        _showSuccessDialog(context,"Failed");
      }

    }  catch (e) {
      log('PlatformException : ${e.toString()}');
      if(mProgressBarUtil.isProgressBarShowing()){
        mProgressBarUtil.hideProgressDialog();
      }
    }

  }

  final TextEditingController productIdTextFieldController = TextEditingController();
  late String customerId;
  Future<void> _showCustomerIdDialog(BuildContext context, Map<String, dynamic> product) async {
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
                      log('Customer ID : $customerId');

                      purchaseProduct(product);
                    }catch(e){
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
            content:  Text(status),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }


}



