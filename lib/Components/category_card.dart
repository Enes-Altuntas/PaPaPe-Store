import 'package:bulb/Components/product_card.dart';
import 'package:bulb/Models/product_category_model.dart';
import 'package:bulb/Models/product_model.dart';
import 'package:bulb/Products/product.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryCard extends StatefulWidget {
  final ProductCategory category;
  final Function onPressedEdit;
  final Function onPressedDelete;

  CategoryCard(
      {Key key, this.category, this.onPressedEdit, this.onPressedDelete})
      : super(key: key);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  Product _selectedProduct;
  String _selectedCatId;

  openProductDialog() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ProductSingle(
                productData: _selectedProduct,
                selectedCategoryId: _selectedCatId)))
        .whenComplete(() {
      setState(() {
        _selectedProduct = null;
        _selectedCatId = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 8,
      color: Colors.white,
      child: Padding(
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
                        fontSize: 20.0,
                        fontFamily: 'Bebas',
                        color: Theme.of(context).primaryColor),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                          child: Icon(Icons.edit,
                              color: Theme.of(context).primaryColor),
                          onTap: widget.onPressedEdit),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: GestureDetector(
                          child: Icon(Icons.delete,
                              color: Theme.of(context).primaryColor),
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
                      switch (snapshot.hasData && snapshot.data.length > 0) {
                        case true:
                          return Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
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
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0))),
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedCatId =
                                              widget.category.categoryId;
                                        });
                                        openProductDialog();
                                      },
                                      icon: FaIcon(FontAwesomeIcons.plus,
                                          size: 25.0, color: Colors.white)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 15.0),
                                child: Text(
                                  "'${widget.category.categoryName}' başlığının altına yeni ürün ekle",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 18.0,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          );
                          break;
                        default:
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0))),
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedCatId =
                                              widget.category.categoryId;
                                        });
                                        openProductDialog();
                                      },
                                      icon: FaIcon(FontAwesomeIcons.plus,
                                          size: 25.0, color: Colors.white)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "'${widget.category.categoryName}' başlığının altına yeni ürün ekle",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                      }
                      break;
                    default:
                      return Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
