import 'package:papape_store/Dashboard/dashboard.dart';
import 'package:papape_store/Login/login.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  await init();
  runApp(MyApp());
}

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  handleNotifications();
}

handleNotifications() async {
  await firebaseMessaging.requestPermission(sound: true);
  await firebaseMessaging.subscribeToTopic("stores");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoreProvider()),
        Provider<AuthService>(
            create: (context) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: MaterialApp(
          title: 'PaPaPe İşletme',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.lightBlue[800],
            primaryColorDark: Colors.black,
            accentColor: Colors.lightBlue[200],
            hintColor: Colors.grey.shade800,
          ),
          home: AuthWrapper()),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User firebaseUser = context.watch<User>();
    switch (firebaseUser != null && firebaseUser.emailVerified) {
      case true:
        return Dashboard();
        break;
      default:
        return Login();
    }
  }
}
