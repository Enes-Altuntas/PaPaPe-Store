import 'dart:io';
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

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  StoreProvider _storeProvider;
  List<StoreCategory> storeCats = [];
  String _selectedCat;
  Future getUserInfo;
  bool isInit = true;
  bool isLoading = false;
  final TextEditingController taxNo = TextEditingController();
  final TextEditingController taxLoc = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController phone = TextEditingController();
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

  Future<Store> _getStoreInfo() async {
    Store _store;
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshots = await FirestoreService().getStoreCat();
    snapshots.docs.forEach((element) {
      StoreCategory catElement = StoreCategory.fromFirestore(element.data());
      storeCats.add(catElement);
    });

    await FirestoreService()
        .getStore()
        .then((value) => {
              if (value != null && value.data() != null)
                {_store = Store.fromFirestore(value.data())}
            })
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
    if (_store != null) {
      _selectedCat = _store.storeCategory;
      taxNo.text = _store.storeTaxNo;
      taxLoc.text = _store.storeTaxLoc;
      name.text = _store.storeName;
      address.text = _store.storeAddress;
      phone.text = _store.storePhone;
      _storeProvider.loadStoreInfo(_store);
    }
    return _store;
  }

  saveStore() async {
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
      setState(() {
        isLoading = true;
      });
      await FirestoreService()
          .saveStore(_storeProvider.getStoreFromProvider())
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    }
  }

  getLocation() async {
    setState(() {
      isLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
    _storeProvider.changeStoreLocLat(position.latitude);
    _storeProvider.changeStoreLocLong(position.longitude);
    ToastService().showSuccess('Konumunuz alınmıştır !', context);
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

  String validateTaxNo(value) {
    if (value.isEmpty) {
      return "* Vergi numarası zorunludur !";
    } else {
      return null;
    }
  }

  String validateTaxLoc(value) {
    if (value.isEmpty) {
      return "* Vergi dairesi zorunludur !";
    } else {
      return null;
    }
  }

  String validateName(value) {
    if (value.isEmpty) {
      return "* İşletme ismi zorunludur !";
    } else {
      return null;
    }
  }

  String validatePhone(value) {
    if (value.isEmpty) {
      return "* İşletme telefon numarası zorunludur !";
    } else {
      return null;
    }
  }

  String validateAddress(value) {
    if (value.isEmpty) {
      return "* İşletme adresi zorunludur !";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: getUserInfo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return (snapshot.connectionState == ConnectionState.done)
            ? (isLoading == false)
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
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.file(
                                          _storeProvider.storeLocalImagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_storeProvider.storePicRef != null)
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Image.network(
                                              _storeProvider.storePicRef,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Placeholder(
                                            fallbackHeight:
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                          ),
                                SizedBox(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        getImageAndUpload();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
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
                                        primary: Theme.of(context).accentColor,
                                      )),
                                ),
                                SizedBox(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        getLocation();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
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
                                        primary: Theme.of(context).accentColor,
                                      )),
                                ),
                                Form(
                                  key: formkey,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: DropdownButton(
                                            value: _selectedCat,
                                            hint: Text(
                                                "İşletme için kategori seçiniz !"),
                                            items: storeCats
                                                .map((StoreCategory storeCat) {
                                              return new DropdownMenuItem<
                                                  String>(
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
                                              _storeProvider
                                                  .changeStoreCategory(value);
                                            }),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: TextFormField(
                                          controller: taxNo,
                                          validator: validateTaxNo,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStoreTaxNo(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              icon: Icon(Icons.attach_money),
                                              labelText:
                                                  'İşletme Vergi Numarası',
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          controller: taxLoc,
                                          validator: validateTaxLoc,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStoreTaxLoc(value);
                                          },
                                          maxLength: 25,
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          decoration: InputDecoration(
                                              icon: Icon(Icons.account_balance),
                                              border: OutlineInputBorder(),
                                              labelText:
                                                  'İşletme Vergi Dairesi'),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          controller: name,
                                          validator: validateName,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStoreName(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          decoration: InputDecoration(
                                              labelText: 'İşletme İsmi',
                                              icon: Icon(
                                                  Icons.announcement_sharp),
                                              border: OutlineInputBorder()),
                                          maxLength: 50,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
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
                                              color: Colors.grey[800]),
                                          decoration: InputDecoration(
                                              labelText: 'İşletme Adresi',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İşletme Telefon Numarası',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePersName,
                                          controller: pers1,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi isim-soyisim (1)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi telefon (1)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi isim-soyisim (2)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi telefon (2)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi isim-soyisim (3)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: TextFormField(
                                          validator: validatePhone,
                                          controller: phone,
                                          onChanged: (value) {
                                            _storeProvider
                                                .changeStorePhone(value);
                                          },
                                          style: TextStyle(
                                              color: Colors.grey[800]),
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'İlgili kişi telefon (3)',
                                              icon: Icon(
                                                  Icons.add_location_rounded),
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          saveStore();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Icon(
                                                Icons.save_outlined,
                                              ),
                                            ),
                                            Text(
                                              'Kaydet & Güncelle',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Bebas',
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                  )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).accentColor,
                ),
              );
      },
    ));
  }
}
