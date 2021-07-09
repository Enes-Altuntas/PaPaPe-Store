import 'package:cloud_firestore/cloud_firestore.dart';

class PositionMarker {
  final String geohash;
  final GeoPoint geopoint;

  PositionMarker({
    this.geohash,
    this.geopoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'geohash': geohash,
      'geopoint': geopoint,
    };
  }

  PositionMarker.fromFirestore(Map<String, dynamic> firestore)
      : geohash = firestore['geohash'],
        geopoint = firestore['geopoint'];
}
