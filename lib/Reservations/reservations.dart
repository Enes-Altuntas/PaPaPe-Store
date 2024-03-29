import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/reservation_card.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/reservations_model.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class Reservation extends StatefulWidget {
  const Reservation({Key key}) : super(key: key);

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  bool isLoading = false;
  bool btnVis = true;
  ReservationsModel selectedReservation;
  UserProvider _userProvider;

  makePhoneCall(storePhone) async {
    await launch("tel:+90$storePhone");
  }

  approveReservation() async {
    setState(() {
      isLoading = true;
    });
    await FirestoreService()
        .approveReservation(selectedReservation)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  approveReservationYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Rezervasyonu onaylamak istediğinize emin misiniz ?',
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
        showCancelBtn: true,
        cancelBtnText: 'Hayır',
        barrierDismissible: false,
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          approveReservation();
        },
        confirmBtnText: 'Evet');
  }

  rejectReservation() async {
    setState(() {
      isLoading = true;
    });
    await FirestoreService()
        .rejectReservation(selectedReservation)
        .then((value) => ToastService().showSuccess(value, context))
        .onError(
            (error, stackTrace) => ToastService().showError(error, context))
        .whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  rejectReservationYesNo() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: '',
        text: 'Rezervasyonu reddetmek istediğinize emin misiniz ?',
        backgroundColor: ColorConstants.instance.primaryColor,
        confirmBtnColor: ColorConstants.instance.primaryColor,
        showCancelBtn: true,
        cancelBtnText: 'Hayır',
        barrierDismissible: false,
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          rejectReservation();
        },
        confirmBtnText: 'Evet');
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReservationsModel>>(
      stream: FirestoreService().getReservations(_userProvider.storeId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            switch (snapshot.hasData && snapshot.data.isNotEmpty) {
              case true:
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReservationCard(
                          reservation: snapshot.data[index],
                          onPressedApprove: () {
                            setState(() {
                              selectedReservation = snapshot.data[index];
                            });
                            approveReservationYesNo();
                          },
                          onPressedCall: () {
                            makePhoneCall(
                                snapshot.data[index].reservationPhone);
                          },
                          onPressedReject: () {
                            setState(() {
                              selectedReservation = snapshot.data[index];
                            });
                            rejectReservationYesNo();
                          },
                        ));
                  },
                );
                break;
              default:
                return NotFound(
                  notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                  notFoundIconColor: ColorConstants.instance.primaryColor,
                  notFoundText:
                      'Şu an işletmeniz adına yayınlanmış hiç bir rezervasyon bulunmamaktadır.',
                  notFoundTextColor: ColorConstants.instance.hintColor,
                );
            }
            break;
          default:
            return const ProgressWidget();
        }
      },
    );
  }
}
