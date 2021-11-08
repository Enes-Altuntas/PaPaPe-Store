import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Dashboard/dashboard.dart';
import 'package:papape_store/Login/login.dart';
import 'package:papape_store/Models/user_model.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  UserProvider _userProvider;
  User firebaseUser;

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    firebaseUser = context.watch<User>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseUser != null) {
      if ((firebaseUser.email != null && firebaseUser.emailVerified) ||
          firebaseUser.phoneNumber != null) {
        return FutureBuilder<UserModel>(
            future: context.read<AuthService>().userInformation,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  switch (snapshot.hasData) {
                    case true:
                      _userProvider.loadUserInfo(snapshot.data);
                      return const Dashboard(
                        defPage: 0,
                      );
                      break;
                    default:
                      return const ProgressWidget();
                  }
                  break;
                default:
                  return const ProgressWidget();
              }
            });
      } else {
        return const Login();
      }
    } else {
      return const Login();
    }
  }
}
