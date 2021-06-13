import 'package:bulovva_store/Models/product_category_model.dart';
import 'package:flutter/material.dart';

class CategorySingle extends StatefulWidget {
  final ProductCategory categoryData;

  CategorySingle({Key key, this.categoryData}) : super(key: key);

  @override
  _CategorySingleState createState() => _CategorySingleState();
}

class _CategorySingleState extends State<CategorySingle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.red[600], Colors.purple[500]],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft)),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text('bulb',
              style: TextStyle(
                  fontSize: 40.0, color: Colors.white, fontFamily: 'Dancing')),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.red[600], Colors.purple[500]],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft)),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0))),
              child: Column(),
            ),
          ),
        ));
  }
}
