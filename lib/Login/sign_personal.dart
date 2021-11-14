import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/wrapper.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SignPersonal extends StatefulWidget {
  const SignPersonal({Key key}) : super(key: key);

  @override
  _SignPersonalState createState() => _SignPersonalState();
}

class _SignPersonalState extends State<SignPersonal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool personal = false;
  bool loginWithPhone = false;
  bool codeSent = false;
  String verificationCode;

  void verifyCode() async {
    setState(() {
      isLoading = true;
    });
    if (codeController.text.isNotEmpty) {
      if (verificationCode.isNotEmpty) {
        context
            .read<AuthService>()
            .saveEmployee(
                storeCode: storeController.text.trim(),
                name: nameController.text.trim(),
                code: codeController.text.trim(),
                verification: verificationCode,
                phone: phoneController.text.trim())
            .then((value) {
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthWrapper()));
        }).onError((error, stackTrace) {
          setState(() {
            isLoading = false;
          });
          ToastService().showError(error, context);
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ToastService()
            .showWarning('Telefonunuza tekrar kod istemelisiniz!', context);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ToastService().showWarning('Doğrulama kodu boş olamaz!', context);
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

  String validateStore(value) {
    if (value.isEmpty) {
      return "* İşletme Kodu zorunludur !";
    } else {
      return null;
    }
  }

  String validateName(value) {
    if (value.isEmpty) {
      return "* İsim-Soyisim zorunludur !";
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

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: ColorConstants.instance.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.instance.whiteContainer,
          iconTheme: IconThemeData(color: ColorConstants.instance.primaryColor),
          elevation: 0,
        ),
        body: (isLoading == false)
            ? SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: ColorConstants.instance.whiteContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 30.0, left: 30.0, bottom: 20.0),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/login_logo.png',
                              height: MediaQuery.of(context).size.height / 5),
                          Visibility(
                            visible: codeSent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: PinPut(
                                fieldsCount: 6,
                                controller: codeController,
                                submittedFieldDecoration:
                                    _pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                selectedFieldDecoration: _pinPutDecoration,
                                followingFieldDecoration:
                                    _pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: ColorConstants.instance.textGold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !codeSent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                validator: validateName,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.account_circle_outlined),
                                    labelText: 'Personel İsim-Soyisim'),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !codeSent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                validator: validatePhone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    prefixText: '+90',
                                    icon: Icon(Icons.phone),
                                    labelText: 'Telefon Numarası'),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !codeSent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextFormField(
                                controller: storeController,
                                keyboardType: TextInputType.text,
                                maxLength: 28,
                                validator: validateStore,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.store),
                                    labelText: 'İşletme Kodu'),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: GradientButton(
                                start: ColorConstants.instance.primaryColor,
                                end: ColorConstants.instance.secondaryColor,
                                buttonText: (!codeSent)
                                    ? 'Doğrulama Kodu Al'
                                    : 'Kodu Doğrula',
                                fontSize: 15,
                                onPressed:
                                    (!codeSent) ? verifyPhone : verifyCode,
                                icon: FontAwesomeIcons.signInAlt,
                                widthMultiplier: 0.9,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const ProgressWidget());
  }
}
