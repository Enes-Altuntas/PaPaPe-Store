import 'package:papape_store/Components/wrapper.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Dashboard/dashboard.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void main() async {
  await initState();
  runApp(const MyApp());
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
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoreProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider<AuthService>(
            create: (context) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            initialData: null,
            create: (context) => context.read<AuthService>().authStateChanges),
      ],
      child: MaterialApp(
        title: 'MyRest',
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        supportedLocales: const [Locale('en', 'EN'), Locale('tr', 'TR')],
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          scaffoldBackgroundColor: ColorConstants.instance.whiteContainer,
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
        home: const AuthWrapper(),
        routes: {
          "reservations": (_) => const Dashboard(
                defPage: 3,
              ),
          "campaigns": (_) => const Dashboard(
                defPage: 0,
              ),
          "wishes": (_) => const Dashboard(defPage: 2),
        },
      ),
    );
  }
}
