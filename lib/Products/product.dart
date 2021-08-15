import 'dart:io';
import 'package:bulb/Components/gradient_button.dart';
import 'package:bulb/Components/image_container.dart';
import 'package:bulb/Models/product_model.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ProductSingle extends StatefulWidget {
  final Product productData;
  final String selectedCategoryId;

  ProductSingle({Key key, this.productData, this.selectedCategoryId})
      : super(key: key);

  @override
  _ProductSingleState createState() => _ProductSingleState();
}

class _ProductSingleState extends State<ProductSingle> {
  GlobalKey<FormState> formKeyProd = GlobalKey<FormState>();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productDesc = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  bool isLoading = false;
  bool isInit = true;
  bool picBtn = false;
  bool editBtn = false;
  bool saveBtn = true;
  File productPic;
  bool picDeleted = false;

  saveProduct() {
    if (formKeyProd.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Product product = Product(
          productId: Uuid().v4(),
          productCatId: widget.selectedCategoryId,
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
                _productDesc.text = '';
                _productName.text = '';
                _productPrice.text = '';
                productPic = null;
              }));
    }
  }

  updateProduct() {
    if (formKeyProd.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Product product = Product(
          productId: widget.productData.productId,
          productCatId: widget.selectedCategoryId,
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
          saveProduct();
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
            aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 2.6),
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
          _productDesc.text = widget.productData.productDesc;
          _productName.text = widget.productData.productName;
          _productPrice.text = widget.productData.productPrice.toString();
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
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text('bulb',
            style: TextStyle(
                fontSize: 45.0,
                color: Colors.white,
                fontFamily: 'Armatic',
                fontWeight: FontWeight.bold)),
      ),
      body: (isLoading == false)
          ? Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
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
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CustomImageContainer(
                            addText: 'Resim Ekle',
                            addable: true,
                            buttonVis: picBtn,
                            localImage: productPic,
                            onPressedAdd: () {
                              getImage();
                            },
                            onPressedDelete: () {
                              deleteImage();
                            },
                            onPressedEdit: () {
                              getImage();
                            },
                            urlImage: (widget.productData != null)
                                ? widget.productData.productPicRef
                                : null,
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
                                  child: Text(
                                    " * Ürün adı kataloğunuzdaki veya menünüzde sattığınız ürünün adıdır. Örnek olarak 'Ezogelin', 'Çay', 'Piercing'.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
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
                                  child: Text(
                                    " * Ürün adı kataloğunuzdaki veya menünüzde sattığınız ürünün tanımıdır. Ürününüzü açıklamanız faydalı olacaktır.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
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
                                  child: Text(
                                    " * Ürün adı kataloğunuzdaki veya menünüzde sattığınız ürünün fiyatıdır. İşletmenizde kullandığınız menü veya katalogdaki fiyatların aynılarını girmeniz, işletmeniz adına yarar sağlayacaktır.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextFormField(
                                    controller: _productPrice,
                                    validator: _validateProdPrice,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Ürün Fiyatı',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Visibility(
                                  visible: saveBtn,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0, bottom: 60.0),
                                      child: GradientButton(
                                        buttonText: 'Ürün Oluştur',
                                        icon: FontAwesomeIcons.save,
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        onPressed: () {
                                          saveYesNo();
                                        },
                                        widthMultiplier: 0.9,
                                      )),
                                ),
                                Visibility(
                                  visible: editBtn,
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0, bottom: 5.0),
                                          child: GradientButton(
                                            buttonText: 'Ürünü Güncelle',
                                            fontFamily: 'Roboto',
                                            fontSize: 15,
                                            icon: FontAwesomeIcons.save,
                                            onPressed: () {
                                              updateYesNo();
                                            },
                                            widthMultiplier: 0.9,
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, bottom: 20.0),
                                          child: GradientButton(
                                            buttonText: 'Ürünü Sil',
                                            fontFamily: 'Roboto',
                                            fontSize: 15,
                                            icon: FontAwesomeIcons.trash,
                                            onPressed: () {
                                              deleteProdYesNo();
                                            },
                                            widthMultiplier: 0.9,
                                          )),
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
                color: Colors.white,
              ),
            ),
    );
  }
}
