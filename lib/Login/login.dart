import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool isVisible = false;

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
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void rememberPass() {
    setState(() {
      isLoading = true;
    });
    if (emailController.text.isEmpty != true) {
      context
          .read<AuthService>()
          .rememberPass(email: emailController.text.trim())
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    } else {
      ToastService().showWarning('Lütfen e-mail hesabınızı giriniz !', context);
      setState(() {
        isLoading = false;
      });
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
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void googleSignIn() {
    setState(() {
      isLoading = true;
    });
    context
        .read<AuthService>()
        .googleLogin()
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
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

  AssetImage myImage;

  @override
  void initState() {
    super.initState();
    myImage = AssetImage('assets/images/icon.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (isLoading == false)
            ? SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).primaryColor,
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/icon.png"),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
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
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            icon: Icon(
                                                Icons.account_circle_outlined),
                                            labelText: 'E-Mail'),
                                        validator: validateMail),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: TextFormField(
                                        obscureText:
                                            (isVisible == false) ? true : false,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            icon: Icon(Icons.vpn_key_outlined),
                                            labelText: 'Şifre',
                                            suffixIcon: IconButton(
                                              icon: (isVisible == false)
                                                  ? Icon(Icons.visibility_off)
                                                  : Icon(Icons.visibility),
                                              onPressed: () {
                                                if (isVisible == true) {
                                                  setState(() {
                                                    isVisible = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    isVisible = true;
                                                  });
                                                }
                                              },
                                            )),
                                        validator: validatePass,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: rememberPass,
                                            child: Text(
                                              'Şifremi Unuttum !',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: ElevatedButton(
                                            onPressed: signIn,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                    FontAwesomeIcons.signInAlt),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: Text('Giriş Yap'),
                                                ),
                                              ],
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                primary:
                                                    Colors.green.shade800)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: ElevatedButton(
                                            onPressed: googleSignIn,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(FontAwesomeIcons
                                                    .googlePlusG),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: Text(
                                                      'Google İle Giriş Yap'),
                                                ),
                                              ],
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                primary:
                                                    Colors.green.shade800)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30.0),
                                      child: Text(
                                        'Henüz hesabın yok mu ?',
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.w500),
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                    FontAwesomeIcons.userPlus),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: Text('Kayıt Ol',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.amber[900])),
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
                child: CircularProgressIndicator(backgroundColor: Colors.white),
              ));
  }
}
