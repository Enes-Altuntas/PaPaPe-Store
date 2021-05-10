import 'dart:io';
import 'package:bulovva_store/Models/store_model.dart';
import 'package:flutter/material.dart';

class StoreProvider with ChangeNotifier {
  String _storeName;
  String _storePicRef;
  String _storeAddress;
  String _storeCategory;
  String _storeAltCategory;
  String _storePhone;
  String _storeTaxNo;
  String _storeTaxLoc;
  String _storeId;
  String _pers1;
  String _pers1Phone;
  String _pers2;
  String _pers2Phone;
  String _pers3;
  String _pers3Phone;
  double _storeLocLat;
  double _storeLocLong;
  File _storeLocalImagePath;
  double _curLocLat;
  double _curLocLong;

  String get storeName => _storeName;
  String get storePicRef => _storePicRef;
  String get storeAdresss => _storeAddress;
  String get storeCategory => _storeCategory;
  String get storeAltCategory => _storeAltCategory;
  String get storePhone => _storePhone;
  String get storeTaxNo => _storeTaxNo;
  String get storeTaxLoc => _storeTaxLoc;
  String get storeId => _storeId;
  double get storeLocLat => _storeLocLat;
  double get storeLocLong => _storeLocLong;
  double get curLocLat => _curLocLat;
  double get curLocLong => _curLocLong;
  String get pers1 => _pers1;
  String get pers1Phone => _pers1Phone;
  String get pers2 => _pers2;
  String get pers2Phone => _pers2Phone;
  String get pers3 => _pers3;
  String get pers3Phone => _pers3Phone;
  File get storeLocalImagePath => _storeLocalImagePath;

  changeStoreName(String value) {
    _storeName = value;
    notifyListeners();
  }

  changeStoreId(String value) {
    _storeId = value;
    notifyListeners();
  }

  changeStoreAddress(String value) {
    _storeAddress = value;
    notifyListeners();
  }

  changeStoreCategory(String value) {
    _storeCategory = value;
    notifyListeners();
  }

  changeStoreAltCategory(String value) {
    _storeAltCategory = value;
    notifyListeners();
  }

  changeStorePhone(String value) {
    _storePhone = value;
    notifyListeners();
  }

  changeStoreTaxNo(String value) {
    _storeTaxNo = value;
    notifyListeners();
  }

  changeStoreTaxLoc(String value) {
    _storeTaxLoc = value;
    notifyListeners();
  }

  changeStoreLocLat(double value) {
    _storeLocLat = value;
    notifyListeners();
  }

  changeStoreLocLong(double value) {
    _storeLocLong = value;
    notifyListeners();
  }

  changeStoreLocalImagePath(File value) {
    _storeLocalImagePath = value;
    notifyListeners();
  }

  changePers1(String value) {
    _pers1 = value;
    notifyListeners();
  }

  changePers2(String value) {
    _pers2 = value;
    notifyListeners();
  }

  changePers3(String value) {
    _pers3 = value;
    notifyListeners();
  }

  changePers1Phone(String value) {
    _pers1Phone = value;
    notifyListeners();
  }

  changePers2Phone(String value) {
    _pers2Phone = value;
    notifyListeners();
  }

  changePers3Phone(String value) {
    _pers3Phone = value;
    notifyListeners();
  }

  changeCurLocLat(double value) {
    _curLocLat = value;
    notifyListeners();
  }

  changeCurLocLong(double value) {
    _curLocLong = value;
    notifyListeners();
  }

  free() {
    _storeAddress = null;
    _storeCategory = null;
    _storeAltCategory = null;
    _storeId = null;
    _storeLocLat = null;
    _storeLocLong = null;
    _storeLocalImagePath = null;
    _pers1 = null;
    _pers2 = null;
    _pers3 = null;
    _pers1Phone = null;
    _pers2Phone = null;
    _pers3Phone = null;
    _storeName = null;
    _storePhone = null;
    _storePicRef = null;
    _storeTaxLoc = null;
    _storeTaxNo = null;
  }

  Store getStoreFromProvider() {
    Store _store = Store(
        storeId: _storeId,
        storeTaxNo: _storeTaxNo,
        storeTaxLoc: _storeTaxLoc,
        storeName: _storeName,
        storePicRef: _storePicRef,
        storeCategory: _storeCategory,
        storeAltCategory: _storeAltCategory,
        storeAddress: _storeAddress,
        storePhone: _storePhone,
        storeLocLat: _storeLocLat,
        storeLocLong: _storeLocLong,
        pers1: _pers1,
        pers2: _pers2,
        pers3: _pers3,
        pers1Phone: _pers1Phone,
        pers2Phone: _pers2Phone,
        pers3Phone: _pers3Phone,
        storeLocalImagePath: _storeLocalImagePath);
    return _store;
  }

  loadStoreInfo(Store store) {
    _storeId = store.storeId;
    _storeName = store.storeName;
    _storePicRef = store.storePicRef;
    _storeCategory = store.storeCategory;
    _storeAddress = store.storeAddress;
    _storePhone = store.storePhone;
    _storeTaxNo = store.storeTaxNo;
    _storeTaxLoc = store.storeTaxLoc;
    _storeLocLat = store.storeLocLat;
    _storeLocLong = store.storeLocLong;
    _pers1 = store.pers1;
    _pers2 = store.pers2;
    _pers3 = store.pers3;
    _pers1Phone = store.pers1Phone;
    _pers2Phone = store.pers2Phone;
    _pers3Phone = store.pers3Phone;
    notifyListeners();
  }
}
