import 'package:papape_store/Models/employee_model.dart';
import 'package:papape_store/Models/store_model.dart';
import 'package:papape_store/Models/user_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel> get userInformation async {
    return await _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      return UserModel.fromFirestore(value.data());
    }).onError((error, stackTrace) => null);
  }

  getInstance() {
    return _firebaseAuth;
  }

  // Giriş
  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (_firebaseAuth.currentUser.emailVerified == false) {
        await _firebaseAuth.signOut();
        return 'Hesabınız henüz aktifleştirilmedi ! Mail kutunuzu kontrol ediniz !';
      }
      return 'Hoşgeldiniz !';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        throw 'Geçersiz kullanıcı adı veya şifre !';
      } else {
        throw 'Sistemde bir hata meydana geldi !';
      }
    }
  }

  Future googleLogin() async {
    GoogleSignInAccount user = await _googleSignIn.signIn();
    if (user == null) {
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await _firebaseAuth.signInWithCredential(credential);

      String role = "owner";
      await saveUser(_firebaseAuth.currentUser.displayName, role)
          .onError((error, stackTrace) {
        throw error;
      });
    }
  }

  // Kayıt
  Future<String> signUp({String name, String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firebaseAuth.currentUser.sendEmailVerification();

      String role = "owner";
      await saveUser(name, role);

      await _firebaseAuth.signOut();

      return "Kullancı kaydınız oluşturulmuştur. E-mail'inize girip hesabınızı aktifleştirebilirsiniz !";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ınvalıd-emaıl') {
        throw 'Kayıt olmak için geçersiz bir e-mail adresi girdiniz !';
      } else if (e.code == 'emaıl-already-ın-use') {
        throw 'Sistemde kayıtlı olan bir e-mail adresi girdiniz, eğer size ait ise "Şifremi Unuttum" seçeneğini deneyebilirsiniz !';
      } else if (e.code == 'weak-password') {
        throw 'Daha güçlü bir şifre girmelisiniz ! ';
      } else {
        throw 'Sistemde bir hata meydana geldi !';
      }
    }
  }

  Future<String> rememberPass({String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Şifrenizi yenilemeniz için link mail adresinize gönderilmiştir !';
    } catch (e) {
      throw 'Şifrenizi yenilemeniz için link mail adresinize gönderilmiştir !';
    }
  }

  Future verifyCodeAndUser({String code, String verification}) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verification, smsCode: code);

    await _firebaseAuth
        .signInWithCredential(phoneAuthCredential)
        .onError((error, stackTrace) {
      throw "Kullanıcı giriş işlemi sırasında bir hata meydana geldi!";
    });

    await _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      return UserModel.fromFirestore(value.data());
    }).onError((error, stackTrace) async {
      await _firebaseAuth.signOut();
      throw "Henüz bu telefon ile yapılmış olan bir kayıt bulunamamaktadır. Eğer kayıt olmadıysanız ilk önce kayıt olmanız gerekmektedir!";
    });
  }

  Future verifyCodeAndSaveUser(
      {String name, String code, String verification}) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verification, smsCode: code);

    await _firebaseAuth
        .signInWithCredential(phoneAuthCredential)
        .onError((error, stackTrace) {
      throw "Telefon ile giriş işlemi sırasında bir hata meydana geldi!";
    });

    String role = "owner";
    await saveUser(name, role);
  }

  Future saveEmployee(
      {String storeCode,
      String name,
      String code,
      String verification,
      String phone}) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verification, smsCode: code);

    await _firebaseAuth
        .signInWithCredential(phoneAuthCredential)
        .onError((error, stackTrace) {
      throw "Telefon ile kayıt işlemi sırasında bir hata meydana geldi!";
    });

    String role = "employee";
    await saveUserEmployee(name, storeCode, role, phone);
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      return e.message;
    }
  }

  Future<void> saveUser(String name, String role) async {
    UserModel user = await _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      return UserModel.fromFirestore(value.data());
    }).onError((error, stackTrace) => null);

    if (user == null) {
      UserModel newUser = UserModel(
          name: name,
          iToken: await FirebaseMessaging.instance.getToken(),
          token: null,
          userId: _firebaseAuth.currentUser.uid,
          favorites: [],
          storeId: _firebaseAuth.currentUser.uid,
          campaignCodes: [],
          roles: []);

      await _db
          .collection('users')
          .doc(_firebaseAuth.currentUser.uid)
          .set(newUser.toMap());
    } else {
      if (user.roles.contains("owner")) {
        return;
      } else if (user.roles.contains("employee")) {
        throw 'Personel kaydınız bulunmaktadır. İşletme sahibi olarak kayıt olamazsınız.';
      } else {
        user.roles.add("owner");

        String token = await FirebaseMessaging.instance.getToken();

        await _db
            .collection('users')
            .doc(_firebaseAuth.currentUser.uid)
            .update({
          'roles': user.roles,
          'iToken': token,
          'storeId': _firebaseAuth.currentUser.uid,
        });
      }
    }
  }

  Future<void> saveUserEmployee(
      String name, String storeCode, String role, String phone) async {
    UserModel user = await _db
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .get()
        .then((value) {
      return UserModel.fromFirestore(value.data());
    }).onError((error, stackTrace) => null);

    if (user != null && user.roles.contains("owner")) {
      throw 'İşletme sahibi olarak kaydınız bulunmaktadır. Personel olarak kayıt yaptıramazsınız.';
    } else if (user != null && user.roles.contains("employee")) {
      throw 'Personel kaydınız bulunmaktadır. Tekrar kayıt olamazsınız.';
    }

    if (user == null) {
      UserModel newUser = UserModel(
          name: name,
          iToken: await FirebaseMessaging.instance.getToken(),
          token: null,
          userId: _firebaseAuth.currentUser.uid,
          favorites: [],
          storeId: storeCode,
          campaignCodes: [],
          roles: []);

      newUser.roles.add("employee");

      await _db
          .collection('users')
          .doc(_firebaseAuth.currentUser.uid)
          .set(newUser.toMap())
          .onError((error, stackTrace) {
        throw 'Kullanıcı kaydınız oluşturulurken bir hata ile karşılaşıldı.';
      });
    } else {
      user.roles.add("employee");
      String token = await FirebaseMessaging.instance.getToken();

      await _db.collection('users').doc(_firebaseAuth.currentUser.uid).update({
        'roles': user.roles,
        'token': token,
        'storeId': storeCode,
      });
    }

    await _db.collection('stores').doc(storeCode).get().then((value) {
      return Store.fromFirestore(value.data());
    }).onError((error, stackTrace) {
      throw 'Girmiş olduğunuz işletme kodunda bir işletme bulunamamıştır.';
    });

    EmployeeModel newEmployee = EmployeeModel(
        employeeId: _firebaseAuth.currentUser.uid,
        name: name,
        phone: phone,
        storeId: storeCode);

    await _db
        .collection('stores')
        .doc(storeCode)
        .collection('employees')
        .doc(_firebaseAuth.currentUser.uid)
        .set(newEmployee.toMap())
        .onError((error, stackTrace) {
      throw 'Kaydınızı işletmeye eklerken bir hata ile karşılaşıldı.';
    });
  }
}
