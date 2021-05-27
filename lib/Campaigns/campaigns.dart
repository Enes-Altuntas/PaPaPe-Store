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
          campaignActive: true,
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
          campaignActive: true,
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
          campaignActive: true,
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

  removeYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Kampanyayı silmek istediğinize emin misiniz ?',
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
                        ? Text('Kampanya Yarat',
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
                                    saveCampaign();
                                  },
                                  child: Text(
                                    'Kampanyayı Kaydet',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green[800],
                                  )))
                          : (_selectedCampaign.campaignActive == true)
                              ? Column(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TextButton(
                                            onPressed: () {
                                              updateCampaign();
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
                                              'Kampanyayı Sil',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                            )))
                                  ],
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextButton(
                                      onPressed: () {
                                        renewCampaign();
                                      },
                                      child: Text(
                                        'Yeniden Kampanya Ver',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green[800],
                                      ))),
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
        ? Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              label: Text(
                'Kampanya',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                openDialog();
              },
            ),
            body: StreamBuilder<List<Campaign>>(
              stream: FirestoreService().getStoreCampaigns(),
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.active)
                    ? (snapshot.data.length != 0)
                        ? ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: (snapshot.data[index].campaignActive)
                                      ? Colors.green[800]
                                      : Theme.of(context).primaryColor,
                                  shadowColor: Theme.of(context).primaryColor,
                                  elevation: 10.0,
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        _selectedCampaign =
                                            snapshot.data[index];
                                      });
                                      openDialog();
                                    },
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        snapshot.data[index].campaignDesc,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Kampanya Başlangıç: ${formatDate(snapshot.data[index].campaignStart)}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Kampanya Bitiş: ${formatDate(snapshot.data[index].campaignFinish)}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Kampanya Anahtarı: #${snapshot.data[index].campaignKey}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Alınmış kampanya kodu sayısı: ${snapshot.data[index].campaignCounter}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_late_outlined,
                                      size: 100.0,
                                      color: Theme.of(context).primaryColor),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      'Henüz yayınlamış olduğunuz herhangi bir kampanya bulunmamaktadır !',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 25.0,
                                          color:
                                              Theme.of(context).primaryColor),
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
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
  }
}
