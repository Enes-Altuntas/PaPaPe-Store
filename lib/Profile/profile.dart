import 'dart:io';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/image_container.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Dashboard/dashboard.dart';
import 'package:papape_store/Map/map.dart';
import 'package:papape_store/Models/store_category.dart';
import 'package:papape_store/Models/store_model.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  StoreProvider _storeProvider;
  List<StoreCategory> storeCats = [];
  Future getUserInfo;
  bool isInit = true;
  bool isLoading = false;
  bool checkBox = false;
  final TextEditingController taxNo = TextEditingController();
  final TextEditingController taxLoc = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController pers1 = TextEditingController();
  final TextEditingController pers2 = TextEditingController();
  final TextEditingController pers3 = TextEditingController();
  final TextEditingController pers1Phone = TextEditingController();
  final TextEditingController pers2Phone = TextEditingController();
  final TextEditingController pers3Phone = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (isInit) {
      _storeProvider = Provider.of<StoreProvider>(context);
      getUserInfo = _getStoreInfo();
      setState(() {
        isInit = false;
      });
    }
  }

  Future _getStoreInfo() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshots = await FirestoreService().getStoreCat();
    for (var element in snapshots.docs) {
      StoreCategory catElement = StoreCategory.fromFirestore(element.data());
      storeCats.add(catElement);
    }

    if (_storeProvider != null) {
      taxNo.text = _storeProvider.storeTaxNo;
      taxLoc.text = _storeProvider.storeTaxLoc;
      name.text = _storeProvider.storeName;
      address.text = _storeProvider.storeAdresss;
      phone.text = _storeProvider.storePhone;
      pers1.text = _storeProvider.pers1;
      pers2.text = _storeProvider.pers2;
      pers3.text = _storeProvider.pers3;
      pers1Phone.text = _storeProvider.pers1Phone;
      pers2Phone.text = _storeProvider.pers2Phone;
      pers3Phone.text = _storeProvider.pers3Phone;
    }

    setState(() {
      isLoading = false;
    });
  }

  saveStore() {
    if (formkey.currentState.validate()) {
      if (_storeProvider.storeLocLat == null ||
          _storeProvider.storeLocLong == null) {
        ToastService().showInfo('Lütfen konum seçiniz !', context);
        return;
      }
      if (_storeProvider.storeCategory == null) {
        ToastService().showInfo('Lütfen işletme kategorisi seçiniz !', context);
        return;
      }
      setState(() {
        isLoading = true;
      });

      FirestoreService()
          .saveStore(_storeProvider.getStoreFromProvider())
          .then((value) {
            ToastService().showSuccess(value, context);
            FirestoreService().getStore().then((value) {
              if (value != null && value.data() != null) {
                _storeProvider.loadStoreInfo(Store.fromFirestore(value.data()));
              }
            });
          })
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
                _storeProvider.changeChanged(false);
              }));
    } else {
      ToastService()
          .showError('Geçersiz girişleriniz bulunmaktadır !', context);
    }
  }

  getLocation() {
    setState(() {
      isLoading = true;
    });
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((value) {
          _storeProvider.changeCurLocLat(value.latitude);
          _storeProvider.changeCurLocLong(value.longitude);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
          );
        })
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
  }

  getImageAndUpload(String type) async {
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
            toolbarWidgetColor: ColorConstants.instance.whiteContainer,
            toolbarColor: ColorConstants.instance.primaryColor,
            statusBarColor: ColorConstants.instance.primaryColor,
            backgroundColor: ColorConstants.instance.whiteContainer,
          ));

      if (cropped != null) {
        _storeProvider.changeStoreLocalImagePath(cropped);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  deleteImage() {
    if (_storeProvider != null) {
      _storeProvider.changeStoreLocalImagePath(null);
      _storeProvider.changeStorePicRef(null);
    }
  }

  checkTaxNo(String value) {
    var p = [];
    int i;
    for (i = 0; i <= 8; i++) {
      p.add((int.parse(value[i]) + 10 - (i + 1)) % 10);
    }
    var q = [];
    int j;
    for (j = 0; j <= 8; j++) {
      if (p[j] == 9) {
        q.add(p[j]);
      } else {
        q.add((p[j] * pow(2, (10 - (j + 1)))) % 9);
      }
    }
    var res = 0;
    for (var element in q) {
      res = res + element;
    }
    if ((10 - (res % 10)) % 10 != int.parse(value[9])) {
      return "* Geçerli bir vergi numarası giriniz !";
    }
    return null;
  }

  String validateTaxNo(String value) {
    if (value.isEmpty) {
      return "* Vergi numarası zorunludur !";
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return "* Sadece rakam içermelidir !";
    }
    if (value.length != 10) {
      return "* 10 karakter içermelidir !";
    }
    String msg = checkTaxNo(value);
    if (msg != null) {
      return msg;
    }
    return null;
  }

  String validateTaxLoc(String value) {
    if (value.isEmpty) {
      return "* Vergi dairesi zorunludur !";
    }
    if (value.contains(RegExp(r'\d')) == true) {
      return "* Rakam içeremez !";
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ]')) != true) {
      return "* Harf içermelidir !";
    }

    return null;
  }

  String validateName(value) {
    if (value.isEmpty) {
      return "* İşletme ismi zorunludur !";
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ]')) != true) {
      return "* Harf içermelidir !";
    }

    return null;
  }

  String validatePhone(value) {
    if (value.isEmpty) {
      return "* İşletme telefon numarası zorunludur !";
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return "* Geçersiz telefon numarası !";
    }
    if (value.length != 10) {
      return "* 10 karakter içermelidir !";
    }

    return null;
  }

  String validateAddress(String value) {
    if (value.isEmpty) {
      return "* İşletme adresi zorunludur !";
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ]')) != true) {
      return "* Harf içermelidir !";
    }

    return null;
  }

  String validatePersName(String value) {
    if (value.isEmpty) {
      return "* En az bir ilgili kişi ismi ve soyismi zorunludur !";
    }
    if (value.contains(RegExp(r'[^a-zA-ZğüşöçİĞÜŞÖÇ\s]')) == true) {
      return "* Yalnızca harf içermelidir !";
    }

    return null;
  }

  String validatePersPhone(value) {
    if (value.isEmpty) {
      return "* En az bir ilgili kişi telefon numarası zorunludur !";
    }
    if (value.contains(RegExp(r'[^\d]')) == true) {
      return "* Geçersiz telefon numarası !";
    }
    if (value.length != 10) {
      return "* 10 karakter içermelidir !";
    }

    return null;
  }

  selectCategory() {
    for (var element in storeCats) {
      if (_storeProvider.storeCategory != null &&
          _storeProvider.storeCategory.contains(element.storeCatName)) {
        element.checked = true;
      } else {
        element.checked = false;
      }
    }
    showDialog(
        context: context,
        builder: (context) {
          return CategoryDialog(
              storeCats: storeCats, selectedCats: _storeProvider.storeCategory);
        });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            floatingActionButton: FloatingActionButton.extended(
                foregroundColor: ColorConstants.instance.textOnColor,
                backgroundColor: ColorConstants.instance.textGold,
                onPressed: () {
                  saveStore();
                },
                label: Row(
                  children: const [
                    Icon(Icons.save),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Kaydet'),
                    ),
                  ],
                )),
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: ColorConstants.instance.iconOnColor,
                ),
                onPressed: () {
                  if (_storeProvider.changed == false) {
                    _storeProvider.changeChanged(false);
                    _storeProvider.changeStoreLocalImagePath(null);
                    Navigator.of(context).pop();
                  } else {
                    CoolAlert.show(
                        context: context,
                        type: CoolAlertType.warning,
                        title: 'Değişiklik',
                        text:
                            'Değiştirdiğiniz bilgiler bulunmaktadır kaydetmeden çıkmak istediğinize emin misiniz ?',
                        showCancelBtn: true,
                        backgroundColor: ColorConstants.instance.primaryColor,
                        confirmBtnColor: ColorConstants.instance.primaryColor,
                        cancelBtnText: 'Hayır',
                        onCancelBtnTap: () {
                          Navigator.of(context).pop();
                        },
                        onConfirmBtnTap: () {
                          _storeProvider.changeChanged(false);
                          _storeProvider.changeStoreLocalImagePath(null);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Dashboard(
                                    defPage: 0,
                                  )));
                        },
                        barrierDismissible: false,
                        confirmBtnText: 'Evet');
                  }
                },
              ),
              title: const TitleWidget(),
            ),
            body: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomImageContainer(
                        localImage: _storeProvider.storeLocalImagePath,
                        urlImage: _storeProvider.storePicRef,
                        onPressedAdd: (String type) {
                          getImageAndUpload(type);
                          _storeProvider.changeChanged(true);
                        },
                        onPressedDelete: () {
                          deleteImage();
                          _storeProvider.changeChanged(true);
                        },
                      ),
                    ),
                    GradientButton(
                        start: ColorConstants.instance.primaryColor,
                        end: ColorConstants.instance.secondaryColor,
                        buttonText: 'Konum Al',
                        icon: Icons.add_location_alt_outlined,
                        widthMultiplier: 0.9,
                        fontSize: 15,
                        onPressed: () {
                          _storeProvider.changeChanged(true);
                          getLocation();
                        }),
                    Padding(
                        padding: const EdgeInsets.only(top: 7.0, bottom: 7.0),
                        child: GradientButton(
                          start: ColorConstants.instance.primaryColor,
                          end: ColorConstants.instance.secondaryColor,
                          buttonText: 'Kategori Ekle',
                          fontSize: 15,
                          icon: Icons.add,
                          onPressed: () {
                            selectCategory();
                          },
                          widthMultiplier: 0.9,
                        )),
                    Form(
                      key: formkey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: TextFormField(
                                controller: taxNo,
                                validator: validateTaxNo,
                                onChanged: (value) {
                                  validateTaxNo(value);
                                  _storeProvider.changeStoreTaxNo(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.attach_money),
                                    labelText: 'İşletme Vergi Numarası',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                controller: taxLoc,
                                validator: validateTaxLoc,
                                onChanged: (value) {
                                  _storeProvider.changeStoreTaxLoc(value);
                                  _storeProvider.changeChanged(true);
                                },
                                maxLength: 25,
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.account_balance),
                                    border: OutlineInputBorder(),
                                    labelText: 'İşletme Vergi Dairesi'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                controller: name,
                                validator: validateName,
                                onChanged: (value) {
                                  _storeProvider.changeStoreName(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                decoration: const InputDecoration(
                                    labelText: 'İşletme İsmi',
                                    icon: Icon(Icons.announcement_sharp),
                                    border: OutlineInputBorder()),
                                maxLength: 50,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                validator: validateAddress,
                                onChanged: (value) {
                                  _storeProvider.changeStoreAddress(value);
                                  _storeProvider.changeChanged(true);
                                },
                                controller: address,
                                maxLength: 255,
                                maxLines: 3,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                decoration: const InputDecoration(
                                    labelText: 'İşletme Adresi',
                                    icon: Icon(Icons.add_location_rounded),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                validator: validatePhone,
                                controller: phone,
                                onChanged: (value) {
                                  _storeProvider.changeStorePhone(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    labelText: 'İşletme Telefon Numarası',
                                    prefix: Text('+90'),
                                    icon: Icon(Icons.phone),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                validator: validatePersName,
                                controller: pers1,
                                onChanged: (value) {
                                  _storeProvider.changePers1(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: 50,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi isim-soyisim (1)',
                                    icon: Icon(Icons.account_circle_outlined),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                validator: validatePersPhone,
                                controller: pers1Phone,
                                onChanged: (value) {
                                  _storeProvider.changePers1Phone(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi telefon (1)',
                                    prefix: Text('+90'),
                                    icon: Icon(Icons.phone),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                controller: pers2,
                                onChanged: (value) {
                                  _storeProvider.changePers2(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: 50,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi isim-soyisim (2)',
                                    icon: Icon(Icons.account_circle_outlined),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                controller: pers2Phone,
                                onChanged: (value) {
                                  _storeProvider.changePers2Phone(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi telefon (2)',
                                    prefix: Text('+90'),
                                    icon: Icon(Icons.phone),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextFormField(
                                controller: pers3,
                                onChanged: (value) {
                                  _storeProvider.changePers3(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: 50,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi isim-soyisim (3)',
                                    icon: Icon(Icons.account_circle_outlined),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: TextFormField(
                                controller: pers3Phone,
                                onChanged: (value) {
                                  _storeProvider.changePers3Phone(value);
                                  _storeProvider.changeChanged(true);
                                },
                                style: TextStyle(
                                  color: ColorConstants.instance.hintColor,
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    labelText: 'İlgili kişi telefon (3)',
                                    prefix: Text('+90'),
                                    icon: Icon(Icons.phone),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        : const ProgressWidget();
  }
}

class CategoryDialog extends StatefulWidget {
  final List<StoreCategory> storeCats;
  final List selectedCats;

  const CategoryDialog({Key key, this.storeCats, this.selectedCats})
      : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  StoreProvider _storeProvider;

  @override
  Widget build(BuildContext context) {
    _storeProvider = Provider.of<StoreProvider>(context);
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        child: ListView.builder(
            itemCount: widget.storeCats.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Checkbox(
                  value: widget.storeCats[index].checked,
                  activeColor: ColorConstants.instance.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      widget.storeCats[index].checked = value;
                    });
                    if (value == true) {
                      _storeProvider.changeAddStoreCategory(
                          widget.storeCats[index].storeCatName);
                    } else {
                      _storeProvider.changeRemoveStoreCategory(
                          widget.storeCats[index].storeCatName);
                    }
                    _storeProvider.changeChanged(true);
                  },
                ),
                title: Text(widget.storeCats[index].storeCatName),
              );
            }),
      ),
    );
  }
}
