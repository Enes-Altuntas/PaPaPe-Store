import 'dart:ui';

import 'package:bulb/Models/camapign_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CampaignCard extends StatefulWidget {
  final Campaign campaign;
  final Function onPressed;

  CampaignCard({Key key, this.campaign, this.onPressed}) : super(key: key);

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
      color: Colors.white,
      shadowColor: Colors.black,
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
                    Theme.of(context).accentColor,
                    Theme.of(context).primaryColor
                  ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
                  child: (widget.campaign.campaignPicRef != null)
                      ? Image.network(widget.campaign.campaignPicRef,
                          loadingBuilder: (context, child, loadingProgress) {
                          return loadingProgress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                        }, fit: BoxFit.fill)
                      : Center(
                          child: Text('Kampanya Resmi Yok',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Bebas',
                                  fontSize: 20.0)),
                        ),
                ),
                Positioned(
                    right: 20.0,
                    top: 20.0,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Theme.of(context).accentColor,
                                Theme.of(context).primaryColor
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft),
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  widget.campaign.campaignCounter.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontSize: 20)),
                            ),
                          ],
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
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Center(
                              child: FaIcon(FontAwesomeIcons.checkCircle,
                                  color: Colors.white),
                            ),
                          )
                        : (widget.campaign.campaignStatus == 'inactive')
                            ? Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Center(
                                  child: FaIcon(FontAwesomeIcons.ban,
                                      color: Colors.white),
                                ),
                              )
                            : Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                    color: Colors.amber[600],
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Center(
                                  child: FaIcon(FontAwesomeIcons.hourglassHalf,
                                      color: Colors.white),
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
                      fontFamily: 'Roboto',
                      color: Colors.amber[900],
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(widget.campaign.campaignDesc,
                  style: TextStyle(fontFamily: 'Roboto'),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.amber[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
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
                              fontSize: 14.0,
                              color: Theme.of(context).hintColor,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                          'Kampanya Bitiş : ${formatDate(widget.campaign.campaignFinish)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Roboto',
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                          '#${widget.campaign.campaignKey.toUpperCase()}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                              color: Colors.amber[900])),
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
