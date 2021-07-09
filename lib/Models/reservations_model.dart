import 'package:cloud_firestore/cloud_firestore.dart';

class Reservations {
  final String reservationDesc;
  final String reservationStatus;
  final String reservationId;
  final String reservationName;
  final String reservationPhone;
  final int reservationCount;
  final String user;
  final Timestamp reservationTime;

  Reservations({
    this.reservationDesc,
    this.reservationStatus,
    this.reservationCount,
    this.reservationName,
    this.reservationPhone,
    this.reservationId,
    this.user,
    this.reservationTime,
  });

  Reservations.fromFirestore(Map<String, dynamic> data)
      : reservationDesc = data['reservationDesc'],
        reservationStatus = data['reservationStatus'],
        reservationCount = data['reservationCount'],
        reservationName = data['reservationName'],
        reservationPhone = data['reservationPhone'],
        reservationId = data['reservationId'],
        user = data['user'],
        reservationTime = data['reservationTime'];

  Map<String, dynamic> toMap() {
    return {
      'reservationDesc': reservationDesc,
      'reservationStatus': reservationStatus,
      'reservationCount': reservationCount,
      'reservationName': reservationName,
      'reservationPhone': reservationPhone,
      'reservationId': reservationId,
      'user': user,
      'reservationTime': reservationTime,
    };
  }
}
