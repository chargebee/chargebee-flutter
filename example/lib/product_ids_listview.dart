import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';

class ProductIdentifiersView extends StatefulWidget {
  final List<dynamic> listProductIds;

  const ProductIdentifiersView(this.listProductIds, {Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  ProductIdentifiersViewState createState() => ProductIdentifiersViewState(listProductIds);
}

class ProductIdentifiersViewState extends State<ProductIdentifiersView> {
  late List<dynamic> listProducts;
  ProductIdentifiersViewState(this.listProducts);

  late ProgressBarUtil mProgressBarUtil;

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
          title: const Text('Product Identifiers List'),
        ),
        body: ListView.builder(
          itemCount: listProducts.length,
          itemBuilder: (context, pos) {
            return Card(
              child: ListTile(
                title: Text(listProducts[pos],
                    style: const TextStyle(
                      color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),

                // onTap: () {
                //   onItemClick(pos);
                // },
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

}
