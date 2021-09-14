import 'package:papape_store/Components/wish_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Models/wishes_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Reports extends StatefulWidget {
  Reports({Key key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
          child: Text(
            'Dilek ve şikayet',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 30.0,
                fontFamily: 'Armatic',
                fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
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
                                ));
                          },
                        );
                        break;
                      default:
                        return NotFound(
                          notFoundIcon: FontAwesomeIcons.smileBeam,
                          notFoundIconColor: Theme.of(context).primaryColor,
                          notFoundIconSize: 75,
                          notFoundText:
                              'Henüz işletmeniz adına hazırlanmış dilek veya şikayet bulunmamaktadır !',
                          notFoundTextColor: Theme.of(context).primaryColor,
                          notFoundTextSize: 30.0,
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
      ],
    );
  }
}
