import 'package:bulb/Models/reservations_model.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Reservation extends StatefulWidget {
  Reservation({Key key}) : super(key: key);

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  bool btnVis = true;

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  makePhoneCall(storePhone) async {
    await launch("tel:$storePhone");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: StreamBuilder<List<Reservations>>(
        stream: FirestoreService().getReservations(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.active)
              ? (snapshot.data.length > 0)
                  ? ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 5.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Theme.of(context).accentColor,
                                    Theme.of(context).primaryColor
                                  ],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft)),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    snapshot.data[index].reservationDesc,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Rezerve kişi sayısı: ${snapshot.data[index].reservationCount.toString()}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'İsim-Soyisim: ${snapshot.data[index].reservationName}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Başvuru Durumu: ${(snapshot.data[index].reservationStatus == 'waiting') ? 'Beklemede' : (snapshot.data[index].reservationStatus == 'aproved') ? 'Onaylanmış' : 'Reddedilmiş'}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                            'Rezervasyon Saati: ${formatDate(snapshot.data[index].reservationTime)}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0)),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50.0))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                                onPressed: () {
                                                  makePhoneCall(snapshot
                                                      .data[index]
                                                      .reservationPhone);
                                                },
                                                child: Text(
                                                  'Telefon: +90${snapshot.data[index].reservationPhone}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                )),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Visibility(
                                            visible: snapshot.data[index]
                                                        .reservationStatus ==
                                                    'waiting'
                                                ? true
                                                : false,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50.0))),
                                                    child: IconButton(
                                                        onPressed: () {},
                                                        icon: FaIcon(
                                                            FontAwesomeIcons
                                                                .thumbsUp,
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.red[400],
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50.0))),
                                                    child: IconButton(
                                                        onPressed: () {},
                                                        icon: FaIcon(
                                                            FontAwesomeIcons
                                                                .thumbsDown,
                                                            color:
                                                                Colors.white)),
                                                  )
                                                ])),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 100.0,
                            color: Theme.of(context).primaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Henüz işletmeniz adına herhangi bir rezervasyon bulunmamaktadır !',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25.0,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ));
        },
      ),
    );
  }
}
