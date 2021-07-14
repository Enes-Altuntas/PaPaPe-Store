import 'package:bulb/Campaigns/campaign.dart';
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                      child: Text("Kampanya Yayınla".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side: BorderSide(
                                          width: 2,
                                          color: Theme.of(context)
                                              .primaryColor)))),
                      onPressed: () {
                        openDialog();
                      }),
                ),
              ),
              Flexible(
                child: StreamBuilder<List<Campaign>>(
                  stream: FirestoreService().getStoreCampaigns(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.active)
                        ? (snapshot.data != null && snapshot.data.length != 0)
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        color: Colors.white,
                                        shadowColor: Colors.black,
                                        elevation: 5.0,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedCampaign =
                                                  snapshot.data[index];
                                            });
                                            openDialog();
                                          },
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3.5,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            colors: [
                                                          Theme.of(context)
                                                              .accentColor,
                                                          Theme.of(context)
                                                              .primaryColor
                                                        ],
                                                            begin: Alignment
                                                                .centerRight,
                                                            end: Alignment
                                                                .centerLeft)),
                                                    child: (snapshot.data[index]
                                                                .campaignPicRef !=
                                                            null)
                                                        ? Image.network(
                                                            snapshot.data[index]
                                                                .campaignPicRef,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                            return loadingProgress ==
                                                                    null
                                                                ? child
                                                                : Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  );
                                                          }, fit: BoxFit.fill)
                                                        : Center(
                                                            child: Text(
                                                                'Kampanya Resmi Yok',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        'Bebas',
                                                                    fontSize:
                                                                        20.0)),
                                                          ),
                                                  ),
                                                  Positioned(
                                                      right: 20.0,
                                                      top: 20.0,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                  Theme.of(
                                                                          context)
                                                                      .accentColor,
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                ],
                                                                begin: Alignment
                                                                    .centerRight,
                                                                end: Alignment
                                                                    .centerLeft),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50.0)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .visibility,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .campaignCounter
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            20)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )),
                                                  Positioned(
                                                      top: 20.0,
                                                      left: 20.0,
                                                      child: (snapshot
                                                                  .data[index]
                                                                  .campaignStatus ==
                                                              'active')
                                                          ? Container(
                                                              height: 40.0,
                                                              width: 40.0,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0)),
                                                              child: Center(
                                                                child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .checkCircle,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )
                                                          : (snapshot
                                                                      .data[
                                                                          index]
                                                                      .campaignStatus ==
                                                                  'inactive')
                                                              ? Container(
                                                                  height: 40.0,
                                                                  width: 40.0,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .red[
                                                                          600],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0)),
                                                                  child: Center(
                                                                    child: FaIcon(
                                                                        FontAwesomeIcons
                                                                            .ban,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  height: 40.0,
                                                                  width: 40.0,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .amber[
                                                                          600],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0)),
                                                                  child: Center(
                                                                    child: FaIcon(
                                                                        FontAwesomeIcons
                                                                            .hourglassHalf,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ))
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0,
                                                    right: 20.0,
                                                    top: 20.0),
                                                child: Text(
                                                    snapshot.data[index]
                                                        .campaignTitle,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                    snapshot.data[index]
                                                        .campaignDesc,
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Theme.of(context)
                                                                .accentColor,
                                                            Theme.of(context)
                                                                .primaryColor
                                                          ],
                                                          begin: Alignment
                                                              .centerRight,
                                                          end: Alignment
                                                              .centerLeft)),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10.0,
                                                                bottom: 5.0),
                                                        child: Text(
                                                            'Kampanya Başlangıç : ${formatDate(snapshot.data[index].campaignStart)}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: Text(
                                                            'Kampanya Bitiş : ${formatDate(snapshot.data[index].campaignFinish)}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10.0,
                                                                bottom: 10.0),
                                                        child: Text(
                                                            '#${snapshot.data[index].campaignKey.toUpperCase()}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.0,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.assignment_late_outlined,
                                          size: 100.0,
                                          color:
                                              Theme.of(context).primaryColor),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          'Henüz yayınlamış olduğunuz herhangi bir kampanya bulunmamaktadır !',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                  },
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
