import 'package:papape_store/Models/position_model.dart';

class MarkerModel {
  // inactive , wait , active
  final String campaignStatus;
  final List storeCategory;
  final PositionModel position;
  final String storeId;
  final String storeName;

  MarkerModel(
      {this.storeCategory,
      this.campaignStatus,
      this.position,
      this.storeId,
      this.storeName});

  Map<String, dynamic> toMap() {
    return {
      'storeCategory': storeCategory,
      'campaignStatus': campaignStatus,
      'position': position.toMap(),
      'storeId': storeId,
      'storeName': storeName
    };
  }

  MarkerModel.fromFirestore(Map<String, dynamic> firestore)
      : storeCategory = firestore['storeCategory'],
        campaignStatus = firestore['campaignStatus'],
        position = PositionModel.fromFirestore(firestore['position']),
        storeId = firestore['storeId'],
        storeName = firestore['storeName'];
}
