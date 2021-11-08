import 'dart:io';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/image_container.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class ProductSingle extends StatefulWidget {
  final Product productData;
  final String selectedCategoryId;

  const ProductSingle({Key key, this.productData, this.selectedCategoryId})
      : super(key: key);

  @override
  _ProductSingleState createState() => _ProductSingleState();
}

class _ProductSingleState extends State<ProductSingle> {
  GlobalKey<FormState> formKeyProd = GlobalKey<FormState>();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productDesc = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  UserProvider _userProvider;
  bool isLoading = false;
  bool isInit = true;
  bool editBtn = false;
  bool saveBtn = true;
  File productPic;

  saveProduct() {
    if (formKeyProd.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Product product = Product(
          productId: const Uuid().v4(),
          productCatId: widget.selectedCategoryId,
          productDesc: _productDesc.text,
          productName: _productName.text,
          productLocalImage: productPic,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .saveProduct(_userProvider.storeId, product)
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
          productPicRef: widget.productData.productPicRef,
          productName: _productName.text,
          productPrice: int.parse(_productPrice.text));
      FirestoreService()
          .updateProduct(_userProvider.storeId, product)
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
        .removeProduct(_userProvider.storeId, widget.productData.productId,
            widget.productData.productCatId)
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
    });
    if (widget.productData != null &&
        widget.productData.productPicRef != null) {
      widget.productData.productPicRef = null;
    }
  }

  getImage(String type) async {
    setState(() {
      isLoading = true;
    });

    PickedFile image;

    if (type == 'gallery') {
      try {
        image = await ImagePicker()
            .getImage(source: ImageSource.gallery, imageQuality: 30);
      } catch (e) {
        ToastService().showInfo(
            'Galeriye erişemiyoruz, eğer izin vermediyseniz bu işlem için kameraya izin vermelisiniz !',
            context);
      }
    } else if (type == 'photo') {
      try {
        image = await ImagePicker()
            .getImage(source: ImageSource.camera, imageQuality: 30);
      } catch (e) {
        ToastService().showInfo(
            'Kameraya erişemiyoruz, eğer izin vermediyseniz bu işlem için kameraya izin vermelisiniz !',
            context);
      }
    }

    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 2.6),
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Resmi Düzenle',
            toolbarColor: ColorConstants.instance.primaryColor,
            toolbarWidgetColor: ColorConstants.instance.textOnColor,
            statusBarColor: ColorConstants.instance.primaryColor,
            backgroundColor: ColorConstants.instance.textOnColor,
          ));

      setState(() {
        productPic = cropped;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 70.0,
              centerTitle: true,
              title: const TitleWidget(),
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: CustomImageContainer(
                    localImage: productPic,
                    onPressedAdd: (String type) {
                      getImage(type);
                    },
                    onPressedDelete: () {
                      deleteImage();
                    },
                    urlImage: (widget.productData != null)
                        ? widget.productData.productPicRef
                        : null,
                  ),
                ),
                Form(
                  key: formKeyProd,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            " * Ürün adı kataloğunuzdaki veya menünüzde sattığınız ürünün adıdır. Örnek olarak 'Ezogelin', 'Çay', 'Piercing'.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorConstants.instance.hintColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: _productName,
                            maxLength: 50,
                            validator: _validateProdName,
                            decoration: const InputDecoration(
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
                                color: ColorConstants.instance.hintColor,
                                fontWeight: FontWeight.bold,
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
                            decoration: const InputDecoration(
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
                                color: ColorConstants.instance.hintColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: _productPrice,
                            validator: _validateProdPrice,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
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
                                start: ColorConstants.instance.buttonDarkGold,
                                end: ColorConstants.instance.buttonLightColor,
                                buttonText: 'Ürün Oluştur',
                                icon: FontAwesomeIcons.save,
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
                                    start:
                                        ColorConstants.instance.buttonDarkGold,
                                    end: ColorConstants
                                        .instance.buttonLightColor,
                                    buttonText: 'Ürünü Güncelle',
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
                                    start: ColorConstants.instance.primaryColor,
                                    end: ColorConstants.instance.secondaryColor,
                                    buttonText: 'Ürünü Sil',
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
            )))
        : const ProgressWidget();
  }
}
