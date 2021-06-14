import 'package:bulovva_store/Dashboard/dashboard.dart';
import 'package:bulovva_store/Login/sign.dart';
import 'package:bulovva_store/Services/authentication_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isInit = true;

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
          .then((value) {
            if (FirebaseAuth.instance.currentUser != null &&
                FirebaseAuth.instance.currentUser.emailVerified) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Dashboard()));
            } else {
              ToastService().showError(value, context);
            }
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Sign()));
  }

  void googleSignIn() {
    setState(() {
      isLoading = true;
    });
    context
        .read<AuthService>()
        .googleLogin()
        .then((value) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Dashboard()));
        })
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (isInit) {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser.reload();
      }
      setState(() {
        isInit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (FirebaseAuth.instance.currentUser != null &&
            FirebaseAuth.instance.currentUser.emailVerified)
        ? Dashboard()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            body: (isLoading == false)
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red[600], Colors.purple[500]],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft)),
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
                                      fontFamily: 'Dancing',
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
                                      fontFamily: 'Dancing',
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
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 20, color: Colors.black87)
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 30.0,
                                    left: 30.0,
                                    bottom: 20.0,
                                    top: 30.0),
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
                                            labelText: 'E-posta'),
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
                                            labelText: 'Parola',
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
                                              'Parolamı Unuttum !',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[600],
                                                  Colors.purple[500]
                                                ],
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft)),
                                        child: TextButton(
                                          onPressed: signIn,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.signInAlt,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  'Giriş Yap',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[600],
                                                  Colors.purple[500]
                                                ],
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft)),
                                        child: TextButton(
                                          onPressed: googleSignIn,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.googlePlusG,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                    'Google İle Giriş Yap',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[600],
                                                  Colors.purple[500]
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
                                          ),
                                        ),
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
                  )
                : Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white),
                  ));
  }
}
