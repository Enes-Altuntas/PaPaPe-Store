import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:papape_store/Models/campaign_user.dart';

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
  final List<CampaignUserModel> campaignUsers;
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
      this.campaignTitle,
      this.campaignUsers,
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
        campaignTitle = data['campaignTitle'],
        campaignUsers = data['campaignUsers'].map<CampaignUserModel>((value) {
          return CampaignUserModel.fromFirestore(value);
        }).toList(),
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
      'campaignStart': campaignStart,
      'campaignUsers': campaignUsers,
      'campaignFinish': campaignFinish,
      'createdAt': createdAt,
      'campaignId': campaignId,
    };
  }
}
