import 'package:bulb/Services/authentication_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Sign extends StatefulWidget {
  Sign({Key key}) : super(key: key);

  @override
  _SignState createState() => _SignState();
}

class _SignState extends State<Sign> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyController =
      TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisible = false;

  void signUp() {
    if (passwordController.text != passwordVerifyController.text) {
      ToastService().showError(
          'Girdiğiniz şifreler eşleşmemektedir ! Lütfen girdiğiniz şifreleri tekrar kontrol ediniz.',
          context);
      return;
    }
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      context
          .read<AuthService>()
          .signUp(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((value) {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.warning,
                title: '',
                text: value,
                showCancelBtn: false,
                backgroundColor: Theme.of(context).primaryColor,
                confirmBtnColor: Theme.of(context).primaryColor,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                barrierDismissible: false,
                confirmBtnText: 'Evet');
          })
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
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                      gradient: LinearGradient(colors: [
                    Theme.of(context).accentColor,
                    Theme.of(context).primaryColor
                  ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('bulb',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Armatic',
                                    shadows: <Shadow>[
                                      Shadow(
                                          color: Colors.black87,
                                          blurRadius: 20,
                                          offset: Offset(5.0, 5.0))
                                    ],
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            10)),
                            Text('" Bulunduğun lokasyona bak ! "',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                          color: Colors.black87,
                                          blurRadius: 20,
                                          offset: Offset(5.0, 5.0))
                                    ],
                                    fontFamily: 'Armatic',
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            30)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(blurRadius: 20, color: Colors.black)
                              ],
                              color: Colors.white,
                            ),
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
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          icon: Icon(
                                              Icons.account_circle_outlined),
                                          labelText: 'E-Posta'),
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
                                          labelText: 'Yeni Parola',
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: TextFormField(
                                      obscureText:
                                          (isVisible == false) ? true : false,
                                      controller: passwordVerifyController,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          icon: Icon(Icons.vpn_key_outlined),
                                          labelText: 'Yeni Parola (Tekrar)',
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).accentColor,
                                                Theme.of(context).primaryColor
                                              ],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft)),
                                      child: TextButton(
                                          onPressed: signUp,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FaIcon(FontAwesomeIcons.userPlus,
                                                  color: Colors.white),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text('Kayıt Ol',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(color: Colors.white),
              ));
  }
}
