import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final bool campaignActive;
  final String campaignDesc;
  final String campaignId;
  final String campaignKey;
  final Timestamp campaignStart;
  final Timestamp campaignFinish;
  final Timestamp createdAt;

  Campaign({
    this.campaignActive,
    this.campaignDesc,
    this.campaignId,
    this.campaignKey,
    this.campaignStart,
    this.campaignFinish,
    this.createdAt,
  });

  Campaign.fromFirestore(Map<String, dynamic> data)
      : campaignActive = data['campaignActive'],
        campaignDesc = data['campaignDesc'],
        campaignKey = data['campaignKey'],
        campaignId = data['campaignId'],
        campaignStart = data['campaignStart'],
        campaignFinish = data['campaignFinish'],
        createdAt = data['createdAt'];

  Map<String, dynamic> toMap() {
    return {
      'campaignActive': campaignActive,
      'campaignDesc': campaignDesc,
      'campaignKey': campaignKey,
      'campaignStart': campaignStart,
      'campaignFinish': campaignFinish,
      'createdAt': createdAt,
      'campaignId': campaignId,
    };
  }
}
