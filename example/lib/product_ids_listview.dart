import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';

class ProductIdentifiersView extends StatefulWidget {
  final List listProductIds;
  final String title;

  const ProductIdentifiersView(this.listProductIds,
      {Key? key, required this.title,})
      : super(key: key);

  @override
  ProductIdentifiersViewState createState() =>
      ProductIdentifiersViewState(listProductIds);
}

class ProductIdentifiersViewState extends State<ProductIdentifiersView> {
  late List listProducts;
  late ProgressBarUtil mProgressBarUtil;

  ProductIdentifiersViewState(this.listProducts);

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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Product Identifiers List'),
        ),
        body: ListView.builder(
          itemCount: listProducts.length,
          itemBuilder: (context, pos) => Card(
              child: ListTile(
                title: Text(listProducts[pos],
                    style: const TextStyle(
                      color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,),),
              ),
            ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
