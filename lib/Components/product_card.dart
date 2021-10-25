import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function onTapped;

  const ProductCard({Key key, this.product, this.onTapped}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapped,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: ColorConstants.instance.primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0))),
                  child: (widget.product.productPicRef != null &&
                          widget.product.productPicRef.isNotEmpty)
                      ? Image.network(
                          widget.product.productPicRef,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            return loadingProgress == null
                                ? child
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color:
                                            ColorConstants.instance.iconOnColor,
                                      ),
                                    ),
                                  );
                          },
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Resim Yok',
                              style: TextStyle(
                                color: ColorConstants.instance.textOnColor,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.product.productName,
                      style: TextStyle(
                          color: ColorConstants.instance.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          fontFamily: 'Roboto'),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        widget.product.productDesc,
                        style: const TextStyle(fontFamily: 'Roboto'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Fiyat: ${widget.product.productPrice} TRY',
                        style: TextStyle(
                            color: ColorConstants.instance.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            fontFamily: 'Roboto'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
