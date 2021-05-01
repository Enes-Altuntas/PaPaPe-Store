import 'dart:io';

import 'package:bulovva_store/Models/camapign_model.dart';
import 'package:bulovva_store/Models/markers_model.dart';
import 'package:bulovva_store/Models/product_category_model.dart';
import 'package:bulovva_store/Models/product_model.dart';
import 'package:bulovva_store/Models/comment_model.dart';
import 'package:bulovva_store/Models/store_model.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  String downloadUrl;
  TaskSnapshot snapshot;
  final _storage = FirebaseStorage.instance;

// Profil ile ilgili backend işlemleri
// *******************************************************************************

  Future savePicture(File localImage, String id) async {
    try {
      snapshot = await _storage.ref().child(id).putFile(localImage);
      downloadUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Seçtiğiniz resim yüklenirken bir hata meydana geldi! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> saveStore(Store store) async {
    String _uuid = AuthService(FirebaseAuth.instance).getUserId();

    if (store.storeLocalImagePath != null) {
      await savePicture(store.storeLocalImagePath, _uuid)
          .onError((error, stackTrace) => throw error);
    }

    if (store.storeId == null) {
      Store newStore = Store(
          storeId: Uuid().v4(),
          storeName: store.storeName,
          storeTaxNo: store.storeTaxNo,
          storeTaxLoc: store.storeTaxLoc,
          storeAddress: store.storeAddress,
          storePhone: store.storePhone,
          storeLocLat: store.storeLocLat,
          storeLocLong: store.storeLocLong,
          storeCategory: store.storeCategory,
          pers1: store.pers1,
          pers2: store.pers2,
          pers3: store.pers3,
          pers1Phone: store.pers1Phone,
          pers2Phone: store.pers2Phone,
          pers3Phone: store.pers3Phone,
          storePicRef: downloadUrl);

      Markers newMarker = Markers(
          hasCampaign: false,
          markerLatitude: store.storeLocLat.toString(),
          markerLongtitude: store.storeLocLong.toString(),
          storeCategory: store.storeCategory,
          storeId: newStore.storeId,
          markerTitle: store.storeName);

      try {
        await _db.collection('stores').doc(_uuid).set(newStore.toMap());
        await _db.collection('markers').doc(_uuid).set(newMarker.toMap());

        return 'Bilgileriniz kaydedilmiştir !';
      } catch (e) {
        throw 'Kayıt işlemi esnasında bir hata ile karşılaşıldı! Lütfen daha sonra tekrar deneyiniz.';
      }
    } else {
      Store updStore = Store(
          storeId: store.storeId,
          storeName: store.storeName,
          storeTaxNo: store.storeTaxNo,
          storeTaxLoc: store.storeTaxLoc,
          storeAddress: store.storeAddress,
          storePhone: store.storePhone,
          storeCategory: store.storeCategory,
          storeLocLat: store.storeLocLat,
          storeLocLong: store.storeLocLong,
          pers1: store.pers1,
          pers2: store.pers2,
          pers3: store.pers3,
          pers1Phone: store.pers1Phone,
          pers2Phone: store.pers2Phone,
          pers3Phone: store.pers3Phone,
          storePicRef: (downloadUrl != null) ? downloadUrl : store.storePicRef);

      Markers newMarker = Markers(
          hasCampaign: false,
          markerLatitude: store.storeLocLat.toString(),
          markerLongtitude: store.storeLocLong.toString(),
          storeCategory: store.storeCategory,
          storeId: store.storeId,
          markerTitle: store.storeName);

      try {
        await _db.collection('stores').doc(_uuid).set(updStore.toMap());
        await _db.collection('markers').doc(_uuid).set(newMarker.toMap());

        return 'Bilgileriniz güncellenmiştir !';
      } catch (e) {
        throw 'Güncelleme işlemi esnasında bir hata ile karşılaşıldı! Lütfen daha sonra tekrar deneyiniz.';
      }
    }
  }

  Future getStore() async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    return await _db.collection('stores').doc(_userId).get();
  }

  Future getStoreCat() async {
    return await _db.collection('categories').get();
  }

// *******************************************************************************
// Profil ile ilgili backend işlemleri

// Kampanyalar ile ilgili backend işlemleri
// *******************************************************************************

  Stream<List<Campaign>> getStoreCampaigns() {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    return _db
        .collection('stores')
        .doc(_userId)
        .collection('campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Campaign.fromFirestore(doc.data()))
            .toList());
  }

  Future<String> saveCampaign(Campaign campaign) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({'campaignActive': false});
              }));

      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaign.campaignId)
          .set(campaign.toMap());

      await _db
          .collection('markers')
          .doc(_userId)
          .update({'hasCampaign': true});

      return 'Kampanyanız başarıyla kaydedilmiştir !';
    } catch (e) {
      throw 'Kampanyanız kaydedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> updateCampaign(Campaign campaign) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaign.campaignId)
          .set(campaign.toMap());

      return 'Kampanyanız başarıyla güncellenirken !';
    } catch (e) {
      throw 'Kampanyanız güncellenirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> renewCampaign(Campaign campaign) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({'campaignActive': false});
              }));

      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaign.campaignId)
          .set(campaign.toMap());

      await _db
          .collection('markers')
          .doc(_userId)
          .update({'hasCampaign': true});

      return 'Kampanyanız başarıyla tekrar yayınlandı !';
    } catch (e) {
      throw 'Kampanyanız yayınlanırken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> removeCampaign(String campaignId) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaignId)
          .update({'campaignActive': false});

      await _db
          .collection('markers')
          .doc(_userId)
          .update({'hasCampaign': false});

      return 'Kampanyanız başarıyla silinmiştir !';
    } catch (e) {
      throw 'Kampanyanız silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

// *******************************************************************************
// Kampanyalar ile ilgili backend işlemleri

// Ürünler ile ilgili backend işlemleri
// *******************************************************************************

  Stream<List<ProductCategory>> getProductCategories() {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    return _db
        .collection('stores')
        .doc(_userId)
        .collection('products')
        .orderBy('categoryRow', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductCategory.fromFirestore(doc.data()))
            .toList());
  }

  Future<String> saveCategory(ProductCategory category) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(category.categoryId)
          .set(category.toMap());
      return 'Yeni ürün kategoriniz başarıyla oluşturulmuştur !';
    } catch (e) {
      throw 'Ürün kategoriniz oluşturulurken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> updateCategory(ProductCategory category) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(category.categoryId)
          .set(category.toMap());
      return 'Ürün kategoriniz başarıyla güncellenmiştir !';
    } catch (e) {
      throw 'Ürün kategoriniz güncelleştirilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> removeCategory(String categoryId) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(categoryId)
          .delete();

      return 'Ürün kategoriniz başarıyla silinmiştir !';
    } catch (e) {
      throw 'Ürün kategoriniz silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Stream<List<Product>> getProducts(String categoryId) {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    Stream<List<Product>> _dishes;
    _dishes = _db
        .collection('stores')
        .doc(_userId)
        .collection('products')
        .doc(categoryId)
        .collection('alt_products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data()))
            .toList());

    return _dishes;
  }

  Future<String> saveProduct(Product product) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(product.productCatId)
          .collection('alt_products')
          .doc(product.productId)
          .set(product.toMap());

      return 'Ürününüz başarıyla eklenmiştir !';
    } catch (e) {
      throw 'Ürününüz kaydedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> updateProduct(Product product, Product oldProduct) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    if (oldProduct.productCatId != product.productCatId) {
      try {
        await _db
            .collection('stores')
            .doc(_userId)
            .collection('products')
            .doc(oldProduct.productCatId)
            .collection('alt_products')
            .doc(oldProduct.productId)
            .delete();
      } catch (e) {
        throw 'Ürününüz silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
      }
    }

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(product.productCatId)
          .collection('alt_products')
          .doc(product.productId)
          .set(product.toMap());

      return 'Ürününüz başarıyla güncellenmiştir !';
    } catch (e) {
      throw 'Ürününüz kaydedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> removeProduct(String productId, String prodctCatId) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('products')
          .doc(prodctCatId)
          .collection('alt_products')
          .doc(productId)
          .delete();

      return 'Ürününüz başarıyla silinmiştir !';
    } catch (e) {
      throw 'Ürününüz silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

// *******************************************************************************
// Ürünler ile ilgili backend işlemleri

// Şikayetler ile ilgili backend işlemleri
// *******************************************************************************

  Stream<List<Comments>> getReports() {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    return _db
        .collection('stores')
        .doc(_userId)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comments.fromFirestore(doc.data()))
            .toList());
  }

// *******************************************************************************
// Şikayetler ile ilgili backend işlemleri
}
