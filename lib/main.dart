import 'package:bulovva_store/Auth/auth.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
          title: 'Bulovva İşletme',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.red[700],
            primaryColorDark: Colors.black,
            accentColor: Colors.red,
            hintColor: Colors.grey.shade800,
          ),
          home: AuthenticationWrapper()),
    );
  }
}
