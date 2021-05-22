import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

class ToastService {
  showSuccess(msg, _context) {
    CoolAlert.show(
      context: _context,
      title: 'Tebrikler !',
      backgroundColor: Theme.of(_context).primaryColor,
      confirmBtnColor: Theme.of(_context).primaryColor,
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
      backgroundColor: Theme.of(_context).primaryColor,
      confirmBtnColor: Theme.of(_context).primaryColor,
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
      backgroundColor: Theme.of(_context).primaryColor,
      confirmBtnColor: Theme.of(_context).primaryColor,
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
      backgroundColor: Theme.of(_context).primaryColor,
      confirmBtnColor: Theme.of(_context).primaryColor,
      barrierDismissible: false,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Geri Dön',
      text: msg,
    );
  }
}
