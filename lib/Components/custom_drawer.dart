import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Login/login.dart';
import 'package:papape_store/Profile/profile.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key key}) : super(key: key);

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
          context.read<AuthService>().signOut().then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Login()));
          });
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  @override
  Widget build(BuildContext context) {
    final User firebaseUser = context.watch<User>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: (firebaseUser.displayName != null)
                ? Text(firebaseUser.displayName)
                : const Text('Kullanıcı'),
            accountEmail: Text(firebaseUser.email),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstants.instance.whiteContainer,
              ),
              child: Icon(
                Icons.person,
                size: 50.0,
                color: ColorConstants.instance.primaryColor,
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              ColorConstants.instance.primaryColor,
              ColorConstants.instance.secondaryColor,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
          ),
          ListTile(
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
          const Divider(
            thickness: 2,
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
