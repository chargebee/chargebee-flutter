import 'package:chargebee_flutter_sdk_example/progress_bar.dart';
import 'package:flutter/material.dart';

class ItemsView extends StatefulWidget {
  final List itemsList;
  final String title;

  const ItemsView(this.itemsList, {Key? key, required this.title})
      : super(key: key);

  @override
  ItemnsViewState createState() => ItemnsViewState(itemsList, title);
}

class ItemnsViewState extends State<ItemsView> {
  late List itemsList;
  late String title;
  late ProgressBarUtil mProgressBarUtil;

  ItemnsViewState(this.itemsList, this.title);

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
          title: Text(title),
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
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
