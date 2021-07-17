import 'package:bulb/Models/product_category_model.dart';
import 'package:bulb/Models/product_model.dart';
import 'package:bulb/Products/category.dart';
import 'package:bulb/Products/product.dart';
import 'package:bulb/Providers/store_provider.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  StoreProvider _storeProvider;
  List<ProductCategory> category;
  List<Product> products;
  bool _isLoading = false;
  String _selectedCatId;
  ProductCategory _selectedCategory;
  Product _selectedProduct;

  openCategoryDialog() async {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kategori eklemeden önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) =>
                CategorySingle(categoryData: _selectedCategory)))
        .whenComplete(() {
      setState(() {
        _selectedCategory = null;
      });
    });
  }

  openProductDialog() async {
    if (_selectedProduct != null && _selectedProduct.productCatId != null) {
      int index = category.indexWhere(
          (element) => element.categoryId == _selectedProduct.productCatId);
      setState(() {
        _selectedCatId = category[index].categoryId;
      });
    }
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

  deleteCatYesNo(BuildContext _context, ProductCategory category) {
    CoolAlert.show(
        context: _context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Kategoriyi silmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          deleteCategory(category);
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  deleteCategory(ProductCategory category) {
    setState(() {
      _isLoading = true;
    });
    FirestoreService()
        .removeCategory(category.categoryId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              _isLoading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading == false)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  'Ürünler',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30.0,
                      fontFamily: 'Armatic',
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                      child: Text("Yeni Başlık Ekle".toUpperCase(),
                          style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side: BorderSide(
                                          width: 2,
                                          color: Theme.of(context)
                                              .primaryColor)))),
                      onPressed: () {
                        openCategoryDialog();
                      }),
                ),
              ),
              Flexible(
                child: StreamBuilder<List<ProductCategory>>(
                  stream: FirestoreService().getProductCategories(),
                  builder: (context, snapshot) {
                    category = snapshot.data;
                    return (snapshot.connectionState == ConnectionState.active)
                        ? (snapshot.hasData == true)
                            ? (snapshot.data.length > 0)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                8,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      snapshot.data[index]
                                                          .categoryName,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontFamily: 'Bebas',
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          child: Icon(
                                                              Icons.edit,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          onTap: () {
                                                            setState(() {
                                                              _selectedCategory =
                                                                  snapshot.data[
                                                                      index];
                                                            });
                                                            openCategoryDialog();
                                                          },
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0),
                                                          child:
                                                              GestureDetector(
                                                            child: Icon(
                                                                Icons.delete,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                            onTap: () {
                                                              deleteCatYesNo(
                                                                  context,
                                                                  snapshot.data[
                                                                      index]);
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              StreamBuilder<List<Product>>(
                                                  stream: FirestoreService()
                                                      .getProducts(snapshot
                                                          .data[index]
                                                          .categoryId),
                                                  builder: (context,
                                                      snapshotProduct) {
                                                    products =
                                                        snapshotProduct.data;
                                                    return (snapshotProduct
                                                                .connectionState ==
                                                            ConnectionState
                                                                .active)
                                                        ? (snapshotProduct.data
                                                                    .length >
                                                                0)
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10.0),
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(50.0))),
                                                                      child: IconButton(
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              _selectedCatId = snapshot.data[index].categoryId;
                                                                            });
                                                                            openProductDialog();
                                                                          },
                                                                          icon: FaIcon(FontAwesomeIcons.plus, size: 25.0, color: Colors.white)),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10.0,
                                                                          bottom:
                                                                              15.0),
                                                                      child:
                                                                          Text(
                                                                        "'${snapshot.data[index].categoryName}' başlığının altına yeni ürün ekle",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                18.0,
                                                                            color:
                                                                                Theme.of(context).primaryColor),
                                                                      ),
                                                                    ),
                                                                    ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: ClampingScrollPhysics(),
                                                                        itemCount: snapshotProduct.data.length,
                                                                        itemBuilder: (context, indexDishes) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 10.0),
                                                                            child:
                                                                                Card(
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(50.0),
                                                                              ),
                                                                              clipBehavior: Clip.antiAlias,
                                                                              color: Colors.white,
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                    gradient: LinearGradient(colors: [
                                                                                  Theme.of(context).accentColor,
                                                                                  Theme.of(context).primaryColor
                                                                                ], begin: Alignment.bottomRight, end: Alignment.topLeft)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(15.0),
                                                                                  child: ListTile(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        _selectedProduct = snapshotProduct.data[indexDishes];
                                                                                        _selectedCatId = snapshot.data[index].categoryId;
                                                                                      });
                                                                                      openProductDialog();
                                                                                    },
                                                                                    title: Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Text(
                                                                                            snapshotProduct.data[indexDishes].productName,
                                                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0, fontFamily: 'Roboto'),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    trailing: Container(
                                                                                      height: MediaQuery.of(context).size.height,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 10.0),
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Icon(Icons.arrow_forward, color: Colors.white)
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    subtitle: Padding(
                                                                                      padding: const EdgeInsets.only(top: 8.0),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(snapshotProduct.data[indexDishes].productDesc, style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                            child: Text(
                                                                                              'Fiyat: ${snapshotProduct.data[indexDishes].productPrice} TRY',
                                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0, fontFamily: 'Roboto'),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                  ],
                                                                ),
                                                              )
                                                            : Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(50.0))),
                                                                      child: IconButton(
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              _selectedCatId = snapshot.data[index].categoryId;
                                                                            });
                                                                            openProductDialog();
                                                                          },
                                                                          icon: FaIcon(FontAwesomeIcons.plus, size: 25.0, color: Colors.white)),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10.0),
                                                                      child:
                                                                          Text(
                                                                        "'${snapshot.data[index].categoryName}' başlığının altına yeni ürün ekle",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                18.0,
                                                                            color:
                                                                                Theme.of(context).primaryColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                        : Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                            backgroundColor:
                                                                Colors.white,
                                                          ));
                                                  }),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_late_outlined,
                                          size: 100.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: Text(
                                            'Henüz kaydedilmiş bir kategoriniz bulunmamaktadır !',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 25.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_late_outlined,
                                      size: 100.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        'Henüz kaydedilmiş bir kategoriniz bulunmamaktadır !',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 25.0),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
  }
}
