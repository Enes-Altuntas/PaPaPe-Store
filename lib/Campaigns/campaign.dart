import 'dart:io';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/image_container.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  bool isInit = true;

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
    });
    if (widget.campaignData != null &&
        widget.campaignData.campaignPicRef != null) {
      widget.campaignData.campaignPicRef = null;
    }
  }

  getImage(String type) async {
    setState(() {
      isLoading = true;
    });

    PickedFile image;

    if (type == 'gallery') {
      try {
        image = await ImagePicker()
            .getImage(source: ImageSource.gallery, imageQuality: 30);
      } catch (e) {
        ToastService().showInfo(
            'Galeriye erişemiyoruz, eğer izin vermediyseniz bu işlem için kameraya izin vermelisiniz !',
            context);
      }
    } else if (type == 'photo') {
      try {
        image = await ImagePicker()
            .getImage(source: ImageSource.camera, imageQuality: 30);
      } catch (e) {
        ToastService().showInfo(
            'Kameraya erişemiyoruz, eğer izin vermediyseniz bu işlem için kameraya izin vermelisiniz !',
            context);
      }
    }

    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 2.6),
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Resmi Düzenle',
            toolbarColor: ColorConstants.instance.primaryColor,
            toolbarWidgetColor: ColorConstants.instance.whiteContainer,
            statusBarColor: ColorConstants.instance.primaryColor,
            backgroundColor: ColorConstants.instance.whiteContainer,
          ));
      setState(() {
        campaignPic = cropped;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  saveCampaign() {
    if (_startDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch ||
        _finishDate.millisecondsSinceEpoch <
            Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch) {
      ToastService().showWarning(
          "Kampanya başlangıç ve bitiş tarihleri geçmişte yer alamaz !",
          context);
      return;
    }
    if (_finishDate.millisecondsSinceEpoch <=
        _startDate.millisecondsSinceEpoch) {
      ToastService().showWarning(
          "Kampanya başlangıç tarihi, kampanya bitiş tarihinden sonra olamaz !",
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
          campaignId: const Uuid().v4(),
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
    if (_finishDate.millisecondsSinceEpoch <=
        _startDate.millisecondsSinceEpoch) {
      ToastService().showWarning(
          "Kampanya başlangıç tarihi, kampanya bitiş tarihinden sonra olamaz !",
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
          campaignPicRef: widget.campaignData.campaignPicRef,
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
    if (_finishDate.millisecondsSinceEpoch <=
        _startDate.millisecondsSinceEpoch) {
      ToastService().showWarning(
          "Kampanya başlangıç tarihi, kampanya bitiş tarihinden sonra olamaz !",
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
          campaignPicRef: widget.campaignData.campaignPicRef,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
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
    }
  }

  Future<DateTime> pickDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: initialDate,
        currentDate: DateTime.now(),
        locale: const Locale("tr", "TR"),
        lastDate: DateTime(DateTime.now().year + 10));

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay> pickTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      hourLabelText: 'Saat',
      minuteLabelText: 'Dakika',
      helpText: 'Saat/Dakika Giriniz',
      cancelText: 'İptal Et',
      confirmText: 'Tamam',
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child,
        );
      },
    );

    if (newTime == null) return null;

    return newTime;
  }

  Future<Timestamp> pickDateTime() async {
    final date = await pickDate();
    if (date == null) return null;

    final time = await pickTime();
    if (time == null) return null;

    DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    return Timestamp.fromDate(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const TitleWidget(),
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
            ),
            body: (isLoading == false)
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: CustomImageContainer(
                            localImage: campaignPic,
                            urlImage: (widget.campaignData != null)
                                ? widget.campaignData.campaignPicRef
                                : null,
                            onPressedAdd: (String type) {
                              getImage(type);
                            },
                            onPressedDelete: () {
                              deleteImage();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Form(
                            key: formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Kampanya başlığı, kampanyanızın en dikkat çekici kısmıdır. Kampanyanızı güzel tanımladığından emin olun!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextFormField(
                                    maxLength: 50,
                                    validator: validateCampaignTitle,
                                    enabled: isEnabled,
                                    controller: _title,
                                    decoration: const InputDecoration(
                                        labelText: 'Kampanya Başlığı',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Kampanyanızı herkesin anlayabileceği şekilde açıklamanız çok önemlidir unutmayın!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
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
                                    decoration: const InputDecoration(
                                        labelText: 'Kampanya Açıklaması',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Kampanya anahtar sözcüğü, müşterilerinizin ödeme yaparken kampanyanızdan yararlanmak için kullanacakları sözcüktür!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextFormField(
                                    validator: validateCampaignKey,
                                    enabled: isEnabled,
                                    controller: _key,
                                    maxLength: 15,
                                    decoration: const InputDecoration(
                                        labelText: 'Kampanya Anahtar Sözcüğü',
                                        prefix: Text('#'),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Kampanyanızın hangi tarih ve saatte başlayacağını belirtmeniz gereklidir.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
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
                                    decoration: const InputDecoration(
                                        labelText: 'Kampanya Başlangıç Tarihi',
                                        border: OutlineInputBorder()),
                                    onTap: () async {
                                      Timestamp startDate =
                                          await pickDateTime();

                                      if (startDate != null) {
                                        setState(() {
                                          _startDate = startDate;
                                          _start.text = formatDate(startDate);
                                          _finish.text = '';
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    " * Kampanyanızın hangi tarih ve saatte biteceğini belirtmeniz gereklidir.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            ColorConstants.instance.hintColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
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
                                    decoration: const InputDecoration(
                                        labelText: 'Kampanya Bitiş Tarihi',
                                        border: OutlineInputBorder()),
                                    onTap: () async {
                                      if (_startDate != null) {
                                        Timestamp finishDate =
                                            await pickDateTime();

                                        if (finishDate != null) {
                                          setState(() {
                                            _finishDate = finishDate;
                                            _finish.text =
                                                formatDate(finishDate);
                                          });
                                        }
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
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: GradientButton(
                                        buttonText: 'Kampanya Yayınla',
                                        start: ColorConstants
                                            .instance.buttonDarkGold,
                                        end: ColorConstants
                                            .instance.buttonLightColor,
                                        onPressed: () {
                                          saveYesNo();
                                        },
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
                                        start: ColorConstants
                                            .instance.buttonDarkGold,
                                        end: ColorConstants
                                            .instance.buttonLightColor,
                                        buttonText: 'Kampanyayı Yinele',
                                        icon: FontAwesomeIcons.save,
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
                                      start:
                                          ColorConstants.instance.primaryColor,
                                      end: ColorConstants
                                          .instance.secondaryColor,
                                      buttonText: 'Kampanyayı Sil',
                                      icon: FontAwesomeIcons.trash,
                                      fontSize: 15,
                                      onPressed: () {
                                        deleteYesNo();
                                      },
                                      widthMultiplier: 0.9,
                                    )),
                                Visibility(
                                    visible: updateBtn,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: GradientButton(
                                        start: ColorConstants
                                            .instance.buttonDarkGold,
                                        end: ColorConstants
                                            .instance.buttonLightColor,
                                        buttonText: 'Kampanyayı Güncelle',
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
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: GradientButton(
                                        start: ColorConstants
                                            .instance.primaryColor,
                                        end: ColorConstants
                                            .instance.secondaryColor,
                                        buttonText: 'Kampanyayı Sonlandır',
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
                  )
                : const ProgressWidget(),
          )
        : const ProgressWidget();
  }
}
