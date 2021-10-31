import 'package:papape_store/Components/product_card.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_category_model.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:papape_store/Products/product.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryCard extends StatefulWidget {
  final ProductCategory category;
  final Function onPressedEdit;
  final Function onPressedDelete;

  const CategoryCard(
      {Key key, this.category, this.onPressedEdit, this.onPressedDelete})
      : super(key: key);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  Product _selectedProduct;
  String _selectedCatId;

  openProductDialog() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductSingle(
            productData: _selectedProduct,
            selectedCategoryId: _selectedCatId)));
  }

  openProductDialogNew() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductSingle(
            productData: null, selectedCategoryId: _selectedCatId)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.category.categoryName,
                  style: TextStyle(
                    fontFamily: 'Amatic',
                    fontSize: 25.0,
                    color: ColorConstants.instance.primaryColor,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                        child: Icon(
                          Icons.edit,
                          color: ColorConstants.instance.primaryColor,
                          size: 25.0,
                        ),
                        onTap: widget.onPressedEdit),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: GestureDetector(
                        child: Icon(
                          Icons.delete,
                          color: ColorConstants.instance.inactiveColor,
                          size: 25.0,
                        ),
                        onTap: widget.onPressedDelete,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          StreamBuilder<List<Product>>(
              stream:
                  FirestoreService().getProducts(widget.category.categoryId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                      case true:
                        return Column(
                          children: [
                            SizedBox(
                              height: 260.0,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: snapshot.data.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, right: 10.0),
                                    child: ProductCard(
                                      onTapped: () {
                                        setState(() {
                                          _selectedProduct =
                                              snapshot.data[index];
                                          _selectedCatId =
                                              widget.category.categoryId;
                                        });
                                        openProductDialog();
                                      },
                                      product: snapshot.data[index],
                                      index: index,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                    color:
                                        ColorConstants.instance.secondaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0))),
                                child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCatId =
                                            widget.category.categoryId;
                                      });
                                      openProductDialogNew();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(FontAwesomeIcons.plus,
                                            size: 25.0,
                                            color: ColorConstants
                                                .instance.iconOnColor),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            'Yeni Ürün Ekle',
                                            style: TextStyle(
                                                color: ColorConstants
                                                    .instance.textOnColor),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        );
                        break;
                      default:
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                  color: ColorConstants.instance.secondaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0))),
                              child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCatId =
                                          widget.category.categoryId;
                                    });
                                    openProductDialogNew();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.plus,
                                          size: 25.0,
                                          color: ColorConstants
                                              .instance.iconOnColor),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: Text(
                                          'Yeni Ürün Ekle',
                                          style: TextStyle(
                                              color: ColorConstants
                                                  .instance.textOnColor),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        );
                    }
                    break;
                  default:
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: ColorConstants.instance.primaryColor,
                    ));
                }
              }),
        ],
      ),
    );
  }
}
