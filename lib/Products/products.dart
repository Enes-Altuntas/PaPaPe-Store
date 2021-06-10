import 'package:bulovva_store/Models/product_category_model.dart';
import 'package:bulovva_store/Models/product_model.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  StoreProvider _storeProvider;
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

  GlobalKey<FormState> formKeyCat = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyProd = GlobalKey<FormState>();

  String _validateCatRow(String value) {
    if (value.isEmpty) {
      return '* Kategori sırası boş olmamalıdır !';
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return '* Yalnızca rakam içerebilir !';
    }

    return null;
  }

  String _validateCatName(String value) {
    if (value.isEmpty) {
      return '* Kategori adı boş olmamalıdır !';
    }

    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
      return '* Harf veya rakam içermelidir !';
    }

    return null;
  }

  String _validateProdName(String value) {
    if (value.isEmpty) {
      return '* Ürün adı boş olmamalıdır !';
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
      return '* Harf veya rakam içermelidir !';
    }

    return null;
  }

  // String _validateProdDesc(String value) {
  //   if (value.isEmpty) {
  //     return '* Ürün tanımı boş olmamalıdır !';
  //   }

  //   if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
  //     return '* Harf veya rakam içermelidir !';
  //   }

  //   return null;
  // }

  String _validateProdPrice(String value) {
    if (value.isEmpty) {
      return '* Ürün fiyatı boş olmamalıdır !';
    }

    if (value.contains(RegExp(r'[^\d.]')) == true) {
      return '* Yalnızca rakam içermelidir !';
    }

    return null;
  }

  openCategoryDialog() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kategori eklemeden önce işletme bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    if (_selectedCategory != null) {
      setState(() {
        _categoryRow.text = _selectedCategory.categoryRow.toString();
        _categoryName.text = _selectedCategory.categoryName;
      });
    }
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (_selectedCategory == null)
                    ? Text('Kategori Ekle')
                    : Text('Kategori Düzenle'),
                GestureDetector(
                  child: Icon(Icons.cancel_outlined, color: Colors.grey),
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
              child: Form(
                key: formKeyCat,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          controller: _categoryRow,
                          validator: _validateCatRow,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Kategori Sırası',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: TextFormField(
                          validator: _validateCatName,
                          controller: _categoryName,
                          decoration: InputDecoration(
                              labelText: 'Kategori Adı',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      (_selectedCategory == null)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                width: MediaQuery.of(_context).size.width,
                                child: TextButton(
                                    onPressed: () {
                                      saveCategory();
                                    },
                                    child: Text(
                                      'Kategori Ekle',
                                      style:
                                          TextStyle(color: Colors.green[900]),
                                    ),
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(15)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green[900]),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                side: BorderSide(
                                                    width: 2,
                                                    color: Colors.green[900]))))),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                width: MediaQuery.of(_context).size.width,
                                child: TextButton(
                                    onPressed: () {
                                      updateCategory();
                                    },
                                    child: Text(
                                      'Kategori Düzenle',
                                      style:
                                          TextStyle(color: Colors.green[900]),
                                    ),
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(15)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green[900]),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                side: BorderSide(
                                                    width: 2,
                                                    color: Colors.green[900]))))),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  openProductDialog() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Ürün eklemeden önce işletme bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
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
          barrierDismissible: false,
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
                          color: Colors.grey,
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
                    child: Form(
                      key: formKeyProd,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: SizedBox(
                                  width: MediaQuery.of(_context).size.width,
                                  child: DropdownButton(
                                      isExpanded: true,
                                      value: _selectedCat,
                                      hint:
                                          Text("Ürün için kategori seçiniz !"),
                                      items: category
                                          .map((ProductCategory category) {
                                        return new DropdownMenuItem<String>(
                                          value: category.categoryName,
                                          onTap: () {
                                            _selectedCatId =
                                                category.categoryId;
                                          },
                                          child:
                                              new Text(category.categoryName),
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
                                validator: _validateProdName,
                                decoration: InputDecoration(
                                    labelText: 'Ürün Adı',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: TextFormField(
                                controller: _productDesc,
                                maxLines: 3,
                                // validator: _validateProdDesc,
                                decoration: InputDecoration(
                                    labelText: 'Ürün Tanımı',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: TextFormField(
                                controller: _productPrice,
                                validator: _validateProdPrice,
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
                                      isExpanded: true,
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
                            (_selectedProduct == null)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(_context).size.width,
                                      child: TextButton(
                                          onPressed: () {
                                            saveProduct();
                                          },
                                          child: Text(
                                            'Ürün Ekle',
                                            style: TextStyle(
                                                color: Colors.green[900]),
                                          ),
                                          style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all<EdgeInsets>(
                                                      EdgeInsets.all(15)),
                                              foregroundColor:
                                                  MaterialStateProperty.all<Color>(
                                                      Colors.green[900]),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      side: BorderSide(
                                                          width: 2,
                                                          color: Colors.green[900]))))),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(_context)
                                              .size
                                              .width,
                                          child: TextButton(
                                              onPressed: () {
                                                updateProduct();
                                              },
                                              child: Text(
                                                'Ürün Düzenle',
                                                style: TextStyle(
                                                    color: Colors.green[900]),
                                              ),
                                              style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsets>(
                                                          EdgeInsets.all(15)),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<Color>(
                                                          Colors.green[900]),
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(50.0),
                                                          side: BorderSide(width: 2, color: Colors.green[900]))))),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(_context)
                                              .size
                                              .width,
                                          child: TextButton(
                                              onPressed: () {
                                                deleteProdYesNo(_context);
                                              },
                                              child: Text(
                                                'Ürün Sil',
                                                style: TextStyle(
                                                    color: Colors.red[900]),
                                              ),
                                              style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsets>(
                                                          EdgeInsets.all(15)),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<Color>(
                                                          Colors.red[900]),
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(50.0),
                                                          side: BorderSide(width: 2, color: Colors.red[900]))))),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
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
    if (formKeyCat.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
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
              }));
      setState(() {
        _categoryName.text = '';
        _categoryRow.text = '';
        _selectedCategory = null;
      });
      Navigator.of(context).pop();
    }
  }

  updateCategory() {
    setState(() {
      _isLoading = true;
    });
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
            }));
    setState(() {
      _categoryName.text = '';
      _categoryRow.text = '';
      _selectedCategory = null;
    });
    Navigator.of(context).pop();
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

  saveProduct() {
    if (_selectedCur == null) {
      ToastService()
          .showInfo('Ürün eklerken para birimi seçilmesi zorunludur', context);
      return;
    }
    if (_selectedCat == null) {
      ToastService()
          .showInfo('Ürün eklerken kategori seçilmesi zorunludur', context);
      return;
    }
    if (formKeyProd.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
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
      setState(() {
        _productDesc.text = '';
        _productName.text = '';
        _productPrice.text = '';
        _selectedCur = null;
        _selectedCat = null;
        _selectedCatId = null;
        _selectedProduct = null;
      });
      Navigator.of(context).pop();
    }
  }

  updateProduct() {
    if (_selectedCur == null) {
      ToastService()
          .showInfo('Ürün eklerken para birimi seçilmesi zorunludur', context);
      return;
    }
    if (_selectedCat == null) {
      ToastService()
          .showInfo('Ürün eklerken kategori seçilmesi zorunludur', context);
      return;
    }
    if (formKeyProd.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
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
      setState(() {
        _productDesc.text = '';
        _productName.text = '';
        _productPrice.text = '';
        _selectedCur = null;
        _selectedCat = null;
        _selectedCatId = null;
        _selectedProduct = null;
      });
      Navigator.of(context).pop();
    }
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
    setState(() {
      _productDesc.text = '';
      _productName.text = '';
      _productPrice.text = '';
      _selectedCur = null;
      _selectedCat = null;
      _selectedCatId = null;
      _selectedProduct = null;
    });
    Navigator.of(context).pop();
  }

  deleteProdYesNo(BuildContext _context) {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Ürünü silmek istediğinize emin misiniz ?',
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        showCancelBtn: true,
        cancelBtnText: 'Hayır',
        barrierDismissible: false,
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          removeProduct();
        },
        confirmBtnText: 'Evet');
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading == false)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                      child: Text("Yeni Kategori Oluştur".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                      child: Text("Yeni Ürün Oluştur".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
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
                        openProductDialog();
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
                                                                  .primaryColor,
                                                            ),
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
                                                        ? (snapshotProduct
                                                                    .hasData ==
                                                                true)
                                                            ? (snapshotProduct
                                                                        .data
                                                                        .length >
                                                                    0)
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10.0),
                                                                    child: ListView.builder(
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
                                                                              color: Colors.white,
                                                                              child: ListTile(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    _selectedProduct = snapshotProduct.data[indexDishes];
                                                                                  });
                                                                                  openProductDialog();
                                                                                },
                                                                                title: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      snapshotProduct.data[indexDishes].productName,
                                                                                      style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 16.0),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                trailing: Column(
                                                                                  children: [],
                                                                                ),
                                                                                subtitle: Padding(
                                                                                  padding: const EdgeInsets.only(top: 8.0),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(snapshotProduct.data[indexDishes].productDesc, style: TextStyle(color: Theme.of(context).hintColor)),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                        child: Text(
                                                                                          'Fiyat: ${snapshotProduct.data[indexDishes].productPrice} ${snapshotProduct.data[indexDishes].currency}',
                                                                                          style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 15.0),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                  )
                                                                : Center(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .assignment_late_outlined,
                                                                          size:
                                                                              30.0,
                                                                          color: (index % 2 != 0)
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 20.0),
                                                                          child:
                                                                              Text(
                                                                            'Henüz kategoriniz için girilmiş bir ürününüz bulunmamaktadır !',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(color: (index % 2 != 0) ? Theme.of(context).primaryColor : Colors.white, fontSize: 20.0),
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
                                                                      size:
                                                                          30.0,
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
                                                                            fontSize:
                                                                                15.0),
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
                              backgroundColor: Colors.white,
                            ),
                          );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
  }
}
