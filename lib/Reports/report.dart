import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/title.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Models/chart_day_model.dart';
import 'package:papape_store/Models/chart_hour_model.dart';
import 'package:papape_store/Providers/user_provider.dart';
import 'package:papape_store/Services/firestore_service.dart';
import 'package:provider/provider.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key key}) : super(key: key);

  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  bool isLoading = false;
  List<DayChart> _dayData = [];
  List<HourChart> _hourData = [];
  List<charts.Series<DayChart, String>> _chartDayData = [];
  List<charts.Series<HourChart, String>> _chartHourData = [];
  UserProvider _userProvider;

  // void prepareDayData(List<Campaign> campaigns) {
  //   _dayData = [];
  //   _chartDayData = [];

  //   for (var i = 1; i <= 7; i++) {
  //     int dayCounter = 0;
  //     for (var element in campaigns) {
  //       for (var campaignUser in element.campaignUsers) {
  //         if (campaignUser.scannedAt.toDate().weekday == i) {
  //           dayCounter = dayCounter + 1;
  //         }
  //       }
  //     }
  //     switch (i) {
  //       case 1:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Pzt');
  //         _dayData.add(item);
  //         break;
  //       case 2:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Salı');
  //         _dayData.add(item);
  //         break;
  //       case 3:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Çrş');
  //         _dayData.add(item);
  //         break;
  //       case 4:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Prş');
  //         _dayData.add(item);
  //         break;
  //       case 5:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Cuma');
  //         _dayData.add(item);
  //         break;
  //       case 6:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Cmt');
  //         _dayData.add(item);
  //         break;
  //       case 7:
  //         DayChart item = DayChart(counter: dayCounter, day: 'Pzr');
  //         _dayData.add(item);
  //         break;
  //       default:
  //     }
  //   }

  //   _chartDayData.add(charts.Series(
  //     id: 'Days',
  //     colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
  //     data: _dayData,
  //     domainFn: (DayChart dayChart, _) => dayChart.day,
  //     measureFn: (DayChart dayChart, _) => dayChart.counter,
  //     fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
  //   ));
  // }

  // void prepareHourData(List<Campaign> campaigns) {
  //   _hourData = [];
  //   _chartHourData = [];

  //   for (var i = 1; i <= 12; i++) {
  //     int hourCounter = 0;
  //     for (var element in campaigns) {
  //       for (var campaignUser in element.campaignUsers) {
  //         if (i == 1 &&
  //             campaignUser.scannedAt.toDate().hour >= 0 &&
  //             campaignUser.scannedAt.toDate().hour < 2) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 2 &&
  //             campaignUser.scannedAt.toDate().hour >= 2 &&
  //             campaignUser.scannedAt.toDate().hour < 4) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 3 &&
  //             campaignUser.scannedAt.toDate().hour >= 4 &&
  //             campaignUser.scannedAt.toDate().hour < 6) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 4 &&
  //             campaignUser.scannedAt.toDate().hour >= 6 &&
  //             campaignUser.scannedAt.toDate().hour < 8) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 5 &&
  //             campaignUser.scannedAt.toDate().hour >= 8 &&
  //             campaignUser.scannedAt.toDate().hour < 10) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 6 &&
  //             campaignUser.scannedAt.toDate().hour >= 10 &&
  //             campaignUser.scannedAt.toDate().hour < 12) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 7 &&
  //             campaignUser.scannedAt.toDate().hour >= 12 &&
  //             campaignUser.scannedAt.toDate().hour < 14) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 8 &&
  //             campaignUser.scannedAt.toDate().hour >= 14 &&
  //             campaignUser.scannedAt.toDate().hour < 16) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 9 &&
  //             campaignUser.scannedAt.toDate().hour >= 16 &&
  //             campaignUser.scannedAt.toDate().hour < 18) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 10 &&
  //             campaignUser.scannedAt.toDate().hour >= 18 &&
  //             campaignUser.scannedAt.toDate().hour < 20) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 11 &&
  //             campaignUser.scannedAt.toDate().hour >= 20 &&
  //             campaignUser.scannedAt.toDate().hour < 22) {
  //           hourCounter = hourCounter + 1;
  //         } else if (i == 12 && campaignUser.scannedAt.toDate().hour >= 22) {
  //           hourCounter = hourCounter + 1;
  //         }
  //       }
  //     }
  //     HourChart item = HourChart(counter: hourCounter, hour: i.toString());
  //     _hourData.add(item);
  //   }

  //   _chartHourData.add(charts.Series(
  //     id: 'Hours',
  //     colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
  //     data: _hourData,
  //     domainFn: (HourChart dayChart, _) => dayChart.hour,
  //     measureFn: (HourChart dayChart, _) => dayChart.counter,
  //     fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
  //   ));
  // }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              toolbarHeight: 70.0,
              flexibleSpace: Container(
                color: ColorConstants.instance.primaryColor,
              ),
              title: const TitleWidget(),
            ),
            body: StreamBuilder<List<Campaign>>(
                stream:
                    FirestoreService().getStoreCampaigns(_userProvider.storeId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                        case true:
                          return null;
                          break;
                        default:
                          return NotFound(
                            notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                            notFoundIconColor:
                                ColorConstants.instance.primaryColor,
                            notFoundText:
                                'Şu an yayınlamış olduğunuz hiçbir kampanya bulunmamaktadır.',
                            notFoundTextColor:
                                ColorConstants.instance.hintColor,
                          );
                      }
                      break;
                    default:
                      return const ProgressWidget();
                  }
                }),
          )
        : const ProgressWidget();
  }
}
