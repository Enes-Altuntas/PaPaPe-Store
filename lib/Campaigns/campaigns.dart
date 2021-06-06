import 'package:bulovva_store/Models/camapign_model.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Campaigns extends StatefulWidget {
  Campaigns({Key key}) : super(key: key);

  @override
  _CampaignsState createState() => _CampaignsState();
}

class _CampaignsState extends State<Campaigns> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _key = TextEditingController();
  final TextEditingController _start = TextEditingController();
  final TextEditingController _finish = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Timestamp _startDate;
  Timestamp _finishDate;
  String _campaignId;
  Campaign _selectedCampaign;
  StoreProvider _storeProvider;
  bool isLoading = false;

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  String validateCampaignDesc(value) {
    if (value.isEmpty) {
      return "* Kampanya açıklaması zorunludur !";
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
      return "* Harf ve rakam içermelidir !";
    }

    return null;
  }

  String validateCampaignKey(String value) {
    if (value.isEmpty) {
      return "* Kampanya anahtarı zorunludur !";
    }
    if (value.contains(RegExp(r'[^a-zA-ZğüşöçİĞÜŞÖÇ\d]')) == true) {
      return "* Sadece harf ve rakam içermelidir !";
    }

    return null;
  }

  String validateCampaignStart(value) {
    if (value.isEmpty) {
      return "* Kampanya başlangıç tarihi zorunludur !";
    } else {
      return null;
    }
  }

  String validateCampaignFinish(value) {
    if (value.isEmpty) {
      return "* Kampanya bitiş tarihi zorunludur !";
    } else {
      return null;
    }
  }

  saveCampaign() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Campaign _campaign = Campaign(
          automatedStart: false,
          automatedStop: false,
          campaignActive: (_startDate.millisecondsSinceEpoch >
                  Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch)
              ? false
              : true,
          campaignId: Uuid().v4(),
          campaignCounter: 0,
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          campaignKey: _key.text.toUpperCase(),
          campaignStart: _startDate,
          createdAt: Timestamp.fromDate(DateTime.now()));
      FirestoreService()
          .saveCampaign(_campaign)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
      Navigator.of(context).pop();
      setState(() {
        _desc.text = '';
        _key.text = '';
        _start.text = '';
        _finish.text = '';
        _campaignId = null;
      });
    }
  }

  renewCampaign() {
    if (_startDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch ||
        _finishDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch) {
      ToastService().showWarning(
          "Kampanya başlangıç ve bitiş tarihleri geçmişte yer alamaz !",
          context);
      return;
    }
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Campaign _campaign = Campaign(
          automatedStart: false,
          automatedStop: false,
          campaignActive: (_startDate.millisecondsSinceEpoch >
                  Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch)
              ? false
              : true,
          campaignId: _selectedCampaign.campaignId,
          campaignDesc: _selectedCampaign.campaignDesc,
          campaignFinish: _finishDate,
          campaignKey: _selectedCampaign.campaignKey,
          campaignStart: _startDate,
          campaignCounter: _selectedCampaign.campaignCounter,
          createdAt: Timestamp.fromDate(DateTime.now()));
      FirestoreService()
          .renewCampaign(_campaign)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
      Navigator.of(context).pop();
      setState(() {
        _selectedCampaign = null;
        _desc.text = '';
        _key.text = '';
        _start.text = '';
        _finish.text = '';
        _campaignId = null;
      });
    }
  }

  updateCampaign() {
    if (_startDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch ||
        _finishDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch) {
      ToastService().showInfo(
          "Kampanya başlangıç ve bitiş tarihleri geçmişte yer alamaz !",
          context);
      return;
    }
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Campaign _campaign = Campaign(
          automatedStart: false,
          automatedStop: false,
          campaignActive: (_startDate.millisecondsSinceEpoch >
                  Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch)
              ? false
              : true,
          campaignId: _campaignId,
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          campaignKey: _key.text.toUpperCase(),
          campaignCounter: _selectedCampaign.campaignCounter,
          campaignStart: _startDate,
          createdAt: Timestamp.fromDate(DateTime.now()));
      FirestoreService()
          .updateCampaign(_campaign)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
      Navigator.of(context).pop();
      setState(() {
        _selectedCampaign = null;
        _desc.text = '';
        _key.text = '';
        _start.text = '';
        _finish.text = '';
        _campaignId = null;
      });
    }
  }

  removeCampaign() {
    setState(() {
      isLoading = true;
    });
    FirestoreService()
        .removeCampaign(_campaignId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
    Navigator.of(context).pop();
    setState(() {
      _selectedCampaign = null;
      _desc.text = '';
      _key.text = '';
      _start.text = '';
      _finish.text = '';
      _campaignId = null;
    });
  }

  deleteCampaign() {
    setState(() {
      isLoading = true;
    });
    FirestoreService()
        .deleteCampaign(_campaignId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
    Navigator.of(context).pop();
    setState(() {
      _selectedCampaign = null;
      _desc.text = '';
      _key.text = '';
      _start.text = '';
      _finish.text = '';
      _campaignId = null;
    });
  }

  removeYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Kampanyayı sonlandırmak istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          removeCampaign();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  renewYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text:
            'Seçili kampanyayı tekrar yayınlamak, bu kampanyayı aktif kampanyanız haline getirir. Kampanyayı tekrar yayınlamak istediğinize emin misiniz?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          renewCampaign();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  updateYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Kampanyayı güncellemek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          updateCampaign();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  saveYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text:
            'Kampanyayı kaydetmek, bu kampanyayı aktif kampanyanız haline getirir. Kampanyayı kaydetmek istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          saveCampaign();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  deleteYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text:
            'Kampanyayı listeden kaldırmak, kullanıcıların verdiğiniz kampanyayı listede görememesine ve sizin bu kampanyayı yeniden yayınlayamamanıza yol açacaktır ! Kampanyayı listeden kaldırmak istediğinize emin misiniz ?',
        showCancelBtn: true,
        backgroundColor: Theme.of(context).primaryColor,
        confirmBtnColor: Theme.of(context).primaryColor,
        cancelBtnText: 'Hayır',
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          deleteCampaign();
        },
        barrierDismissible: false,
        confirmBtnText: 'Evet');
  }

  openDialog() {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeId == null) {
      ToastService().showInfo(
          'Kampanya girmeden önce işletme bilgilerinizi kaydetmelisiniz !',
          context);
      return;
    }
    if (_selectedCampaign != null) {
      setState(() {
        _desc.text = _selectedCampaign.campaignDesc;
        _key.text = _selectedCampaign.campaignKey;
        _start.text = formatDate(_selectedCampaign.campaignStart).toString();
        _startDate = _selectedCampaign.campaignStart;
        _finish.text = formatDate(_selectedCampaign.campaignFinish).toString();
        _finishDate = _selectedCampaign.campaignFinish;
        _campaignId = _selectedCampaign.campaignId;
      });
    }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (_selectedCampaign == null)
                        ? Text('Kampanya Yayınla',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'Bebas',
                                color: Theme.of(context).primaryColor))
                        : Text('Kampanya Düzenle',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'Bebas',
                                color: Theme.of(context).primaryColor)),
                    GestureDetector(
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _startDate = null;
                          _finishDate = null;
                          _selectedCampaign = null;
                          _desc.text = '';
                          _key.text = '';
                          _start.text = '';
                          _finish.text = '';
                          _campaignId = null;
                        });
                      },
                    ),
                  ]),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLength: 255,
                      validator: validateCampaignDesc,
                      enabled: (_selectedCampaign != null &&
                              _selectedCampaign.campaignActive == false)
                          ? false
                          : true,
                      maxLines: 3,
                      controller: _desc,
                      decoration: InputDecoration(
                          labelText: 'Kampanya Açıklaması',
                          border: OutlineInputBorder()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        validator: validateCampaignKey,
                        enabled: (_selectedCampaign != null &&
                                _selectedCampaign.campaignActive == false)
                            ? false
                            : true,
                        controller: _key,
                        maxLength: 15,
                        decoration: InputDecoration(
                            labelText: 'Kampanya Anahtarı',
                            prefix: Text('#'),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        controller: _start,
                        validator: validateCampaignStart,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: 'Kampanya Başlangıç',
                            border: OutlineInputBorder()),
                        onTap: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2050, 1, 1), onConfirm: (date) {
                            setState(() {
                              _startDate = Timestamp.fromDate(date);
                              _start.text = formatDate(_startDate);
                              _finish.text = '';
                            });
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.tr);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        validator: validateCampaignFinish,
                        controller: _finish,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: 'Kampanya Bitiş',
                            border: OutlineInputBorder()),
                        onTap: () {
                          if (_startDate != null) {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: _startDate.toDate(),
                                maxTime: DateTime(2050, 1, 1),
                                onConfirm: (date) {
                              setState(() {
                                _finishDate = Timestamp.fromDate(date);
                                _finish.text = formatDate(_finishDate);
                              });
                            },
                                currentTime: _startDate.toDate(),
                                locale: LocaleType.tr);
                          } else {
                            ToastService().showWarning(
                                "Bitiş tarihi girmeden önce başlangıç tarihi girilmelidir !",
                                context);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: (_selectedCampaign == null)
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextButton(
                                  onPressed: () {
                                    saveYesNo();
                                  },
                                  child: Text(
                                    'Kampanyayı Kaydet',
                                    style: TextStyle(color: Colors.green[900]),
                                  ),
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(15)),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green[900]),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  width: 2,
                                                  color: Colors.green[900]))))))
                          : (_selectedCampaign.campaignActive == true ||
                                  _startDate.millisecondsSinceEpoch >
                                      Timestamp.fromDate(DateTime.now())
                                          .millisecondsSinceEpoch)
                              ? Column(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TextButton(
                                            onPressed: () {
                                              updateYesNo();
                                            },
                                            child: Text(
                                              'Kampanyayı Güncelle',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green[800],
                                            ))),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TextButton(
                                            onPressed: () {
                                              removeYesNo();
                                            },
                                            child: Text(
                                              'Kampanyayı Sonlandır',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                            )))
                                  ],
                                )
                              : Column(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TextButton(
                                            onPressed: () {
                                              renewYesNo();
                                            },
                                            child: Text(
                                              'Yeniden Kampanya Ver',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green[800],
                                            ))),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TextButton(
                                            onPressed: () {
                                              deleteYesNo();
                                            },
                                            child: Text(
                                              'Kampanyayı Listeden Kaldır',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                            )))
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextButton(
                      child: Text("Kampanya Yayınla".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side: BorderSide(
                                          width: 2,
                                          color: Theme.of(context)
                                              .primaryColor)))),
                      onPressed: () {
                        openDialog();
                      }),
                ),
              ),
              Flexible(
                child: StreamBuilder<List<Campaign>>(
                  stream: FirestoreService().getStoreCampaigns(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.active)
                        ? (snapshot.data.length != 0)
                            ? ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        color: Colors.white,
                                        shadowColor: Colors.black,
                                        elevation: 5.0,
                                        child: Container(
                                          height: 440,
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedCampaign =
                                                      snapshot.data[index];
                                                });
                                                openDialog();
                                              },
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Stack(
                                                      children: [
                                                        ColorFiltered(
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                  BlendMode
                                                                      .multiply),
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Image.network(
                                                                snapshot
                                                                    .data[index]
                                                                    .campaignPicRef,
                                                                fit: BoxFit
                                                                    .fitWidth),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 10,
                                                          right: 25,
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  "#${snapshot.data[index].campaignKey}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 40,
                                                          left: 10,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .access_time,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  formatDate(snapshot
                                                                      .data[
                                                                          index]
                                                                      .campaignStart),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 10,
                                                          left: 10,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .access_alarm,
                                                                  color: Colors
                                                                      .white),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  formatDate(snapshot
                                                                      .data[
                                                                          index]
                                                                      .campaignFinish),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 25,
                                                          right: 25,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .visibility,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                  snapshot
                                                                      .data[
                                                                          index]
                                                                      .campaignCounter
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10.0),
                                                                child: (snapshot
                                                                            .data[
                                                                                index]
                                                                            .campaignActive ==
                                                                        true)
                                                                    ? Text(
                                                                        'Kampanya Yayında'
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.green[800],
                                                                            fontSize: 16.0),
                                                                      )
                                                                    : (snapshot.data[index].campaignStart.millisecondsSinceEpoch >
                                                                            Timestamp.now().millisecondsSinceEpoch)
                                                                        ? Text(
                                                                            'Kampanya Beklemede'.toUpperCase(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.amber[800],
                                                                                fontSize: 16.0),
                                                                          )
                                                                        : Text(
                                                                            'Kampanya İnaktif'.toUpperCase(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.red[800],
                                                                                fontSize: 16.0),
                                                                          )),
                                                            Text(
                                                              snapshot
                                                                  .data[index]
                                                                  .campaignDesc,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              )),
                                        )),
                                  );
                                },
                              )
                            : Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.assignment_late_outlined,
                                          size: 100.0,
                                          color:
                                              Theme.of(context).primaryColor),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          'Henüz yayınlamış olduğunuz herhangi bir kampanya bulunmamaktadır !',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                          );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
  }
}
