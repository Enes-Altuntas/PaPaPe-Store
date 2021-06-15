import 'dart:io';
import 'package:bulovva_store/Models/product_category_model.dart';
import 'package:bulovva_store/Models/product_model.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ProductSingle extends StatefulWidget {
  final Product productData;
  final String selectedCategory;
  final List<ProductCategory> category;

  ProductSingle(
      {Key key, this.productData, this.selectedCategory, this.category})
      : super(key: key);

  @override
  _ProductSingleState createState() => _ProductSingleState();
}

class _ProductSingleState extends State<ProductSingle> {
  GlobalKey<FormState> formKeyProd = GlobalKey<FormState>();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productDesc = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  String _selectedCur;
  String _selectedCat;
  String _selectedCatId;
  bool isLoading = false;
  bool isInit = true;
  bool picBtn = false;
  bool editBtn = false;
  bool saveBtn = true;
  File productPic;
  bool picDeleted = false;

  saveProduct() {
    if (_selectedCur == null) {
      ToastService()
          .showInfo('Ürün eklerken para birimi seçilmesi zorunludur', context);
      return;
    }
    if (_selectedCatId == null) {
      ToastService()
          .showInfo('Ürün eklerken kategori seçilmesi zorunludur', context);
      return;
    }
    if (formKeyProd.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Product product = Product(
          productId: Uuid().v4(),
          currency: _selectedCur,
          productCatId: _selectedCatId,
          productDesc: _productDesc.text,
          productName: _productName.text,
          productLocalImage: productPic,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .saveProduct(product)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
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
        isLoading = true;
      });
      Product product = Product(
          productId: widget.productData.productId,
          currency: _selectedCur,
          productCatId: (_selectedCatId != null)
              ? _selectedCatId
              : widget.productData.productCatId,
          productDesc: _productDesc.text,
          productLocalImage: productPic,
          productPicRef: (picDeleted) ? null : widget.productData.productPicRef,
          productName: _productName.text,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .updateProduct(product)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    }
  }

  removeProduct() {
    setState(() {
      isLoading = true;
    });
    FirestoreService()
        .removeProduct(
            widget.productData.productId, widget.productData.productCatId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  deleteProdYesNo() {
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

  updateYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Ürünü güncellemek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          updateProduct();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  saveYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Ürünü kaydetmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          saveProduct()();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
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

  String _validateProdPrice(String value) {
    if (value.isEmpty) {
      return '* Ürün fiyatı boş olmamalıdır !';
    }

    if (value.contains(RegExp(r'[^\d.]')) == true) {
      return '* Yalnızca rakam içermelidir !';
    }

    return null;
  }

  deleteImage() {
    setState(() {
      productPic = null;
      picDeleted = true;
    });
    if (widget.productData != null &&
        widget.productData.productPicRef != null) {
      widget.productData.productPicRef = null;
    }
  }

  getImage() async {
    setState(() {
      isLoading = true;
    });
    await Permission.photos.request();
    PermissionStatus permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      PickedFile image =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (image != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 2.5),
            compressQuality: 100,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Resmi Düzenle',
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: Colors.white,
                statusBarColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white));

        setState(() {
          productPic = cropped;
          picDeleted = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      if (widget.productData != null) {
        setState(() {
          _selectedCat = widget.selectedCategory;
          _productDesc.text = widget.productData.productDesc;
          _productName.text = widget.productData.productName;
          _productPrice.text = widget.productData.productPrice.toString();
          _selectedCur = widget.productData.currency;
          _selectedCatId = widget.productData.productCatId;
          isInit = false;
          editBtn = true;
          saveBtn = false;
        });
      }
    }
    if ((widget.productData != null &&
            (widget.productData.productLocalImage != null ||
                widget.productData.productPicRef != null)) ||
        productPic != null) {
      setState(() {
        picBtn = true;
      });
    } else {
      setState(() {
        picBtn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: (isLoading == false)
          ? Container(
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        (productPic != null)
                            ? Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.5,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(35.0),
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.red[600],
                                                Colors.purple[500]
                                              ],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft)),
                                      child: Image.file(productPic,
                                          fit: BoxFit.fitWidth),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              getImage();
                                            },
                                            child: Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.red[600],
                                                          Colors.purple[500]
                                                        ],
                                                        begin: Alignment
                                                            .centerRight,
                                                        end: Alignment
                                                            .centerLeft)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Colors.white),
                                                  ],
                                                ))),
                                        TextButton(
                                            onPressed: () {
                                              deleteImage();
                                            },
                                            child: Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.red[600],
                                                          Colors.purple[500]
                                                        ],
                                                        begin: Alignment
                                                            .centerRight,
                                                        end: Alignment
                                                            .centerLeft)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.white),
                                                  ],
                                                ))),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : (widget.productData != null &&
                                    widget.productData.productPicRef != null)
                                ? Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      children: [
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3.5,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(35.0),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red[600],
                                                    Colors.purple[500]
                                                  ],
                                                  begin: Alignment.centerRight,
                                                  end: Alignment.centerLeft)),
                                          child: Image.network(
                                              widget.productData.productPicRef,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                            return loadingProgress == null
                                                ? child
                                                : Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  );
                                          }, fit: BoxFit.fitWidth),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Visibility(
                                              visible: picBtn,
                                              child: TextButton(
                                                  onPressed: () {
                                                    getImage();
                                                  },
                                                  child: Container(
                                                      height: 50.0,
                                                      width: 50.0,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.0),
                                                          gradient: LinearGradient(
                                                              colors: [
                                                                Colors.red[600],
                                                                Colors
                                                                    .purple[500]
                                                              ],
                                                              begin: Alignment
                                                                  .centerRight,
                                                              end: Alignment
                                                                  .centerLeft)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.edit,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ))),
                                            ),
                                            Visibility(
                                              visible: picBtn,
                                              child: TextButton(
                                                  onPressed: () {
                                                    deleteImage();
                                                  },
                                                  child: Container(
                                                      height: 50.0,
                                                      width: 50.0,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.0),
                                                          gradient: LinearGradient(
                                                              colors: [
                                                                Colors.red[600],
                                                                Colors
                                                                    .purple[500]
                                                              ],
                                                              begin: Alignment
                                                                  .centerRight,
                                                              end: Alignment
                                                                  .centerLeft)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.delete,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ))),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: InkWell(
                                      onTap: getImage,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3.5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(35.0),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[600],
                                                  Colors.purple[500]
                                                ],
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20.0),
                                              child: Icon(
                                                Icons.upload_file,
                                                color: Colors.white,
                                                size: 50.0,
                                              ),
                                            ),
                                            Text(
                                              'Resim Ekle',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Bebas',
                                                  fontSize: 20.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                        Form(
                          key: formKeyProd,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: DropdownButton(
                                          isExpanded: true,
                                          value: _selectedCat,
                                          hint: Text(
                                              "Ürün için kategori seçiniz !"),
                                          items: widget.category
                                              .map((ProductCategory category) {
                                            return new DropdownMenuItem<String>(
                                              value: category.categoryName,
                                              onTap: () {
                                                _selectedCatId =
                                                    category.categoryId;
                                              },
                                              child: new Text(
                                                  category.categoryName),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCat = value;
                                            });
                                          }),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: TextFormField(
                                    controller: _productName,
                                    maxLength: 50,
                                    validator: _validateProdName,
                                    decoration: InputDecoration(
                                        labelText: 'Ürün Adı',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: TextFormField(
                                    controller: _productDesc,
                                    keyboardType: TextInputType.text,
                                    maxLength: 255,
                                    maxLines: 5,
                                    // validator: _validateProdDesc,
                                    decoration: InputDecoration(
                                        labelText: 'Ürün Tanımı',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
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
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
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
                                Visibility(
                                  visible: saveBtn,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, bottom: 20.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.red[600],
                                                Colors.purple[500]
                                              ],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft)),
                                      child: TextButton(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.save,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text("Ürün Oluştur".toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontFamily: 'Bebas')),
                                            ],
                                          ),
                                          onPressed: () {
                                            saveYesNo();
                                          }),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: editBtn,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, bottom: 5.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red[600],
                                                    Colors.purple[500]
                                                  ],
                                                  begin: Alignment.centerRight,
                                                  end: Alignment.centerLeft)),
                                          child: TextButton(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                      "Ürün Düzenle"
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white,
                                                          fontFamily: 'Bebas')),
                                                ],
                                              ),
                                              onPressed: () {
                                                updateYesNo();
                                              }),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 20.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red[600],
                                                    Colors.purple[500]
                                                  ],
                                                  begin: Alignment.centerRight,
                                                  end: Alignment.centerLeft)),
                                          child: TextButton(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                      "Ürünü Sil".toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white,
                                                          fontFamily: 'Bebas')),
                                                ],
                                              ),
                                              onPressed: () {
                                                deleteProdYesNo();
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
    );
  }
}
