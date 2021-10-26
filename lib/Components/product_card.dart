import 'dart:math';

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
  bool isBack = false;
  double angle = 0;

  void _flip() {
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: angle),
          duration: const Duration(seconds: 1),
          builder: (BuildContext context, double val, __) {
            if (val >= (pi / 2)) {
              isBack = true;
            } else {
              isBack = false;
            }
            return (Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(val),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  clipBehavior: Clip.antiAlias,
                  width: 300,
                  decoration: BoxDecoration(
                      color: ColorConstants.instance.primaryColor,
                      borderRadius: BorderRadius.circular(20.0)),
                  child: (isBack == false)
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2),
                                BlendMode.multiply),
                            child: Image.network(
                              widget.product.productPicRef,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: widget.onTapped,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: ColorConstants
                                                  .instance.waitingColor),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Icon(
                                              Icons.edit,
                                              color: ColorConstants
                                                  .instance.primaryColor,
                                            ),
                                          ),
                                        ),
                                      )),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.product.productName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: ColorConstants
                                                .instance.waitingColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          widget.product.productDesc,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: ColorConstants
                                                  .instance.textOnColor,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0),
                                        child: Text(
                                          'TRY ${widget.product.productPrice.toString()}.00',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ColorConstants
                                                  .instance.waitingColor,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
            ));
          }),
    );
  }
}
