import 'package:papape_store/Campaigns/campaign.dart';
import 'package:papape_store/Components/bordered_button.dart';
import 'package:papape_store/Components/campaign_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Campaigns extends StatefulWidget {
  Campaigns({Key key}) : super(key: key);

  @override
  _CampaignsState createState() => _CampaignsState();
}

class _CampaignsState extends State<Campaigns> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  Campaign _selectedCampaign;
  StoreProvider _storeProvider;
  bool isLoading = false;

  openDialog() async {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kampanya yayınlamadan önce profil sayfasına giderek bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) =>
                CampaignSingle(campaignData: _selectedCampaign)))
        .whenComplete(() {
      setState(() {
        _selectedCampaign = null;
      });
    });
  }

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Column(
            children: [
              SizedBox(
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kampanyalar',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                          fontFamily: 'Armatic',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: BorderedButton(
                    buttonText: 'Kampanya Yayınla',
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: () {
                      openDialog();
                    },
                    widthMultiplier: 0.7,
                  )),
              Flexible(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: StreamBuilder<List<Campaign>>(
                        stream: FirestoreService().getStoreCampaigns(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.active:
                              switch (snapshot.hasData &&
                                  snapshot.data.length > 0) {
                                case true:
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: CampaignCard(
                                              campaign: snapshot.data[index],
                                              onPressed: () {
                                                setState(() {
                                                  _selectedCampaign =
                                                      snapshot.data[index];
                                                });
                                                openDialog();
                                              },
                                            ),
                                          );
                                        }),
                                  );
                                  break;
                                default:
                                  return NotFound(
                                    notFoundIcon:
                                        FontAwesomeIcons.exclamationTriangle,
                                    notFoundIconColor: Colors.amber[900],
                                    notFoundIconSize: 60,
                                    notFoundText:
                                        'Şu an yayınlamış olduğunuz hiçbir kampanya bulunmamaktadır.',
                                    notFoundTextColor:
                                        Theme.of(context).primaryColor,
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
                        }),
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
  }
}
