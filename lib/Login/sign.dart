import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:papape_store/Services/toast_service.dart';
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
                backgroundColor: ColorConstants.instance.primaryColor,
                confirmBtnColor: ColorConstants.instance.primaryColor,
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
                    color: ColorConstants.instance.primaryColor,
                  ),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 70.0,
                                        fontFamily: 'Armatic',
                                        fontWeight: FontWeight.bold),
                                    children: [
                                  TextSpan(
                                      text: 'Pa',
                                      style: TextStyle(
                                        color: ColorConstants
                                            .instance.inactiveColor,
                                      )),
                                  TextSpan(
                                      text: 'Pa',
                                      style: TextStyle(
                                        color: ColorConstants
                                            .instance.waitingColor,
                                      )),
                                  TextSpan(
                                      text: 'Pe',
                                      style: TextStyle(
                                        color:
                                            ColorConstants.instance.activeColor,
                                      ))
                                ]))),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.0),
                                topRight: Radius.circular(50.0)),
                            color: ColorConstants.instance.whiteContainer,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 30.0,
                                left: 30.0,
                                bottom: 20.0,
                                top: 70.0),
                            child: Column(
                              children: [
                                TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        icon:
                                            Icon(Icons.account_circle_outlined),
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
                                    padding: const EdgeInsets.only(top: 40.0),
                                    child: GradientButton(
                                      start:
                                          ColorConstants.instance.primaryColor,
                                      end: ColorConstants
                                          .instance.secondaryColor,
                                      buttonText: 'Kayıt Ol',
                                      fontFamily: 'Roboto',
                                      fontSize: 15,
                                      onPressed: signUp,
                                      icon: FontAwesomeIcons.save,
                                      widthMultiplier: 0.9,
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: GradientButton(
                                      start: ColorConstants
                                          .instance.signBackButtonSecondary,
                                      end: ColorConstants
                                          .instance.signBackButtonPrimary,
                                      buttonText: 'Geri',
                                      fontFamily: 'Roboto',
                                      fontSize: 15,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: FontAwesomeIcons.arrowLeft,
                                      widthMultiplier: 0.9,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ProgressWidget());
  }
}
