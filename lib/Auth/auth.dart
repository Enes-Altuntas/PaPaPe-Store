import 'package:bulovva_store/Campaigns/campaigns.dart';
import 'package:bulovva_store/Comments/comments.dart';
import 'package:bulovva_store/Login/login.dart';
import 'package:bulovva_store/Products/products.dart';
import 'package:bulovva_store/Profile/profile.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationWrapper extends StatefulWidget {
  AuthenticationWrapper({Key key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  int _currentIndex = 0;
  StoreProvider _storeProvider;
  List<Widget> _widgets = <Widget>[Profile(), Campaigns(), Menu(), Reports()];

  @override
  Widget build(BuildContext context) {
    final _firebaseUser = context.watch<User>();
    _storeProvider = Provider.of<StoreProvider>(context);
    return (_firebaseUser != null && _firebaseUser.emailVerified)
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Bulovva İşletme',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Bebas',
                      color: Theme.of(context).primaryColor)),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      _storeProvider.free();
                      context.read<AuthService>().signOut();
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
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: _widgets.elementAt(_currentIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              unselectedIconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor, size: 20),
              selectedIconTheme: IconThemeData(color: Colors.red, size: 35),
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Profil'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_shopping_cart), label: 'Kampanyalar'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.art_track), label: 'Ürünler'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.campaign), label: 'Yorumlar'),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          )
        : Login();
  }
}
