import 'package:bulb/Campaigns/campaign.dart';
import 'package:bulb/Components/bordered_button.dart';
import 'package:bulb/Components/campaign_card.dart';
import 'package:bulb/Components/not_found.dart';
import 'package:bulb/Models/camapign_model.dart';
import 'package:bulb/Providers/store_provider.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  'Kampanyalar',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30.0,
                      fontFamily: 'Armatic',
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: BorderedButton(
                    buttonText: 'Kampanya Yayınla',
                    borderColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      openDialog();
                    },
                    widthMultiplier: 0.7,
                  )),
              Flexible(
                child: StreamBuilder<List<Campaign>>(
                    stream: FirestoreService().getStoreCampaigns(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.active:
                          switch (
                              snapshot.hasData && snapshot.data.length > 0) {
                            case true:
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20.0),
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
                                notFoundIcon: FontAwesomeIcons.sadTear,
                                notFoundIconColor:
                                    Theme.of(context).primaryColor,
                                notFoundIconSize: 75,
                                notFoundText:
                                    'Şu an yayınlamış olduğunuz hiçbir kampanya bulunmamaktadır.',
                                notFoundTextColor:
                                    Theme.of(context).primaryColor,
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
                    }),
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
