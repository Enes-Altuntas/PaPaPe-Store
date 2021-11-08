import 'package:firebase_auth/firebase_auth.dart';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/wrapper.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Login/sign.dart';
import 'package:papape_store/Login/sign_personal.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisible = false;
  bool loginWithPhone = false;
  bool codeSent = false;
  String verificationCode;

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
                  MaterialPageRoute(builder: (context) => const AuthWrapper()));
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

  void verifyCode() async {
    setState(() {
      isLoading = true;
    });
    if (codeController.text.isNotEmpty) {
      if (verificationCode.isNotEmpty) {
        context
            .read<AuthService>()
            .verifyCodeAndUser(
                code: codeController.text.trim(),
                verification: verificationCode)
            .then((value) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()));
            })
            .onError(
                (error, stackTrace) => ToastService().showError(error, context))
            .whenComplete(() => setState(() {
                  isLoading = false;
                }));
      } else {
        ToastService()
            .showWarning('Telefonunuza tekrar kod istemelisiniz!', context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ToastService().showWarning('Doğrulama kodu boş olamaz!', context);
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

  void verifyPhone() async {
    setState(() {
      isLoading = true;
    });
    if (formkey.currentState.validate()) {
      FirebaseAuth firebaseAuth = context.read<AuthService>().getInstance();
      await firebaseAuth
          .verifyPhoneNumber(
              phoneNumber: '+90${phoneController.text.trim()}',
              verificationCompleted: (PhoneAuthCredential credential) async {
                setState(() {
                  isLoading = false;
                });
              },
              verificationFailed: (FirebaseAuthException exception) {
                setState(() {
                  isLoading = false;
                });
                if (exception.code == 'too-many-requests') {
                  ToastService().showError(
                      'İşleminiz, çok fazla denemeniz doğrultusunda engellendi tekrar deneyebilmek için lütfen bekleyiniz yada diğer giriş yöntemlerini deneyebilirsiniz.',
                      context);
                } else if (exception.code == "invalid-phone-number") {
                  ToastService().showError(
                      'Hatalı bir cep telefonu girdiniz, düzeltip tekrar deneyebilir yada diğer giriş yöntemlerini deneyebilirsiniz.',
                      context);
                } else {
                  ToastService().showError(
                      'SMS gönderilmesi sırasında bir hata oluştu! Girdiğiniz telefon numarasını kontrol edebilir yada diğer giriş yöntemlerini deneyebilirsiniz.',
                      context);
                }
              },
              codeSent: (String verificationId, [int forceResendingToken]) {
                setState(() {
                  isLoading = false;
                  verificationCode = verificationId;
                  codeSent = true;
                });
              },
              codeAutoRetrievalTimeout: (String verificationId) {})
          .timeout(const Duration(seconds: 60));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void googleSignIn() {
    context.read<AuthService>().googleLogin().then((value) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWrapper()));
    }).onError((error, stackTrace) {
      ToastService().showError(error, context);
    });
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

  String validatePhone(value) {
    if (value.isEmpty) {
      return "* Telefon Numarası zorunludur !";
    } else {
      return null;
    }
  }

  String validateCode(value) {
    if (value.isEmpty) {
      return "* Doğrulama kodu zorunludur !";
    } else {
      return null;
    }
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: ColorConstants.instance.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: (isLoading == false)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration:
                    BoxDecoration(color: ColorConstants.instance.primaryColor),
                child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 110.0),
                        child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    fontFamily: "Amatic",
                                    fontSize: 70.0,
                                    fontWeight: FontWeight.bold),
                                children: [
                              TextSpan(
                                  text: 'My',
                                  style: TextStyle(
                                      color:
                                          ColorConstants.instance.textOnColor)),
                              TextSpan(
                                  text: 'Rest',
                                  style: TextStyle(
                                      color: ColorConstants.instance.textGold)),
                            ])),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorConstants.instance.whiteContainer,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(50.0),
                                  topRight: Radius.circular(50.0))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 30.0, left: 30.0, top: 40.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: loginWithPhone && !codeSent,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: TextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: const InputDecoration(
                                              prefix: Text("+90"),
                                              icon: Icon(Icons.phone),
                                              labelText: 'Telefon Numarası'),
                                          validator: validatePhone),
                                    ),
                                  ),
                                  Visibility(
                                    visible: loginWithPhone && codeSent,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: PinPut(
                                        fieldsCount: 6,
                                        controller: codeController,
                                        validator: validateCode,
                                        submittedFieldDecoration:
                                            _pinPutDecoration.copyWith(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        selectedFieldDecoration:
                                            _pinPutDecoration,
                                        followingFieldDecoration:
                                            _pinPutDecoration.copyWith(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                            color: ColorConstants
                                                .instance.textGold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !loginWithPhone,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: TextFormField(
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                              icon: Icon(Icons
                                                  .account_circle_outlined),
                                              labelText: 'E-posta'),
                                          validator: validateMail),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !loginWithPhone,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: TextFormField(
                                        obscureText:
                                            (isVisible == false) ? true : false,
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                            icon: const Icon(
                                                Icons.vpn_key_outlined),
                                            labelText: 'Parola',
                                            suffixIcon: IconButton(
                                              icon: (isVisible == false)
                                                  ? const Icon(
                                                      Icons.visibility_off)
                                                  : const Icon(
                                                      Icons.visibility),
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              loginWithPhone = !loginWithPhone;
                                              codeSent = false;
                                              verificationCode = "";
                                            });
                                          },
                                          child: Text(
                                            (!loginWithPhone)
                                                ? 'Telefon ile Giriş Yap'
                                                : 'E-Mail ile Giriş Yap',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ColorConstants
                                                  .instance.primaryColor,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: !loginWithPhone,
                                          child: GestureDetector(
                                            onTap: rememberPass,
                                            child: Text(
                                              'Parolamı Unuttum !',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: ColorConstants
                                                    .instance.hintColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: GradientButton(
                                      buttonText: (loginWithPhone)
                                          ? (codeSent)
                                              ? 'Kodu Doğrula'
                                              : 'Doğrulama Kodu Al'
                                          : 'Giriş Yap',
                                      start:
                                          ColorConstants.instance.primaryColor,
                                      end: ColorConstants
                                          .instance.secondaryColor,
                                      icon: FontAwesomeIcons.signInAlt,
                                      onPressed: (loginWithPhone)
                                          ? (codeSent)
                                              ? verifyCode
                                              : verifyPhone
                                          : signIn,
                                      fontSize: 15,
                                      widthMultiplier: 0.9,
                                    ),
                                  ),
                                  Visibility(
                                    visible: !loginWithPhone,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: GradientButton(
                                        buttonText: 'Google İle Giriş Yap',
                                        start: ColorConstants
                                            .instance.signBackButtonSecondary,
                                        end: ColorConstants
                                            .instance.signBackButtonPrimary,
                                        icon: FontAwesomeIcons.google,
                                        onPressed: googleSignIn,
                                        fontSize: 15,
                                        widthMultiplier: 0.9,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Sign()));
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                              color: ColorConstants
                                                  .instance.hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text: 'Hesabınız yok mu? '),
                                              TextSpan(
                                                  text: 'Kayıt Olun!',
                                                  style: TextStyle(
                                                    color: ColorConstants
                                                        .instance.primaryColor,
                                                  ))
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SignPersonal()));
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: ColorConstants
                                                  .instance.hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text: 'Personel misiniz? '),
                                              TextSpan(
                                                  text: 'Kayıt Olun!',
                                                  style: TextStyle(
                                                    color: ColorConstants
                                                        .instance.textGold,
                                                  ))
                                            ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const ProgressWidget());
  }
}
