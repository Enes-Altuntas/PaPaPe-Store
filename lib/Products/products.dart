import 'package:bulovva_store/Models/product_category_model.dart';
import 'package:bulovva_store/Models/product_model.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<ProductCategory> category;
  List<Product> products;
  String _selectedCur;
  String _selectedCat;
  String _selectedCatId;
  bool _isLoading = false;

  ProductCategory _selectedCategory;
  Product _selectedProduct;

  final TextEditingController _categoryRow = TextEditingController();
  final TextEditingController _categoryName = TextEditingController();

  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productDesc = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();

  openCategoryDialog() {
    if (_selectedCategory != null) {
      setState(() {
        _categoryRow.text = _selectedCategory.categoryRow.toString();
        _categoryName.text = _selectedCategory.categoryName;
      });
    }
    return showDialog(
        context: context,
        builder: (_context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (_selectedCategory == null)
                    ? Text('Kategori Ekle')
                    : Text('Kategori Düzenle'),
                GestureDetector(
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red[400],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                      _categoryName.text = '';
                      _categoryRow.text = '';
                    });
                    Navigator.of(_context).pop();
                  },
                )
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        controller: _categoryRow,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Kategori Sırası',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: TextFormField(
                        controller: _categoryName,
                        decoration: InputDecoration(
                            labelText: 'Kategori Adı',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(_context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            saveCategory();
                          },
                          child: Text('Kategori Ekle'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red[400],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  openProductDialog() {
    if (category.length > 0) {
      if (_selectedProduct != null) {
        int index = category.indexWhere(
            (element) => element.categoryId == _selectedProduct.productCatId);

        setState(() {
          _selectedCat = category[index].categoryName;
          _selectedCur = _selectedProduct.currency;
          _productDesc.text = _selectedProduct.productDesc;
          _productName.text = _selectedProduct.productName;
          _productPrice.text = _selectedProduct.productPrice.toString();
        });
      }
      return showDialog(
          context: context,
          builder: (_context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (_selectedProduct == null)
                          ? Text('Ürün Ekle')
                          : Text('Ürün Düzenle'),
                      GestureDetector(
                        child: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red[400],
                        ),
                        onTap: () {
                          _selectedCur = null;
                          _selectedCat = null;
                          _selectedProduct = null;
                          _productName.text = '';
                          _productDesc.text = '';
                          _productPrice.text = '';
                          Navigator.of(_context).pop();
                        },
                      )
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                width: MediaQuery.of(_context).size.width,
                                child: DropdownButton(
                                    value: _selectedCat,
                                    hint: Text("Ürün için kategori seçiniz !"),
                                    items: category
                                        .map((ProductCategory category) {
                                      return new DropdownMenuItem<String>(
                                        value: category.categoryName,
                                        onTap: () {
                                          _selectedCatId = category.categoryId;
                                        },
                                        child: new Text(category.categoryName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCat = value;
                                      });
                                    }),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: TextFormField(
                              controller: _productName,
                              decoration: InputDecoration(
                                  labelText: 'Ürün Adı',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: TextFormField(
                              controller: _productDesc,
                              decoration: InputDecoration(
                                  labelText: 'Ürün Tanımı',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: TextFormField(
                              controller: _productPrice,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Ürün Fiyatı',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: SizedBox(
                                width: MediaQuery.of(_context).size.width,
                                child: DropdownButton(
                                    value: _selectedCur,
                                    hint: Text("Para Birimi Seçiniz !"),
                                    items: <String>['TRY', 'USD', 'EUR']
                                        .map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCur = value;
                                      });
                                    }),
                              )),
                          SizedBox(
                            width: MediaQuery.of(_context).size.width,
                            child: ElevatedButton(
                                onPressed: () {
                                  saveProduct();
                                },
                                child: (_selectedProduct == null)
                                    ? Text('Ürün Ekle')
                                    : Text('Ürün Düzenle'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                )),
                          ),
                          SizedBox(
                            width: MediaQuery.of(_context).size.width,
                            child: ElevatedButton(
                                onPressed: () {
                                  removeProduct();
                                },
                                child: Text('Ürün Sil'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          });
    } else {
      ToastService()
          .showInfo('Kategori eklemeden ürün ekleyemezsiniz !', context);
    }
  }

  saveCategory() {
    setState(() {
      _isLoading = true;
    });
    if (_selectedCategory == null) {
      ProductCategory category = ProductCategory(
        categoryId: Uuid().v4(),
        categoryRow: int.parse(_categoryRow.text),
        categoryName: _categoryName.text,
      );

      FirestoreService()
          .saveCategory(category)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                _isLoading = false;
                _categoryName.text = '';
                _categoryRow.text = '';
                _selectedCategory = null;
              }));
    } else {
      ProductCategory updCategory = ProductCategory(
        categoryId: _selectedCategory.categoryId,
        categoryRow: int.parse(_categoryRow.text),
        categoryName: _categoryName.text,
      );

      FirestoreService()
          .updateCategory(updCategory)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                _isLoading = false;
                _categoryName.text = '';
                _categoryRow.text = '';
                _selectedCategory = null;
              }));
    }
    Navigator.of(context).pop();
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

  saveProduct() {
    setState(() {
      _isLoading = true;
    });
    if (_selectedProduct == null) {
      Product product = Product(
          productId: Uuid().v4(),
          currency: _selectedCur,
          productCatId: _selectedCatId,
          productDesc: _productDesc.text,
          productName: _productName.text,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .saveProduct(product)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                _isLoading = false;
              }));
    } else {
      Product product = Product(
          productId: _selectedProduct.productId,
          currency: _selectedCur,
          productCatId: (_selectedCatId != null)
              ? _selectedCatId
              : _selectedProduct.productCatId,
          productDesc: _productDesc.text,
          productName: _productName.text,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .updateProduct(product, _selectedProduct)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                _isLoading = false;
              }));
    }
    Navigator.of(context).pop();
    setState(() {
      _productDesc.text = '';
      _productName.text = '';
      _productPrice.text = '';
      _selectedCur = null;
      _selectedCat = null;
      _selectedCatId = null;
    });
  }

  removeProduct() {
    setState(() {
      _isLoading = true;
    });
    FirestoreService()
        .removeProduct(
            _selectedProduct.productId, _selectedProduct.productCatId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              _isLoading = false;
            }));
    Navigator.of(context).pop();
    setState(() {
      _productDesc.text = '';
      _productName.text = '';
      _productPrice.text = '';
      _selectedCur = null;
      _selectedCat = null;
      _selectedCatId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.white,
            label: Text(
              'Ürün',
              style: TextStyle(color: Colors.red[800]),
            ),
            icon: Icon(
              Icons.add,
              color: Colors.red[800],
            ),
            onPressed: () {
              openProductDialog();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              label: Text('Kategori', style: TextStyle(color: Colors.red[800])),
              icon: Icon(
                Icons.add,
                color: Colors.red[800],
              ),
              onPressed: () {
                openCategoryDialog();
              },
            ),
          ),
        ],
      ),
      body: (_isLoading == false)
          ? StreamBuilder<List<ProductCategory>>(
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
                                        MediaQuery.of(context).size.width / 8,
                                    color: (index % 2 == 0)
                                        ? Colors.red
                                        : Colors.white,
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
                                                  snapshot
                                                      .data[index].categoryName,
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontFamily: 'Bebas',
                                                      color: (index % 2 != 0)
                                                          ? Colors.red
                                                          : Colors.white),
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      child: Icon(Icons.edit,
                                                          color: (index % 2 !=
                                                                  0)
                                                              ? Colors.red
                                                              : Colors.white),
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedCategory =
                                                              snapshot
                                                                  .data[index];
                                                        });
                                                        openCategoryDialog();
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: (index % 2 !=
                                                                  0)
                                                              ? Colors.red
                                                              : Colors.white,
                                                        ),
                                                        onTap: () {
                                                          deleteCategory(
                                                              snapshot
                                                                  .data[index]);
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
                                                      .data[index].categoryId),
                                              builder:
                                                  (context, snapshotProduct) {
                                                products = snapshotProduct.data;
                                                return (snapshotProduct
                                                            .connectionState ==
                                                        ConnectionState.active)
                                                    ? (snapshotProduct
                                                                .hasData ==
                                                            true)
                                                        ? (snapshotProduct.data
                                                                    .length >
                                                                0)
                                                            ? ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    snapshotProduct
                                                                        .data
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        indexDishes) {
                                                                  return Card(
                                                                    color: (index %
                                                                                2 !=
                                                                            0)
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .white,
                                                                    child:
                                                                        ListTile(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          _selectedProduct =
                                                                              snapshotProduct.data[indexDishes];
                                                                        });
                                                                        openProductDialog();
                                                                      },
                                                                      title:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                            snapshotProduct.data[indexDishes].productName,
                                                                            style:
                                                                                TextStyle(color: (index % 2 != 0) ? Colors.white : Colors.grey[850]),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      trailing:
                                                                          Column(
                                                                        children: [
                                                                          Text(
                                                                              'Fiyat: ${snapshotProduct.data[indexDishes].productPrice} ${snapshotProduct.data[indexDishes].currency}',
                                                                              style: TextStyle(color: (index % 2 != 0) ? Colors.white : Colors.grey[850])),
                                                                        ],
                                                                      ),
                                                                      subtitle:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 8.0),
                                                                        child: Text(
                                                                            snapshotProduct.data[indexDishes].productDesc,
                                                                            style: TextStyle(color: (index % 2 != 0) ? Colors.white : Colors.grey[850])),
                                                                      ),
                                                                    ),
                                                                  );
                                                                })
                                                            : Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .assignment_late_outlined,
                                                                      size:
                                                                          30.0,
                                                                      color: (index % 2 !=
                                                                              0)
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .white,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              20.0),
                                                                      child:
                                                                          Text(
                                                                        'Henüz kategoriniz için girilmiş bir ürününüz bulunmamaktadır !',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            color: (index % 2 != 0)
                                                                                ? Colors.red
                                                                                : Colors.white,
                                                                            fontSize: 20.0),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                        : Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .assignment_late_outlined,
                                                                  size: 30.0,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          20.0),
                                                                  child: Text(
                                                                    'Henüz kategoriniz için girilmiş bir ürününüz bulunmamaktadır !',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                    : Center(
                                                        child:
                                                            CircularProgressIndicator());
                                              }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_late_outlined,
                                      size: 100.0,
                                      color: Colors.red,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        'Henüz kaydedilmiş bir kategoriniz bulunmamaktadır !',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 25.0, color: Colors.red),
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
                                  color: Colors.red,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    'Henüz kaydedilmiş bir kategoriniz bulunmamaktadır !',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 25.0),
                                  ),
                                ),
                              ],
                            ),
                          )
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      );
              },
            )
          : Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).accentColor,
              ),
            ),
    );
  }
}
