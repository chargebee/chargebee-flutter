import 'package:flutter/material.dart';

class ListItems extends StatelessWidget {

  late List<String> listItems;
  ListItems(this.listItems, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, pos) {
        return Card(
          child: ListTile(
            title: Text(listItems[pos]),
            // leading: SizedBox(
            //   width: 50,
            //   height: 50,
            // ),
            onTap: (){
              //onItemClick(course[pos]);
            },
          ),
        );
      },
    );
  }
}