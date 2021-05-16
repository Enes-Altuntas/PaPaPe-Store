import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final bool campaignActive;
  final String campaignDesc;
  final String campaignId;
  final String campaignKey;
  final int campaignCounter;
  final Timestamp campaignStart;
  final Timestamp campaignFinish;
  final Timestamp createdAt;

  Campaign({
    this.campaignActive,
    this.campaignDesc,
    this.campaignId,
    this.campaignKey,
    this.campaignCounter,
    this.campaignStart,
    this.campaignFinish,
    this.createdAt,
  });

  Campaign.fromFirestore(Map<String, dynamic> data)
      : campaignActive = data['campaignActive'],
        campaignDesc = data['campaignDesc'],
        campaignKey = data['campaignKey'],
        campaignCounter = data['campaignCounter'],
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
      'campaignCounter': campaignCounter,
      'campaignFinish': campaignFinish,
      'createdAt': createdAt,
      'campaignId': campaignId,
    };
  }
}
