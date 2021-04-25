import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;

  void signIn() {
    setState(() {
      isLoading = true;
    });
    if (formkey.currentState.validate()) {
      context
          .read<AuthService>()
          .signIn(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    }
  }

  void signUp() {
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      context
          .read<AuthService>()
          .signUp(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    }
  }

  String validateMail(value) {
    if (value.isEmpty) {
      return "* E-mail zorunludur !";
    } else {
      return null;
    }
  }

  String validatePass(value) {
    if (value.isEmpty) {
      return "* Şifre zorunludur !";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (isLoading == false)
            ? SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/istanbul.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.8),
                              BlendMode.hardLight))),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 6,
                            child: Image.asset(
                              'assets/images/logos.png',
                              fit: BoxFit.cover,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 20, color: Colors.black)
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 20.0,
                                    left: 20.0,
                                    bottom: 20.0,
                                    top: 20.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'E-Mail'),
                                        validator: validateMail),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Şifre'),
                                        validator: validatePass,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 50.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: ElevatedButton(
                                            onPressed: signIn,
                                            child: Text('Giriş Yap'),
                                            style: ElevatedButton.styleFrom(
                                                primary:
                                                    Colors.green.shade800)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: ElevatedButton(
                                            onPressed: signUp,
                                            child: Text('Kayıt Ol',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark)),
                                            style: ElevatedButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .accentColor)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).accentColor,
                ),
              ));
  }
}
