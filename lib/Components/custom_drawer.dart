import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Employees/employees.dart';
import 'package:papape_store/Login/login.dart';
import 'package:papape_store/Profile/profile.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Reports/report.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserProvider _userProvider;
  StoreProvider _storeProvider;

  exitYesNo(BuildContext context) {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Çıkmak istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _userProvider.free();
          _storeProvider.free();
          context.read<AuthService>().signOut().then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Login()));
          });
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  @override
  void didChangeDependencies() {
    _storeProvider = Provider.of<StoreProvider>(context);
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final User firebaseUser = context.watch<User>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: (_userProvider != null && _userProvider.name != null)
                ? Text(
                    'Hoşgeldiniz ${_userProvider.name},',
                    style: TextStyle(
                        color: ColorConstants.instance.textGold,
                        fontWeight: FontWeight.bold),
                  )
                : null,
            accountEmail: (firebaseUser != null)
                ? (firebaseUser.email != null && firebaseUser.email.isNotEmpty)
                    ? Text(firebaseUser.email)
                    : Text(firebaseUser.phoneNumber)
                : null,
            currentAccountPicture:
                (firebaseUser == null || firebaseUser.photoURL == null)
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstants.instance.whiteContainer,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50.0,
                          color: ColorConstants.instance.primaryColor,
                        ),
                      )
                    : CircleAvatar(
                        radius: 50.0,
                        backgroundImage: NetworkImage(firebaseUser.photoURL),
                        backgroundColor: Colors.transparent,
                      ),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              ColorConstants.instance.primaryColor,
              ColorConstants.instance.secondaryColor,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
          ),
          Visibility(
            visible: _userProvider != null && _userProvider.roles == 'owner',
            child: ListTile(
              leading: Icon(
                Icons.store,
                color: ColorConstants.instance.primaryColor,
              ),
              title: const Text('İşletme Bilgileri'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Profile()));
              },
            ),
          ),
          Visibility(
            visible: _userProvider != null && _userProvider.roles == 'owner',
            child: const Divider(
              thickness: 2,
            ),
          ),
          Visibility(
            visible: _userProvider != null && _userProvider.roles == 'owner',
            child: ListTile(
              leading: FaIcon(
                FontAwesomeIcons.chartBar,
                color: ColorConstants.instance.primaryColor,
              ),
              title: const Text('Rapor Listesi'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ReportView()));
              },
            ),
          ),
          Visibility(
            visible: _userProvider != null && _userProvider.roles == 'owner',
            child: ListTile(
              leading: Icon(
                Icons.list,
                color: ColorConstants.instance.primaryColor,
              ),
              title: const Text('Personel Listesi'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Employees()));
              },
            ),
          ),
          Visibility(
            visible: _userProvider != null && _userProvider.roles == 'owner',
            child: const Divider(
              thickness: 2,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.assignment_late,
              color: ColorConstants.instance.primaryColor,
            ),
            title: const Text('KVKK ve Gizlilik'),
          ),
          ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: ColorConstants.instance.primaryColor,
            ),
            title: const Text('Çıkış Yap'),
            onTap: () {
              exitYesNo(context);
            },
          ),
        ],
      ),
    );
  }
}
