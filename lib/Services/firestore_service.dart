import 'dart:io';

import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Models/campaign_user.dart';
import 'package:papape_store/Models/user_model.dart';
import 'package:papape_store/Models/wishes_model.dart';
import 'package:papape_store/Models/markers_model.dart';
import 'package:papape_store/Models/position_model.dart';
import 'package:papape_store/Models/product_category_model.dart';
import 'package:papape_store/Models/product_model.dart';
import 'package:papape_store/Models/reservations_model.dart';
import 'package:papape_store/Models/store_model.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Geoflutterfire geo = Geoflutterfire();
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

  Future deletePicture(String id) async {
    try {
      Reference pictureRef = _storage.ref().child(id);
      await pictureRef.delete();
    } catch (e) {
      throw 'Seçtiğiniz resim silinirken bir hata meydana geldi! Lütfen daha sonra tekrar deneyiniz.';
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
          storeId: _uuid,
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

      GeoFirePoint center =
          geo.point(latitude: store.storeLocLat, longitude: store.storeLocLong);

      MarkerModel newMarker = MarkerModel(
        campaignStatus: 'none',
        storeCategory: store.storeCategory,
        storeName: store.storeName,
        position: PositionModel(
            geohash: center.hash,
            geopoint: GeoPoint(store.storeLocLat, store.storeLocLong)),
        storeId: newStore.storeId,
      );

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

      GeoFirePoint center =
          geo.point(latitude: store.storeLocLat, longitude: store.storeLocLong);

      try {
        await _db.collection('stores').doc(_uuid).set(updStore.toMap());
        await _db.collection('markers').doc(_uuid).update({
          'storeCategory': store.storeCategory,
          'storeName': store.storeName,
          'position': PositionModel(
                  geohash: center.hash,
                  geopoint: GeoPoint(store.storeLocLat, store.storeLocLong))
              .toMap()
        });

        return 'Bilgileriniz güncellenmiştir !';
      } catch (e) {
        throw 'Güncelleme işlemi esnasında bir hata ile karşılaşıldı! Lütfen daha sonra tekrar deneyiniz.';
      }
    }
  }

  Future getStore() async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();
    if (_userId != null) {
      return await _db.collection('stores').doc(_userId).get();
    }
  }

  Future getStoreCat() async {
    return await _db
        .collection('categories')
        .orderBy('storeCatRow', descending: false)
        .get();
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
        .where('delInd', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Campaign.fromFirestore(doc.data()))
            .toList());
  }

  Future<String> saveCampaign(Campaign campaign) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    if (campaign.campaignLocalImage != null) {
      await savePicture(campaign.campaignLocalImage, campaign.campaignId)
          .onError((error, stackTrace) => throw error)
          .whenComplete(() {
        campaign.campaignPicRef = downloadUrl;
      });
    }

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .get()
          .then((value) => value.docs.map((element) {
                element.reference.update({'campaignStatus': 'inactive'});
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
          .update({'campaignStatus': 'wait'});

      return 'Kampanyanız başarıyla kaydedilmiştir !';
    } catch (e) {
      throw 'Kampanyanız kaydedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> updateCampaign(Campaign campaign) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    if (campaign.campaignLocalImage != null) {
      await savePicture(campaign.campaignLocalImage, campaign.campaignId)
          .onError((error, stackTrace) => throw error)
          .whenComplete(() {
        campaign.campaignPicRef = downloadUrl;
      });
    }

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaign.campaignId)
          .set(campaign.toMap());

      return 'Kampanyanız başarıyla güncellenmiştir !';
    } catch (e) {
      throw 'Kampanyanız güncellenirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  // Future<String> renewCampaign(Campaign campaign) async {
  //   String _userId = AuthService(FirebaseAuth.instance).getUserId();

  //   if (campaign.campaignLocalImage != null) {
  //     await savePicture(campaign.campaignLocalImage, campaign.campaignId)
  //         .onError((error, stackTrace) => throw error)
  //         .whenComplete(() {
  //       campaign.campaignPicRef = downloadUrl;
  //     });
  //   }

  //   try {
  //     await _db
  //         .collection('stores')
  //         .doc(_userId)
  //         .collection('campaigns')
  //         .get()
  //         .then((value) => value.docs.map((element) {
  //               element.reference.update({'campaignStatus': 'inactive'});
  //             }));

  //     await _db
  //         .collection('stores')
  //         .doc(_userId)
  //         .collection('campaigns')
  //         .doc(campaign.campaignId)
  //         .set(campaign.toMap());

  //     await _db
  //         .collection('markers')
  //         .doc(_userId)
  //         .update({'campaignStatus': 'wait'});

  //     return 'Kampanyanız başarıyla tekrar yayınlandı !';
  //   } catch (e) {
  //     throw 'Kampanyanız yayınlanırken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
  //   }
  // }

  Future<String> removeCampaign(String campaignId) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaignId)
          .update({'campaignStatus': 'inactive'});

      await _db
          .collection('markers')
          .doc(_userId)
          .update({'campaignStatus': 'inactive'});

      return 'Kampanyanız başarıyla sonlandırılmıştır !';
    } catch (e) {
      throw 'Kampanyanız sonlandırılırken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> deleteCampaign(String campaignId) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    try {
      await _db
          .collection('stores')
          .doc(_userId)
          .collection('campaigns')
          .doc(campaignId)
          .update({'campaignActive': 'inactive', 'delInd': true});

      await _db
          .collection('markers')
          .doc(_userId)
          .update({'campaignStatus': 'inactive'});

      await deletePicture(campaignId);

      return 'Kampanyanız başarıyla silinmiştir !';
    } catch (e) {
      throw 'Kampanyanız silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyiniz.';
    }
  }

  Future<String> scanCode(
      String storeId, String campaignId, String userId) async {
    UserModel user;

    try {
      user = await _db.collection('users').doc(userId).get().then((value) {
        return UserModel.fromFirestore(value.data());
      });
    } catch (e) {
      return 'Müşteri kodu bulunamadı !';
    }

    if (user.campaignCodes.contains(campaignId)) {
      user.campaignCodes.remove(campaignId);

      try {
        await _db
            .collection('users')
            .doc(userId)
            .update({'campaignCodes': user.campaignCodes});

        Campaign scannedCampaign = await _db
            .collection('stores')
            .doc(storeId)
            .collection('campaigns')
            .doc(campaignId)
            .get()
            .then((value) {
          return Campaign.fromFirestore(value.data());
        });

        scannedCampaign.campaignUsers.add(CampaignUserModel(
            scannedAt: Timestamp.fromDate(DateTime.now()), user: userId));

        await _db
            .collection('stores')
            .doc(storeId)
            .collection('campaigns')
            .doc(campaignId)
            .update({'campaignUsers': scannedCampaign.campaignUsers});

        return 'Kampanya başarıyla uygulanmıştır !';
      } catch (e) {
        return 'Kampanya kodu bulunamadı !';
      }
    } else {
      throw ('Müşterinin kampanyası bulunamamıştır !');
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
      return 'Yeni başlığınız başarıyla oluşturulmuştur !';
    } catch (e) {
      throw 'Başlığınız oluşturulurken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
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
      return 'Başlığınız başarıyla güncellenmiştir !';
    } catch (e) {
      throw 'Başlığınız güncelleştirilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
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

      return 'Başlığınız başarıyla silinmiştir !';
    } catch (e) {
      throw 'Başlığınız silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
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

    if (product.productLocalImage != null) {
      await savePicture(product.productLocalImage, product.productId)
          .onError((error, stackTrace) => throw error)
          .whenComplete(() {
        product.productPicRef = downloadUrl;
      });
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

      return 'Ürününüz başarıyla eklenmiştir !';
    } catch (e) {
      throw 'Ürününüz kaydedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> updateProduct(Product product) async {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    if (product.productLocalImage != null) {
      await savePicture(product.productLocalImage, product.productId)
          .onError((error, stackTrace) => throw error)
          .whenComplete(() {
        product.productPicRef = downloadUrl;
      });
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

      await deletePicture(productId);

      return 'Ürününüz başarıyla silinmiştir !';
    } catch (e) {
      throw 'Ürününüz silinirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

// *******************************************************************************
// Ürünler ile ilgili backend işlemleri

// Şikayetler ile ilgili backend işlemleri
// *******************************************************************************

  Stream<List<WishesModel>> getReports() {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    return _db
        .collection('wishes')
        .where('wishStore', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WishesModel.fromFirestore(doc.data()))
            .toList());
  }

// *******************************************************************************
// Şikayetler ile ilgili backend işlemleri

// Rezervasyon ile ilgili backend işlemleri
// *******************************************************************************

  Stream<List<ReservationsModel>> getReservations() {
    String _userId = AuthService(FirebaseAuth.instance).getUserId();

    return _db
        .collection('reservations')
        .where('reservationStore', isEqualTo: _userId)
        .orderBy('reservationTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationsModel.fromFirestore(doc.data()))
            .toList());
  }

  Future<String> approveReservation(ReservationsModel reservation) async {
    try {
      await _db
          .collection('reservations')
          .doc(reservation.reservationId)
          .update({'reservationStatus': 'approved'});

      return 'Rezervasyonunuz başarıyla onaylanmıştır !';
    } catch (e) {
      throw 'Rezervasyonunuz onaylanırken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

  Future<String> rejectReservation(ReservationsModel reservation) async {
    try {
      await _db
          .collection('reservations')
          .doc(reservation.reservationId)
          .update({'reservationStatus': 'rejected'});

      return 'Rezervasyonunuz başarıyla reddedilmiştir !';
    } catch (e) {
      throw 'Rezervasyonunuz reddedilirken bir hata ile karşılaşıldı ! Lütfen daha sonra tekrar deneyeniz.';
    }
  }

// *******************************************************************************
// Rezarvasyon ile ilgili backend işlemleri
}
