import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final firestoreService = FirestoreService();

  AuthService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  getUserId() {
    return _firebaseAuth.currentUser.uid;
  }

  // Giriş
  Future signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        throw 'Geçersiz kullanıcı adı veya şifre !';
      } else {
        throw 'Sistemde bir hata meydana geldi !';
      }
    }
  }

  // Kayıt
  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'Kullancı kaydınız oluşturulmuştur. Şimdi şirket bilgilerinizi doldurmaya başlayabilirsiniz !';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ınvalıd-emaıl') {
        throw 'Kayıt olmak için geçersiz bir e-mail adresi girdiniz !';
      } else if (e.code == 'emaıl-already-ın-use') {
        throw 'Sistemde kayıtlı olan bir e-mail adresi girdiniz, eğer size ait ise "Şifremi Unuttum" seçeneğini deneyebilirsiniz !';
      } else {
        throw 'Sistemde bir hata meydana geldi !';
      }
    }
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      return e.message;
    }
  }
}
