import 'package:cloud_firestore/cloud_firestore.dart';

class WishesModel {
  final String wishDesc;
  final String wishTitle;
  final String wishId;
  final String wishUser;
  final String wishUserPhone;
  final Timestamp createdAt;
  final String wishStore;

  WishesModel(
      {this.wishDesc,
      this.wishTitle,
      this.wishId,
      this.wishUser,
      this.wishUserPhone,
      this.createdAt,
      this.wishStore});

  WishesModel.fromFirestore(Map<String, dynamic> data)
      : wishDesc = data['wishDesc'],
        wishTitle = data['wishTitle'],
        wishId = data['wishId'],
        wishUser = data['wishUser'],
        wishUserPhone = data['wishUserPhone'],
        createdAt = data['createdAt'],
        wishStore = data['wishStore'];

  Map<String, dynamic> toMap() {
    return {
      'wishDesc': wishDesc,
      'wishTitle': wishTitle,
      'wishId': wishId,
      'wishUser': wishUser,
      'wishUserPhone': wishUserPhone,
      'createdAt': createdAt,
      'wishStore': wishStore,
    };
  }
}
