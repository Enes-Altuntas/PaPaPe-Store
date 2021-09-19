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
  print(await firebaseMessaging.getToken());
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
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primaryColor: Colors.lightBlue[800],
          primaryColorDark: Colors.black,
          accentColor: Colors.lightBlue[200],
          hintColor: Colors.grey.shade800,
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
