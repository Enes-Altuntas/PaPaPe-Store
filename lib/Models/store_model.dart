import 'dart:io';

class Store {
  final String storeId;
  final String storeName;
  final String storePicRef;
  final String storeAddress;
  final List storeCategory;
  final String storePhone;
  final String storeTaxNo;
  final String storeTaxLoc;
  final double storeLocLat;
  final double storeLocLong;
  final String pers1;
  final String pers2;
  final String pers3;
  final String pers1Phone;
  final String pers2Phone;
  final String pers3Phone;
  File storeLocalImagePath;

  Store({
    this.storeId,
    this.storeName,
    this.storePicRef,
    this.storeAddress,
    this.storeCategory,
    this.storePhone,
    this.storeTaxNo,
    this.storeTaxLoc,
    this.storeLocLat,
    this.storeLocLong,
    this.pers1,
    this.pers2,
    this.pers3,
    this.pers1Phone,
    this.pers2Phone,
    this.pers3Phone,
    this.storeLocalImagePath,
  });

  Store.fromFirestore(Map<String, dynamic> data)
      : storeId = data['storeId'],
        storeName = data['storeName'],
        storePicRef = data['storePicRef'],
        storeAddress = data['storeAddress'],
        storeCategory = data['storeCategory'],
        storePhone = data['storePhone'],
        storeTaxNo = data['storeTaxNo'],
        storeTaxLoc = data['storeTaxLoc'],
        storeLocLat = data['storeLocLat'],
        pers1 = data['pers1'],
        pers2 = data['pers2'],
        pers3 = data['pers3'],
        pers1Phone = data['pers1Phone'],
        pers2Phone = data['pers2Phone'],
        pers3Phone = data['pers3Phone'],
        storeLocLong = data['storeLocLong'];

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'storePicRef': storePicRef,
      'storeAddress': storeAddress,
      'storeCategory': storeCategory,
      'storePhone': storePhone,
      'storeTaxNo': storeTaxNo,
      'storeTaxLoc': storeTaxLoc,
      'storeLocLat': storeLocLat,
      'storeLocLong': storeLocLong,
      'pers1': pers1,
      'pers2': pers2,
      'pers3': pers3,
      'pers1Phone': pers1Phone,
      'pers2Phone': pers2Phone,
      'pers3Phone': pers3Phone,
    };
  }
}
