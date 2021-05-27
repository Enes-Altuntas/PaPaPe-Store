import 'dart:io';
import 'package:bulovva_store/Map/map.dart';
import 'package:bulovva_store/Models/store_alt_category_model.dart';
import 'package:bulovva_store/Models/store_category.dart';
import 'package:bulovva_store/Models/store_model.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  StoreProvider _storeProvider;
  List<StoreCategory> storeCats = [];
  List<StoreAltCategory> storeAltCats = [];
  String _selectedCat;
  String _selectedAltCat;
  Future getUserInfo;
  bool isInit = true;
  bool isLoading = false;
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
    if (isInit) {
      _storeProvider = Provider.of<StoreProvider>(context);
      getUserInfo = _getStoreInfo();
      setState(() {
        isInit = false;
      });
    }
    super.didChangeDependencies();
  }

  Future _getStoreInfo() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshots = await FirestoreService().getStoreCat();
    snapshots.docs.forEach((element) {
      StoreCategory catElement = StoreCategory.fromFirestore(element.data());
      storeCats.add(catElement);
    });

    if (_storeProvider != null) {
      _selectedCat = _storeProvider.storeCategory;
      selectCategory(_selectedCat);
      if (_storeProvider.storeAltCategory != null &&
          _storeProvider.storeAltCategory.isNotEmpty) {
        _selectedAltCat = _storeProvider.storeAltCategory;
      }
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
  }

  saveStore() {
    if (formkey.currentState.validate()) {
      if (_storeProvider.storeLocalImagePath == null &&
          _storeProvider.storePicRef == null) {
        ToastService().showInfo('Lütfen bir resim seçiniz !', context);
        return;
      }
      if (_storeProvider.storeLocLat == null ||
          _storeProvider.storeLocLong == null) {
        ToastService().showInfo('Lütfen konum seçiniz !', context);
        return;
      }
      if (_storeProvider.storeCategory == null) {
        ToastService().showInfo('Lütfen işletme kategorisi seçiniz !', context);
        return;
      }
      if (_selectedAltCat == null && storeAltCats.length > 0) {
        ToastService()
            .showInfo('Lütfen işletme alt kategorisi seçiniz !', context);
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
            MaterialPageRoute(builder: (context) => Maps()),
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

  selectCategory(String value) async {
    setState(() {
      isLoading = true;
      _selectedAltCat = null;
      storeAltCats = [];
    });

    int index =
        storeCats.indexWhere((element) => element.storeCatName == value);

    QuerySnapshot snapshots =
        await FirestoreService().getStoreAltCat(storeCats[index].storeCatId);

    if (snapshots.docs.isNotEmpty) {
      snapshots.docs.forEach((element) {
        StoreAltCategory altCatElement =
            StoreAltCategory.fromFirestore(element.data());
        storeAltCats.add(altCatElement);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  getImageAndUpload() async {
    setState(() {
      isLoading = true;
    });
    final _picker = ImagePicker();
    PickedFile image;
    await Permission.photos.request();
    PermissionStatus permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      image = await _picker
          .getImage(source: ImageSource.gallery)
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
      File file = File(image.path);
      if (image != null) {
        _storeProvider.changeStoreLocalImagePath(file);
      }
    }
  }

  checkTaxNo(String value) {
    var p = [];
    var i;
    for (i = 0; i <= 8; i++) {
      p.add((int.parse(value[i]) + 10 - (i + 1)) % 10);
    }
    var q = [];
    var j;
    for (j = 0; j <= 8; j++) {
      if (p[j] == 9) {
        q.add(p[j]);
      } else {
        q.add((p[j] * pow(2, (10 - (j + 1)))) % 9);
      }
    }
    var res = 0;
    q.forEach((element) {
      res = res + element;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          label: (_storeProvider.storeId == null)
              ? Text(
                  'Kaydet',
                  style: TextStyle(color: Colors.white),
                )
              : Text(
                  'Güncelle',
                  style: TextStyle(color: Colors.white),
                ),
          icon: Icon(
            Icons.save,
            color: Colors.white,
          ),
          onPressed: () {
            saveStore();
          },
        ),
        body: (isLoading == false)
            ? SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Form(
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
                          children: [
                            (_storeProvider.storeLocalImagePath != null)
                                ? SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    width: MediaQuery.of(context).size.width,
                                    child: Image.file(
                                      _storeProvider.storeLocalImagePath,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  )
                                : (_storeProvider.storePicRef != null)
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.network(
                                          _storeProvider.storePicRef,
                                          fit: BoxFit.scaleDown,
                                        ),
                                      )
                                    : Placeholder(
                                        fallbackHeight:
                                            MediaQuery.of(context).size.height /
                                                4,
                                      ),
                            SizedBox(
                              child: ElevatedButton(
                                  onPressed: () {
                                    getImageAndUpload();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.add_a_photo_outlined,
                                        ),
                                      ),
                                      Text(
                                        'Resim Seç',
                                        style: TextStyle(
                                          fontFamily: 'Bebas',
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                  )),
                            ),
                            SizedBox(
                              child: ElevatedButton(
                                  onPressed: () {
                                    getLocation();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.add_location_alt_outlined,
                                        ),
                                      ),
                                      Text(
                                        'Konum Al',
                                        style: TextStyle(
                                          fontFamily: 'Bebas',
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                  )),
                            ),
                            Form(
                              key: formkey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: DropdownButton(
                                          value: _selectedCat,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          hint: Text(
                                              "İşletme için kategori seçiniz !"),
                                          items: storeCats
                                              .map((StoreCategory storeCat) {
                                            return new DropdownMenuItem<String>(
                                              value: storeCat.storeCatName,
                                              onTap: () {
                                                _selectedCat =
                                                    storeCat.storeCatName;
                                              },
                                              child: new Text(
                                                storeCat.storeCatName,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            selectCategory(value);
                                            _storeProvider
                                                .changeStoreCategory(value);
                                          }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: DropdownButton(
                                          value: _selectedAltCat,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          hint: Text(
                                              "İşletme için alt kategori seçiniz !"),
                                          items: storeAltCats.map(
                                              (StoreAltCategory storeAltCat) {
                                            return new DropdownMenuItem<String>(
                                              value:
                                                  storeAltCat.storeAltCatName,
                                              onTap: () {
                                                _selectedAltCat =
                                                    storeAltCat.storeAltCatName;
                                              },
                                              child: new Text(
                                                storeAltCat.storeAltCatName,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStoreAltCategory(value);
                                          }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: TextFormField(
                                      controller: taxNo,
                                      validator: validateTaxNo,
                                      onChanged: (value) {
                                        _storeProvider.changeStoreTaxNo(value);
                                        validateTaxNo(value);
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      decoration: InputDecoration(
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
                                      },
                                      maxLength: 25,
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      decoration: InputDecoration(
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      decoration: InputDecoration(
                                          labelText: 'İşletme İsmi',
                                          icon: Icon(Icons.announcement_sharp),
                                          border: OutlineInputBorder()),
                                      maxLength: 35,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: TextFormField(
                                      validator: validateAddress,
                                      onChanged: (value) {
                                        _storeProvider
                                            .changeStoreAddress(value);
                                      },
                                      controller: address,
                                      maxLength: 255,
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      decoration: InputDecoration(
                                          labelText: 'İşletme Adresi',
                                          icon:
                                              Icon(Icons.add_location_rounded),
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.text,
                                      maxLength: 50,
                                      decoration: InputDecoration(
                                          labelText:
                                              'İlgili kişi isim-soyisim (1)',
                                          icon: Icon(
                                              Icons.account_circle_outlined),
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.text,
                                      maxLength: 50,
                                      decoration: InputDecoration(
                                          labelText:
                                              'İlgili kişi isim-soyisim (2)',
                                          icon: Icon(
                                              Icons.account_circle_outlined),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: TextFormField(
                                      controller: pers2Phone,
                                      onChanged: (value) {
                                        _storeProvider.changePers2Phone(value);
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
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
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.text,
                                      maxLength: 50,
                                      decoration: InputDecoration(
                                          labelText:
                                              'İlgili kişi isim-soyisim (3)',
                                          icon: Icon(
                                              Icons.account_circle_outlined),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: TextFormField(
                                      controller: pers3Phone,
                                      onChanged: (value) {
                                        _storeProvider.changePers3Phone(value);
                                      },
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                          labelText: 'İlgili kişi telefon (3)',
                                          prefix: Text('+90'),
                                          icon: Icon(Icons.phone),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ));
  }
}
