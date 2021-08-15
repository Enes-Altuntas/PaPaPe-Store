import 'package:bulb/Components/gradient_button.dart';
import 'package:bulb/Dashboard/dashboard.dart';
import 'package:bulb/Login/sign.dart';
import 'package:bulb/Services/authentication_service.dart';
import 'package:bulb/Services/toast_service.dart';
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
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text('bulb',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: 'Armatic',
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            10)),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                                color: Colors.amber[200],
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
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
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
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .hintColor),
                                          )),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: GradientButton(
                                      buttonText: 'Giriş Yap',
                                      icon: FontAwesomeIcons.signInAlt,
                                      onPressed: signIn,
                                      fontFamily: 'Roboto',
                                      fontSize: 15,
                                      widthMultiplier: 0.9,
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: GradientButton(
                                        buttonText: 'Google',
                                        icon: FontAwesomeIcons.googlePlusG,
                                        onPressed: googleSignIn,
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        widthMultiplier: 0.9,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: TextButton(
                                      onPressed: signUp,
                                      child: Text(
                                        'Hesabınız yok mu ? Kayıt Olun !',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ));
  }
}
