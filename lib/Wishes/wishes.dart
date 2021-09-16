import 'package:papape_store/Components/wish_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Models/wishes_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Reports extends StatefulWidget {
  Reports({Key key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  makePhoneCall(userPhone) async {
    await launch("tel:$userPhone");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dilek ve şikayet',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 30.0,
                    fontFamily: 'Armatic',
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0))),
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: StreamBuilder<List<WishesModel>>(
                stream: FirestoreService().getReports(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      switch (snapshot.hasData && snapshot.data.length > 0) {
                        case true:
                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CommentCard(
                                    wish: snapshot.data[index],
                                    onPressedCall: () {
                                      makePhoneCall(
                                          snapshot.data[index].wishUserPhone);
                                    },
                                  ));
                            },
                          );
                          break;
                        default:
                          return NotFound(
                            notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                            notFoundIconColor: Colors.amber[900],
                            notFoundIconSize: 60,
                            notFoundText:
                                'Henüz işletmeniz adına hazırlanmış dilek veya şikayet bulunmamaktadır !',
                            notFoundTextColor: Theme.of(context).primaryColor,
                            notFoundTextSize: 40.0,
                          );
                      }
                      break;
                    default:
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
