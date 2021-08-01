import 'package:cloud_firestore/cloud_firestore.dart';

class PositionModel {
  final String geohash;
  final GeoPoint geopoint;

  PositionModel({
    this.geohash,
    this.geopoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'geohash': geohash,
      'geopoint': geopoint,
    };
  }

  PositionModel.fromFirestore(Map<String, dynamic> firestore)
      : geohash = firestore['geohash'],
        geopoint = firestore['geopoint'];
}
