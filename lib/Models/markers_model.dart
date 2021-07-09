import 'package:bulb/Models/position_model.dart';

class FirestoreMarkers {
  final bool hasCampaign;
  final String storeCategory;
  final PositionMarker position;
  final String storeId;

  FirestoreMarkers({
    this.storeCategory,
    this.hasCampaign,
    this.position,
    this.storeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeCategory': storeCategory,
      'hasCampaign': hasCampaign,
      'position': position.toMap(),
      'storeId': storeId,
    };
  }

  FirestoreMarkers.fromFirestore(Map<String, dynamic> firestore)
      : storeCategory = firestore['storeCategory'],
        hasCampaign = firestore['hasCampaign'],
        position = PositionMarker.fromFirestore(firestore['position']),
        storeId = firestore['storeId'];
}
