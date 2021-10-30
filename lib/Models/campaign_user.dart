import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignUserModel {
  final String user;
  final Timestamp scannedAt;

  CampaignUserModel({this.user, this.scannedAt});

  Map<String, dynamic> toMap() {
    return {'user': user, 'scannedAt': scannedAt};
  }

  CampaignUserModel.fromFirestore(Map<String, dynamic> firestore)
      : user = firestore['user'],
        scannedAt = firestore['scannedAt'];
}
