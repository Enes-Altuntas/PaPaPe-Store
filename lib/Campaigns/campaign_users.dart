import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/campaign_user.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:provider/provider.dart';

class CampaignUsers extends StatefulWidget {
  final String campaignId;

  const CampaignUsers({Key key, this.campaignId}) : super(key: key);

  @override
  _CampaignUsersState createState() => _CampaignUsersState();
}

class _CampaignUsersState extends State<CampaignUsers> {
  bool isLoading = false;
  UserProvider _userProvider;
  final TextEditingController search = TextEditingController();
  String _search;

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              toolbarHeight: 70.0,
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
              title: const TitleWidget(),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: StreamBuilder<List<CampaignUserModel>>(
                  stream: FirestoreService().getCampaignUsers(
                      _userProvider.storeId, widget.campaignId),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                        switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                          case true:
                            return Column(
                              children: [
                                SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: TextFormField(
                                      controller: search,
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _search = search.text;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.search,
                                                color: ColorConstants
                                                    .instance.primaryColor,
                                              )),
                                          labelText: 'Arama (İsim-Soyisim)',
                                          border: const OutlineInputBorder()),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, index) {
                                        if (_search != null &&
                                            _search.isNotEmpty) {
                                          if (snapshot.data[index].userName
                                              .toLowerCase()
                                              .contains(
                                                  _search.toLowerCase())) {
                                            return SizedBox(
                                              height: 100,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                    color: ColorConstants
                                                        .instance.hintColor,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              'Müşteri İsim-Soyisim: ${snapshot.data[index].userName}',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "Montserrat",
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: snapshot
                                                                        .data[
                                                                            index]
                                                                        .scanned !=
                                                                    null &&
                                                                snapshot
                                                                    .data[index]
                                                                    .scanned,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          20.0,
                                                                      top:
                                                                          10.0),
                                                              child: Text(
                                                                'Personel: ${snapshot.data[index].scannedByName}',
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontSize:
                                                                        10.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 20.0),
                                                        child: (snapshot
                                                                .data[index]
                                                                .scanned)
                                                            ? Icon(
                                                                Icons.check_box,
                                                                size: 30,
                                                                color: ColorConstants
                                                                    .instance
                                                                    .activeColor,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .check_box_outline_blank,
                                                                size: 30,
                                                                color: ColorConstants
                                                                    .instance
                                                                    .inactiveColor,
                                                              ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        } else {
                                          return SizedBox(
                                            height: 100,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                side: BorderSide(
                                                  color: ColorConstants
                                                      .instance.hintColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            'Müşteri İsim-Soyisim: ${snapshot.data[index].userName}',
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    "Montserrat",
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: snapshot
                                                                      .data[
                                                                          index]
                                                                      .scanned !=
                                                                  null &&
                                                              snapshot
                                                                  .data[index]
                                                                  .scanned,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0,
                                                                    top: 10.0),
                                                            child: Text(
                                                              'Personel: ${snapshot.data[index].scannedByName}',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "Montserrat",
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20.0),
                                                      child: (snapshot
                                                              .data[index]
                                                              .scanned)
                                                          ? Icon(
                                                              Icons.check_box,
                                                              size: 30,
                                                              color: ColorConstants
                                                                  .instance
                                                                  .activeColor,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .check_box_outline_blank,
                                                              size: 30,
                                                              color: ColorConstants
                                                                  .instance
                                                                  .inactiveColor,
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            );
                            break;
                          default:
                            return NotFound(
                              notFoundIcon:
                                  FontAwesomeIcons.exclamationTriangle,
                              notFoundIconColor:
                                  ColorConstants.instance.primaryColor,
                              notFoundText:
                                  'Şu an bu kampanyayı kullanan hiçbir kullanıcı bulunmamaktadır.',
                              notFoundTextColor:
                                  ColorConstants.instance.hintColor,
                            );
                        }
                        break;
                      default:
                        return const ProgressWidget();
                    }
                  }),
            ),
          )
        : const ProgressWidget();
  }
}
