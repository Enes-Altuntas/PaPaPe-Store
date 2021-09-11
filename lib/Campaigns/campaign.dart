import 'dart:io';
import 'package:bulb/Components/gradient_button.dart';
import 'package:bulb/Components/image_container.dart';
import 'package:bulb/Components/title.dart';
import 'package:bulb/Models/camapign_model.dart';
import 'package:bulb/Services/firestore_service.dart';
import 'package:bulb/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CampaignSingle extends StatefulWidget {
  final Campaign campaignData;

  const CampaignSingle({Key key, this.campaignData}) : super(key: key);

  @override
  _CampaignSingleState createState() => _CampaignSingleState();
}

class _CampaignSingleState extends State<CampaignSingle> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _key = TextEditingController();
  final TextEditingController _start = TextEditingController();
  final TextEditingController _finish = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Timestamp _startDate;
  Timestamp _finishDate;
  File campaignPic;
  bool isLoading = false;
  bool isEnabled;
  bool saveBtn = false;
  bool renewBtn = false;
  bool deleteBtn = false;
  bool updateBtn = false;
  bool endBtn = false;
  bool picBtn = false;
  bool isInit = true;
  bool picDeleted = false;

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  String validateCampaignTitle(value) {
    if (value.isEmpty) {
      return "* Kampanya başlığı zorunludur !";
    }
    if (value.contains(RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ\d]')) != true) {
      return "* Harf ve rakam içermelidir !";
    }

    return null;
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
      return "* Kampanya anahtar sözcüğü zorunludur !";
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

  deleteImage() {
    setState(() {
      campaignPic = null;
      picDeleted = true;
    });
    if (widget.campaignData != null &&
        widget.campaignData.campaignPicRef != null) {
      widget.campaignData.campaignPicRef = null;
    }
  }

  getImage() async {
    setState(() {
      isLoading = true;
    });
    await Permission.photos.request();
    PermissionStatus permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      PickedFile image =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (image != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 2.6),
            compressQuality: 100,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Resmi Düzenle',
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: Colors.white,
                statusBarColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white));
        setState(() {
          campaignPic = cropped;
          picDeleted = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  saveCampaign() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Campaign _campaign = Campaign(
          automatedStart: false,
          automatedStop: false,
          campaignStatus: 'wait',
          campaignId: Uuid().v4(),
          campaignCounter: 0,
          campaignTitle: _title.text,
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          delInd: false,
          campaignKey: _key.text.toUpperCase(),
          campaignLocalImage: campaignPic,
          campaignStart: _startDate,
          createdAt: Timestamp.fromDate(DateTime.now()));
      FirestoreService()
          .saveCampaign(_campaign)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
                _title.text = '';
                _desc.text = '';
                _finishDate = null;
                _finish.text = '';
                _startDate = null;
                _start.text = '';
                _key.text = '';
                campaignPic = null;
              }));
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
          campaignStatus: 'wait',
          campaignTitle: _title.text,
          campaignId: widget.campaignData.campaignId,
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          campaignKey: _key.text.toUpperCase(),
          delInd: false,
          campaignStart: _startDate,
          campaignLocalImage: campaignPic,
          campaignPicRef:
              (picDeleted) ? null : widget.campaignData.campaignPicRef,
          campaignCounter: widget.campaignData.campaignCounter,
          createdAt: Timestamp.fromDate(DateTime.now()));
      FirestoreService()
          .renewCampaign(_campaign)
          .then((value) => ToastService().showSuccess(value, context))
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
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
          campaignStatus: 'wait',
          campaignTitle: _title.text,
          campaignId: widget.campaignData.campaignId,
          campaignDesc: _desc.text,
          campaignFinish: _finishDate,
          delInd: false,
          campaignLocalImage: campaignPic,
          campaignPicRef:
              (picDeleted) ? null : widget.campaignData.campaignPicRef,
          campaignKey: _key.text.toUpperCase(),
          campaignCounter: widget.campaignData.campaignCounter,
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
    }
  }

  removeCampaign() {
    setState(() {
      isLoading = true;
    });
    FirestoreService()
        .removeCampaign(widget.campaignData.campaignId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  deleteCampaign() {
    setState(() {
      isLoading = true;
    });
    FirestoreService()
        .deleteCampaign(widget.campaignData.campaignId)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
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

  @override
  void initState() {
    super.initState();
    if (widget.campaignData != null) {
      if (widget.campaignData.campaignStatus == 'wait' ||
          widget.campaignData.campaignStatus == 'inactive') {
        setState(() {
          isEnabled = true;
        });
      } else {
        setState(() {
          isEnabled = false;
        });
      }

      if (widget.campaignData.campaignStatus == 'wait') {
        setState(() {
          updateBtn = true;
          endBtn = true;
        });
      }

      if (widget.campaignData.campaignStatus == 'active') {
        setState(() {
          endBtn = true;
        });
      }

      if (widget.campaignData.campaignStatus == 'inactive') {
        setState(() {
          renewBtn = true;
          deleteBtn = true;
        });
      }
    } else {
      isEnabled = true;
      saveBtn = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      if (widget.campaignData != null) {
        setState(() {
          _title.text = widget.campaignData.campaignTitle;
          _desc.text = widget.campaignData.campaignDesc;
          _key.text = widget.campaignData.campaignKey;
          _start.text = formatDate(widget.campaignData.campaignStart);
          _finish.text = formatDate(widget.campaignData.campaignFinish);
          _startDate = widget.campaignData.campaignStart;
          _finishDate = widget.campaignData.campaignFinish;
          isInit = false;
        });
      }
      if (widget.campaignData != null &&
          (campaignPic != null || widget.campaignData.campaignPicRef != null)) {
        setState(() {
          picBtn = true;
        });
      } else {
        setState(() {
          picBtn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
        ),
        elevation: 0,
        centerTitle: true,
        title: TitleWidget(),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Theme.of(context).accentColor,
          Theme.of(context).primaryColor
        ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0))),
            child: (isLoading == false)
                ? Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: CustomImageContainer(
                              addText: 'Resim Ekle',
                              addable: (widget.campaignData != null &&
                                      widget.campaignData.campaignStatus ==
                                          'active')
                                  ? false
                                  : true,
                              buttonVis: picBtn,
                              localImage: campaignPic,
                              urlImage: (widget.campaignData != null)
                                  ? widget.campaignData.campaignPicRef
                                  : null,
                              onPressedAdd: () {
                                if (widget.campaignData != null) {
                                  if (widget.campaignData.campaignStatus !=
                                      'active') {
                                    getImage();
                                  }
                                } else {
                                  getImage();
                                }
                              },
                              onPressedDelete: () {
                                deleteImage();
                              },
                              onPressedEdit: () {
                                getImage();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40.0),
                            child: Form(
                              key: formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: TextFormField(
                                      maxLength: 50,
                                      validator: validateCampaignTitle,
                                      enabled: isEnabled,
                                      controller: _title,
                                      decoration: InputDecoration(
                                          labelText: 'Kampanya Başlığı',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextFormField(
                                      maxLength: 255,
                                      validator: validateCampaignDesc,
                                      enabled: isEnabled,
                                      keyboardType: TextInputType.text,
                                      maxLines: 3,
                                      controller: _desc,
                                      decoration: InputDecoration(
                                          labelText: 'Kampanya Açıklaması',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextFormField(
                                      validator: validateCampaignKey,
                                      enabled: isEnabled,
                                      controller: _key,
                                      maxLength: 15,
                                      decoration: InputDecoration(
                                          labelText: 'Kampanya Anahtar Sözcüğü',
                                          prefix: Text('#'),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: TextFormField(
                                      controller: _start,
                                      validator: validateCampaignStart,
                                      enabled: isEnabled,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          labelText:
                                              'Kampanya Başlangıç Tarihi',
                                          border: OutlineInputBorder()),
                                      onTap: () {
                                        DatePicker.showDateTimePicker(context,
                                            showTitleActions: true,
                                            minTime: DateTime.now()
                                                .add(new Duration(minutes: 15)),
                                            maxTime: DateTime(2030, 1, 1),
                                            onConfirm: (date) {
                                          setState(() {
                                            _startDate =
                                                Timestamp.fromDate(date);
                                            _start.text =
                                                formatDate(_startDate);
                                            _finish.text = '';
                                          });
                                        },
                                            currentTime: DateTime.now()
                                                .add(new Duration(minutes: 15)),
                                            locale: LocaleType.tr);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 10.0),
                                    child: TextFormField(
                                      validator: validateCampaignFinish,
                                      controller: _finish,
                                      enabled: isEnabled,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          labelText: 'Kampanya Bitiş Tarihi',
                                          border: OutlineInputBorder()),
                                      onTap: () {
                                        if (_startDate != null) {
                                          DatePicker.showDateTimePicker(context,
                                              showTitleActions: true,
                                              minTime: _startDate
                                                  .toDate()
                                                  .add(new Duration(hours: 1)),
                                              maxTime: DateTime(2050, 1, 1),
                                              onConfirm: (date) {
                                            setState(() {
                                              _finishDate =
                                                  Timestamp.fromDate(date);
                                              _finish.text =
                                                  formatDate(_finishDate);
                                            });
                                          },
                                              currentTime: _startDate
                                                  .toDate()
                                                  .add(new Duration(hours: 1)),
                                              locale: LocaleType.tr);
                                        } else {
                                          ToastService().showWarning(
                                              "Bitiş tarihi girmeden önce başlangıç tarihi girilmelidir !",
                                              context);
                                        }
                                      },
                                    ),
                                  ),
                                  Visibility(
                                      visible: saveBtn,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: GradientButton(
                                          buttonText: 'Kampanya Yayınla',
                                          onPressed: () {
                                            saveYesNo();
                                          },
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                          widthMultiplier: 0.9,
                                          icon: FontAwesomeIcons.save,
                                        ),
                                      )),
                                  Visibility(
                                      visible: renewBtn,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, bottom: 20.0),
                                        child: GradientButton(
                                          buttonText: 'Kampanyayı Yinele',
                                          icon: FontAwesomeIcons.save,
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                          onPressed: () {
                                            renewYesNo();
                                          },
                                          widthMultiplier: 0.9,
                                        ),
                                      )),
                                  Visibility(
                                      visible: deleteBtn,
                                      child: GradientButton(
                                        buttonText: 'Kampanyayı Sil',
                                        icon: FontAwesomeIcons.trash,
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        onPressed: () {
                                          deleteYesNo();
                                        },
                                        widthMultiplier: 0.9,
                                      )),
                                  Visibility(
                                      visible: updateBtn,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: GradientButton(
                                          buttonText: 'Kampanyayı Güncelle',
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                          icon: FontAwesomeIcons.save,
                                          onPressed: () {
                                            updateYesNo();
                                          },
                                          widthMultiplier: 0.9,
                                        ),
                                      )),
                                  Visibility(
                                      visible: endBtn,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: GradientButton(
                                          buttonText: 'Kampanyayı Sonlandır',
                                          fontFamily: 'Roboto',
                                          fontSize: 15,
                                          icon: FontAwesomeIcons.trash,
                                          onPressed: () {
                                            removeYesNo();
                                          },
                                          widthMultiplier: 0.9,
                                        ),
                                      )),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
