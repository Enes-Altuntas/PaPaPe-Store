import 'dart:ui';

import 'package:bulb/Campaigns/campaigns.dart';
import 'package:bulb/Wishes/wishes.dart';
import 'package:bulb/Login/login.dart';
import 'package:bulb/Models/store_model.dart';
import 'package:bulb/Products/products.dart';
import 'package:bulb/Profile/profile.dart';
import 'package:bulb/Providers/store_provider.dart';
import 'package:bulb/Reservations/reservations.dart';
import 'package:bulb/Services/authentication_service.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StoreProvider _storeProvider;
  Future getUserInfo;
  bool isInit = true;
  bool isLoading = false;

  exitYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Çıkmak istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _storeProvider.free();
          context.read<AuthService>().signOut().then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Login()));
          });
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  Future<void> didChangeDependencies() async {
    if (isInit) {
      _storeProvider = Provider.of<StoreProvider>(context);
      getUserInfo = _getStoreInfo();
      setState(() {
        isInit = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<Store> _getStoreInfo() async {
    Store _store;
    setState(() {
      isLoading = true;
    });

    await FirestoreService()
        .getStore()
        .then((value) => {
              if (value != null && value.data() != null)
                {_store = Store.fromFirestore(value.data())}
            })
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));

    if (_store != null) {
      _storeProvider.loadStoreInfo(_store);
    }
    return _store;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Profile()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
          ),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: 'Bebas',
              fontSize: 15.0,
            ),
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                icon: FaIcon(FontAwesomeIcons.tags),
              ),
              Tab(
                icon: FaIcon(FontAwesomeIcons.bookOpen),
              ),
              Tab(
                icon: FaIcon(FontAwesomeIcons.bullhorn),
              ),
              Tab(
                icon: FaIcon(FontAwesomeIcons.bell),
              ),
            ],
          ),
          title: Text('bulb',
              style: TextStyle(
                  fontSize: 45.0,
                  color: Colors.white,
                  fontFamily: 'Armatic',
                  fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                  onPressed: () {
                    exitYesNo();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      )
                    ],
                  )),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
          child: FutureBuilder(
              future: getUserInfo,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return (snapshot.connectionState == ConnectionState.done)
                    ? (isLoading == false)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(50.0),
                                              topRight: Radius.circular(50.0))),
                                      child: TabBarView(
                                        children: [
                                          Campaigns(),
                                          Menu(),
                                          Reports(),
                                          Reservation()
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                    : Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
              }),
        ),
      ),
    );
  }
}
