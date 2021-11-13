import 'dart:io';
import 'package:flutter/material.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Providers/store_provider.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key key}) : super(key: key);

  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  bool _isLoading = false;
  UserProvider _userProvider;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    StoreProvider _storeProvider =
        Provider.of<StoreProvider>(context, listen: false);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _isLoading = true;
      });
      List<String> data = scanData.code.split('*');
      String storeId = data[0];
      String campaignId = data[1];
      String userId = data[2];
      if (_storeProvider.storeId == storeId) {
        FirestoreService()
            .scanCode(storeId, campaignId, userId, _userProvider.name,
                _userProvider.userId)
            .then((value) => ToastService().showSuccess(value, context))
            .onError(
                (error, stackTrace) => ToastService().showError(error, context))
            .whenComplete(() => setState(() {
                  _isLoading = false;
                }));
      }
      controller.dispose();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading == false)
        ? Scaffold(
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                    borderRadius: 10.0,
                    borderLength: 20.0,
                    borderWidth: 10.0,
                    borderColor: ColorConstants.instance.textGold),
              ),
            ),
          )
        : const ProgressWidget();
  }
}
