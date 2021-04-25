import 'package:bulovva_store/Models/camapign_model.dart';
import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    } else {
      return null;
    }
  }

  String validateCampaignKey(value) {
    if (value.isEmpty) {
      return "* Kampanya anahtarı zorunludur !";
    } else {
      return null;
    }
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
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          campaignKey: '#${_key.text.toUpperCase()}',
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

  updateCampaign() {
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
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (_campaignId == null)
                        ? Text('Kampanya Yarat',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'Bebas',
                                color: Theme.of(context).accentColor))
                        : Text('Kampanya Düzenle',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'Bebas',
                                color: Theme.of(context).accentColor)),
                    GestureDetector(
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Theme.of(context).accentColor,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLength: 255,
                      validator: validateCampaignDesc,
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
                        controller: _key,
                        maxLength: 15,
                        decoration: InputDecoration(
                            labelText: 'Kampanya Anahtarı',
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
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(),
                                maxTime: DateTime(2050, 1, 1),
                                onConfirm: (date) {
                              setState(() {
                                _start.text = date.toString();
                                _startDate = Timestamp.fromDate(date);
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.tr);
                          },
                          child: Text(
                            'Kampanya Başlangıcı Seç',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                          )),
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
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(),
                                maxTime: DateTime(2050, 1, 1),
                                onConfirm: (date) {
                              setState(() {
                                _finish.text = date.toString();
                                _finishDate = Timestamp.fromDate(date);
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.tr);
                          },
                          child: Text(
                            'Kampanya Bitişi Seç',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: (_campaignId == null)
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
                          : Column(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextButton(
                                        onPressed: () {
                                          updateCampaign();
                                        },
                                        child: Text(
                                          'Kampanyayı Güncelle',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.green[800],
                                        ))),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextButton(
                                        onPressed: () {
                                          removeCampaign();
                                        },
                                        child: Text(
                                          'Kampanyayı Sil',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red[800],
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
        ? Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              label: Text(
                'Kampanya Ekle',
                style: TextStyle(color: Colors.red[800]),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.red[800],
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
                                      ? Colors.green
                                      : Colors.red,
                                  shadowColor: Theme.of(context).accentColor,
                                  elevation: 10.0,
                                  child: ListTile(
                                    onTap: () {
                                      if (snapshot.data[index].campaignActive) {
                                        setState(() {
                                          _desc.text =
                                              snapshot.data[index].campaignDesc;
                                          _key.text =
                                              snapshot.data[index].campaignKey;
                                          _start.text = formatDate(snapshot
                                                  .data[index].campaignStart)
                                              .toString();
                                          _startDate = snapshot
                                              .data[index].campaignStart;
                                          _finish.text = formatDate(snapshot
                                                  .data[index].campaignFinish)
                                              .toString();
                                          _finishDate = snapshot
                                              .data[index].campaignFinish;
                                          _campaignId =
                                              snapshot.data[index].campaignId;
                                        });
                                        openDialog();
                                      } else {
                                        ToastService().showInfo(
                                            'Sadece aktif kampanyanız düzenlenebilir !',
                                            context);
                                      }
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
                                              'Kampanya Anahtarı: ${snapshot.data[index].campaignKey}',
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
                                      size: 100.0, color: Colors.red),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      'Henüz yayınlamış olduğunuz herhangi bir kampanya bulunmamaktadır !',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 25.0, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      );
              },
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).accentColor,
            ),
          );
  }
}
