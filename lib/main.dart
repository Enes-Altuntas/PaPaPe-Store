import 'package:bulovva_store/Login/login.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
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
  await firebaseMessaging.requestPermission();
  await firebaseMessaging.subscribeToTopic("isletmeler");
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
          title: 'Bulb İşletme',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.purple,
            primaryColorDark: Colors.black,
            accentColor: Colors.red[600],
            hintColor: Colors.grey.shade800,
          ),
          home: Login()),
    );
  }
}
