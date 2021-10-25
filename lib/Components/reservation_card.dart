import 'dart:ui';

import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/reservations_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatefulWidget {
  final ReservationsModel reservation;
  final Function onPressedCall;
  final Function onPressedApprove;
  final Function onPressedReject;

  const ReservationCard(
      {Key key,
      this.reservation,
      this.onPressedApprove,
      this.onPressedCall,
      this.onPressedReject})
      : super(key: key);

  @override
  _ReservationCardState createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'İsim-Soyisim: ${widget.reservation.reservationName}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorConstants.instance.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Rezerve kişi sayısı: ${widget.reservation.reservationCount.toString()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorConstants.instance.hintColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Rezervasyon Açıklaması: ${(widget.reservation.reservationDesc)}',
                  style: TextStyle(
                    color: ColorConstants.instance.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Başvuru Durumu: ${(widget.reservation.reservationStatus == 'waiting') ? 'Beklemede' : (widget.reservation.reservationStatus == 'approved') ? 'Onaylanmış' : (widget.reservation.reservationStatus == 'canceled') ? 'İptal edilmiş' : 'Reddedilmiş'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.instance.hintColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                    'Rezervasyon Saati: ${formatDate(widget.reservation.reservationTime)}',
                    style: TextStyle(
                        color: ColorConstants.instance.hintColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: ColorConstants.instance.whiteContainer,
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstants.instance.hintColor
                              .withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 5.0, top: 5.0, left: 15.0, right: 15.0),
                    child: TextButton(
                        onPressed: widget.onPressedCall,
                        child: Text(
                          'Rez. Telefon: +90${widget.reservation.reservationPhone}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.instance.primaryColor,
                          ),
                        )),
                  ),
                ),
              ),
              Visibility(
                visible: widget.reservation.reservationStatus == 'waiting'
                    ? true
                    : false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: ColorConstants.instance.activeColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(50.0))),
                          child: TextButton(
                              onPressed: widget.onPressedApprove,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.thumbsUp,
                                      color:
                                          ColorConstants.instance.iconOnColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(
                                      'Onayla',
                                      style: TextStyle(
                                        color:
                                            ColorConstants.instance.textOnColor,
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: ColorConstants.instance.inactiveColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(50.0))),
                          child: TextButton(
                              onPressed: widget.onPressedReject,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.thumbsDown,
                                      color:
                                          ColorConstants.instance.iconOnColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(
                                      'Reddet',
                                      style: TextStyle(
                                        color:
                                            ColorConstants.instance.textOnColor,
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        )
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
