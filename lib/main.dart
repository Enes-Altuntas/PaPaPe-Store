import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Dashboard/dashboard.dart';
import 'package:papape_store/Login/login.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void main() async {
  await initState();
  runApp(MyApp());
}

Future<void> initState() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  handleNotifications();
}

handleNotifications() async {
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data["route"];
    navigatorKey.currentState.pushNamed(route);
  });

  await firebaseMessaging.subscribeToTopic("stores");
  await firebaseMessaging.requestPermission(sound: true);
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
            initialData: null,
            create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: MaterialApp(
        title: 'PaPaPe İşletme',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          cardTheme: CardTheme(
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  color: ColorConstants.instance.primaryColor,
                  width: 2.0,
                ),
              ),
              color: ColorConstants.instance.whiteContainer),
        ),
        home: AuthWrapper(),
        routes: {
          "reservations": (_) => Dashboard(
                defPage: 3,
              ),
          "campaigns": (_) => Dashboard(
                defPage: 0,
              ),
          "wishes": (_) => Dashboard(defPage: 2),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User firebaseUser = context.watch<User>();
    switch (firebaseUser != null && firebaseUser.emailVerified) {
      case true:
        return Dashboard(
          defPage: 0,
        );
        break;
      default:
        return Login();
    }
  }
}
