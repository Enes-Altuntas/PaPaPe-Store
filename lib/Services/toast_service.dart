import 'package:cool_alert/cool_alert.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class ToastService {
  showSuccess(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Tebrikler !',
      backgroundColor: ColorConstants.instance.primaryColor,
      confirmBtnColor: ColorConstants.instance.primaryColor,
      barrierDismissible: false,
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
      backgroundColor: ColorConstants.instance.primaryColor,
      confirmBtnColor: ColorConstants.instance.primaryColor,
      barrierDismissible: false,
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
      backgroundColor: ColorConstants.instance.primaryColor,
      confirmBtnColor: ColorConstants.instance.primaryColor,
      barrierDismissible: false,
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
      backgroundColor: ColorConstants.instance.primaryColor,
      confirmBtnColor: ColorConstants.instance.primaryColor,
      barrierDismissible: false,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }
}
