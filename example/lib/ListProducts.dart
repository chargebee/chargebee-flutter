import 'dart:developer';

import 'package:chargebee_flutter_sdk/chargebee_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class ListProducts extends StatelessWidget {

  late List<Map<String, dynamic>> listItems;
  ListProducts(this.listItems, {Key? key}) : super(key: key);

  //static const platform = MethodChannel('flutter.dev/configure');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, pos) {
        return Card(
          child: ListTile(
            title: Text(listItems[pos]['productTitle'], style: const TextStyle(
                color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
            //subtitle: const Text("4,000"),
            trailing: Text("Subscribe", style: const TextStyle(
                color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
            // leading: SizedBox(
            //   width: 50,
            //   height: 50,
            // ),
            onTap: (){
              //onItemClick(listItems[pos]);
            },
          ),
        );
      },
    );
  }
  onItemClick(String menuItem) async {
    log('retrieveItems :$menuItem');
    // List<String> products = menuItem.trim().replaceAll(" ", "").split(',');
    //
    // try {
    //   await platform.invokeMethod('purchaseProduct',{"product_id":products}).then((value) {
    //
    //   });
    // } on PlatformException catch (e) {
    //   log('PlatformException : ${e.message}');
    // }


  }
}