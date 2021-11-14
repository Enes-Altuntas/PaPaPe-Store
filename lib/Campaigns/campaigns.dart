import 'package:papape_store/Campaigns/campaign.dart';
import 'package:papape_store/Components/campaign_card.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Campaigns extends StatefulWidget {
  const Campaigns({Key key}) : super(key: key);

  @override
  _CampaignsState createState() => _CampaignsState();
}

class _CampaignsState extends State<Campaigns> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  UserProvider _userProvider;
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
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: StreamBuilder<List<Campaign>>(
                stream:
                    FirestoreService().getStoreCampaigns(_userProvider.storeId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                        case true:
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: CampaignCard(
                                      campaign: snapshot.data[index],
                                      onPressed: () {
                                        if (_userProvider.roles
                                            .contains("owner")) {
                                          setState(() {
                                            _selectedCampaign =
                                                snapshot.data[index];
                                          });
                                          openDialog();
                                        } else {
                                          ToastService().showWarning(
                                              'Bu işlemi gerçekleştirmeye yetkiniz bulunmamaktadır.',
                                              context);
                                        }
                                      },
                                    ),
                                  );
                                }),
                          );
                          break;
                        default:
                          return NotFound(
                            notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                            notFoundIconColor:
                                ColorConstants.instance.primaryColor,
                            notFoundText:
                                'Şu an yayınlanmış kampanya bulunmamaktadır.',
                            notFoundTextColor:
                                ColorConstants.instance.hintColor,
                          );
                      }
                      break;
                    default:
                      return const ProgressWidget();
                  }
                }),
          )
        : const ProgressWidget();
  }
}
