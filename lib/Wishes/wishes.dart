import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/wish_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/wishes_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Reports extends StatefulWidget {
  const Reports({Key key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  makePhoneCall(userPhone) async {
    await launch("tel:$userPhone");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: StreamBuilder<List<WishesModel>>(
        stream: FirestoreService().getReports(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                case true:
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CommentCard(
                            wish: snapshot.data[index],
                            onPressedCall: () {
                              makePhoneCall(snapshot.data[index].wishUserPhone);
                            },
                          ));
                    },
                  );
                  break;
                default:
                  return NotFound(
                    notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                    notFoundIconColor: ColorConstants.instance.primaryColor,
                    notFoundIconSize: 50,
                    notFoundText:
                        'Henüz işletmeniz adına hazırlanmış dilek veya şikayet bulunmamaktadır !',
                    notFoundTextColor: ColorConstants.instance.hintColor,
                    notFoundTextSize: 30.0,
                  );
              }
              break;
            default:
              return const ProgressWidget();
          }
        },
      ),
    );
  }
}
