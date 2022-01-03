import 'package:flutter/material.dart';

class GroceryLIst extends StatelessWidget {
  const GroceryLIst({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Grocery List'),
      ),
    );
  }
}