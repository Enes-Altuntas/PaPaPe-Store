import 'package:papape_store/Models/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function onTapped;

  ProductCard({Key key, this.product, this.onTapped}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(color: Colors.amber[200]),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListTile(
            onTap: widget.onTapped,
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.product.productName,
                    style: TextStyle(
                        color: Colors.amber[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: MediaQuery.of(context).size.width / 4.5,
              height: MediaQuery.of(context).size.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.amber[900],
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: (widget.product.productPicRef != null &&
                      widget.product.productPicRef.isNotEmpty)
                  ? Image.network(
                      widget.product.productPicRef,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                      },
                    )
                  : Center(
                      child: Text(
                        'Resim Yok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.productDesc,
                      style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontFamily: 'Roboto')),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text(
                      'Fiyat: ${widget.product.productPrice} TRY',
                      style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          fontFamily: 'Roboto'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
