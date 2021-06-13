import 'package:bulovva_store/Models/product_model.dart';
import 'package:flutter/material.dart';

class ProductSingle extends StatefulWidget {
  final Product productData;
  final String selectedCategory;

  ProductSingle({Key key, this.productData, this.selectedCategory})
      : super(key: key);

  @override
  _ProductSingleState createState() => _ProductSingleState();
}

class _ProductSingleState extends State<ProductSingle> {
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
