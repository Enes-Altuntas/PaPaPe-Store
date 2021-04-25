import 'package:cool_alert/cool_alert.dart';

class ToastService {
  showSuccess(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Tebrikler !',
      type: CoolAlertType.success,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }

  showWarning(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Dikkat !',
      type: CoolAlertType.warning,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }

  showError(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Hata !',
      type: CoolAlertType.error,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }

  showInfo(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Bilgilendirme !',
      type: CoolAlertType.info,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }
}
