import 'dart:ui';

import 'package:papape_store/Campaigns/campaign_users.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CampaignCard extends StatefulWidget {
  final Campaign campaign;
  final Function onPressed;

  const CampaignCard({Key key, this.campaign, this.onPressed})
      : super(key: key);

  @override
  _CampaignCardState createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: ColorConstants.instance.whiteContainer,
      shadowColor: ColorConstants.instance.primaryColor,
      elevation: 5.0,
      child: InkWell(
        onTap: widget.onPressed,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    ColorConstants.instance.secondaryColor,
                    ColorConstants.instance.primaryColor,
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                  child: (widget.campaign.campaignPicRef != null &&
                          widget.campaign.campaignPicRef.isNotEmpty)
                      ? Image.network(widget.campaign.campaignPicRef,
                          loadingBuilder: (context, child, loadingProgress) {
                          return loadingProgress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                        }, fit: BoxFit.cover)
                      : Center(
                          child: Text('Kampanya Resmi Yok',
                              style: TextStyle(
                                  color: ColorConstants.instance.textOnColor,
                                  fontSize: 20.0)),
                        ),
                ),
                Positioned(
                    right: 20.0,
                    top: 20.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CampaignUsers(
                                campaignId: widget.campaign.campaignId)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 3.0,
                                color: ColorConstants.instance.textGold),
                            color: ColorConstants.instance.primaryColor,
                            borderRadius: BorderRadius.circular(50.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                color: ColorConstants.instance.iconOnColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                Positioned(
                    top: 20.0,
                    left: 20.0,
                    child: (widget.campaign.campaignStatus == 'active')
                        ? Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                                color: ColorConstants.instance.activeColor,
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.checkCircle,
                                color: ColorConstants.instance.iconOnColor,
                              ),
                            ),
                          )
                        : (widget.campaign.campaignStatus == 'inactive')
                            ? Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                    color:
                                        ColorConstants.instance.inactiveColor,
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.ban,
                                    color: ColorConstants.instance.iconOnColor,
                                  ),
                                ),
                              )
                            : Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                    color: ColorConstants.instance.waitingColor,
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.hourglassHalf,
                                    color: ColorConstants.instance.iconOnColor,
                                  ),
                                ),
                              ))
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Text(widget.campaign.campaignTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Montserrat",
                      color: ColorConstants.instance.primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(widget.campaign.campaignDesc,
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: (widget.campaign.campaignStatus == 'active')
                      ? ColorConstants.instance.activeColor
                      : (widget.campaign.campaignStatus == 'inactive')
                          ? ColorConstants.instance.inactiveColor
                          : ColorConstants.instance.waitingColor,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.instance.hintColor.withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                      child: Text(
                          'Kampanya Başlangıç : ${formatDate(widget.campaign.campaignStart)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorConstants.instance.textOnColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                      child: Text(
                          'Kampanya Bitiş : ${formatDate(widget.campaign.campaignFinish)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorConstants.instance.textOnColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
