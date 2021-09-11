import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  // inactive , wait , active
  final String campaignStatus;
  String campaignPicRef;
  final bool automatedStart;
  final bool automatedStop;
  final bool delInd;
  final String campaignDesc;
  final String campaignId;
  final String campaignTitle;
  final String campaignKey;
  final int campaignCounter;
  final Timestamp campaignStart;
  final Timestamp campaignFinish;
  final Timestamp createdAt;
  File campaignLocalImage;

  Campaign(
      {this.campaignStatus,
      this.campaignPicRef,
      this.automatedStart,
      this.automatedStop,
      this.delInd,
      this.campaignDesc,
      this.campaignId,
      this.campaignKey,
      this.campaignTitle,
      this.campaignCounter,
      this.campaignStart,
      this.campaignFinish,
      this.createdAt,
      this.campaignLocalImage});

  Campaign.fromFirestore(Map<String, dynamic> data)
      : campaignStatus = data['campaignStatus'],
        automatedStart = data['automatedStart'],
        campaignPicRef = data['campaignPicRef'],
        delInd = data['delInd'],
        automatedStop = data['automatedStop'],
        campaignDesc = data['campaignDesc'],
        campaignKey = data['campaignKey'],
        campaignTitle = data['campaignTitle'],
        campaignCounter = data['campaignCounter'],
        campaignId = data['campaignId'],
        campaignStart = data['campaignStart'],
        campaignFinish = data['campaignFinish'],
        createdAt = data['createdAt'];

  Map<String, dynamic> toMap() {
    return {
      'campaignStatus': campaignStatus,
      'automatedStart': automatedStart,
      'campaignPicRef': campaignPicRef,
      'delInd': delInd,
      'automatedStop': automatedStop,
      'campaignDesc': campaignDesc,
      'campaignTitle': campaignTitle,
      'campaignKey': campaignKey,
      'campaignStart': campaignStart,
      'campaignCounter': campaignCounter,
      'campaignFinish': campaignFinish,
      'createdAt': createdAt,
      'campaignId': campaignId,
    };
  }
}
