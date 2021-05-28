import 'package:bulovva_store/Campaigns/campaigns.dart';
import 'package:bulovva_store/Comments/comments.dart';
import 'package:bulovva_store/Login/login.dart';
import 'package:bulovva_store/Models/store_model.dart';
import 'package:bulovva_store/Products/products.dart';
import 'package:bulovva_store/Profile/profile.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  StoreProvider _storeProvider;
  Future getUserInfo;
  List<Widget> _widgets = <Widget>[Campaigns(), Menu(), Reports(), Profile()];
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text('Bulovva İşletme',
            style: TextStyle(
                fontSize: 25.0,
                fontFamily: 'Bebas',
                color: Theme.of(context).primaryColor)),
        actions: [
          TextButton(
              onPressed: () {
                exitYesNo();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              )),
        ],
      ),
      body: FutureBuilder(
          future: getUserInfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return (snapshot.connectionState == ConnectionState.done)
                ? (isLoading == false)
                    ? SafeArea(
                        child: _widgets.elementAt(_currentIndex),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  );
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        unselectedIconTheme:
            IconThemeData(color: Theme.of(context).primaryColor, size: 20),
        selectedIconTheme: IconThemeData(color: Colors.red, size: 35),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart), label: 'Kampanyalar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.art_track), label: 'Ürünler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.campaign), label: 'Yorumlar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
