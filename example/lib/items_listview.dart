import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';

class ItemsView extends StatefulWidget {
  final List<dynamic> itemsList;

  const ItemsView(this.itemsList, {Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  ItemnsViewState createState() => ItemnsViewState(itemsList);
}

class ItemnsViewState extends State<ItemsView> {
  late List<dynamic> itemsList;
  ItemnsViewState(this.itemsList);

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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: const Text('List Items'),
        ),
        body: ListView.builder(
          itemCount: itemsList.length,
          itemBuilder: (context, pos) {
            return Card(
              child: ListTile(
                title: Text(itemsList[pos],
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