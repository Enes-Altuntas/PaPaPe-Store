import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Models/chart_day_model.dart';
import 'package:papape_store/Models/chart_hour_model.dart';
import 'package:papape_store/Services/firestore_service.dart';

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

  void prepareDayData(List<Campaign> campaigns) {
    _dayData = [];
    _chartDayData = [];

    for (var i = 1; i <= 7; i++) {
      int dayCounter = 0;
      for (var element in campaigns) {
        for (var campaignUser in element.campaignUsers) {
          if (campaignUser.scannedAt.toDate().weekday == i) {
            dayCounter = dayCounter + element.campaignUsers.length;
          }
        }
      }
      switch (i) {
        case 1:
          DayChart item = DayChart(counter: dayCounter, day: 'Pzt');
          _dayData.add(item);
          break;
        case 2:
          DayChart item = DayChart(counter: dayCounter, day: 'Salı');
          _dayData.add(item);
          break;
        case 3:
          DayChart item = DayChart(counter: dayCounter, day: 'Çrş');
          _dayData.add(item);
          break;
        case 4:
          DayChart item = DayChart(counter: dayCounter, day: 'Prş');
          _dayData.add(item);
          break;
        case 5:
          DayChart item = DayChart(counter: dayCounter, day: 'Cuma');
          _dayData.add(item);
          break;
        case 6:
          DayChart item = DayChart(counter: dayCounter, day: 'Cmt');
          _dayData.add(item);
          break;
        case 7:
          DayChart item = DayChart(counter: dayCounter, day: 'Pzr');
          _dayData.add(item);
          break;
        default:
      }
    }

    _chartDayData.add(charts.Series(
      id: 'Days',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      data: _dayData,
      domainFn: (DayChart dayChart, _) => dayChart.day,
      measureFn: (DayChart dayChart, _) => dayChart.counter,
      fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
    ));
  }

  void prepareHourData(List<Campaign> campaigns) {
    _hourData = [];
    _chartHourData = [];

    for (var i = 1; i <= 12; i++) {
      int hourCounter = 0;
      for (var element in campaigns) {
        for (var campaignUser in element.campaignUsers) {
          if (i == 1 &&
              campaignUser.scannedAt.toDate().hour >= 0 &&
              campaignUser.scannedAt.toDate().hour < 2) {
            hourCounter = hourCounter + 1;
          } else if (i == 2 &&
              campaignUser.scannedAt.toDate().hour >= 2 &&
              campaignUser.scannedAt.toDate().hour < 4) {
            hourCounter = hourCounter + 1;
          } else if (i == 3 &&
              campaignUser.scannedAt.toDate().hour >= 4 &&
              campaignUser.scannedAt.toDate().hour < 6) {
            hourCounter = hourCounter + 1;
          } else if (i == 4 &&
              campaignUser.scannedAt.toDate().hour >= 6 &&
              campaignUser.scannedAt.toDate().hour < 8) {
            hourCounter = hourCounter + 1;
          } else if (i == 5 &&
              campaignUser.scannedAt.toDate().hour >= 8 &&
              campaignUser.scannedAt.toDate().hour < 10) {
            hourCounter = hourCounter + 1;
          } else if (i == 6 &&
              campaignUser.scannedAt.toDate().hour >= 10 &&
              campaignUser.scannedAt.toDate().hour < 12) {
            hourCounter = hourCounter + 1;
          } else if (i == 7 &&
              campaignUser.scannedAt.toDate().hour >= 12 &&
              campaignUser.scannedAt.toDate().hour < 14) {
            hourCounter = hourCounter + 1;
          } else if (i == 8 &&
              campaignUser.scannedAt.toDate().hour >= 14 &&
              campaignUser.scannedAt.toDate().hour < 16) {
            hourCounter = hourCounter + 1;
          } else if (i == 9 &&
              campaignUser.scannedAt.toDate().hour >= 16 &&
              campaignUser.scannedAt.toDate().hour < 18) {
            hourCounter = hourCounter + 1;
          } else if (i == 10 &&
              campaignUser.scannedAt.toDate().hour >= 18 &&
              campaignUser.scannedAt.toDate().hour < 20) {
            hourCounter = hourCounter + 1;
          } else if (i == 11 &&
              campaignUser.scannedAt.toDate().hour >= 20 &&
              campaignUser.scannedAt.toDate().hour < 22) {
            hourCounter = hourCounter + 1;
          } else if (i == 12 && campaignUser.scannedAt.toDate().hour >= 22) {
            hourCounter = hourCounter + 1;
          }
        }
      }
      HourChart item = HourChart(counter: hourCounter, hour: i.toString());
      _hourData.add(item);
    }

    _chartHourData.add(charts.Series(
      id: 'Hours',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      data: _hourData,
      domainFn: (HourChart dayChart, _) => dayChart.hour,
      measureFn: (HourChart dayChart, _) => dayChart.counter,
      fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == false)
        ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: StreamBuilder<List<Campaign>>(
                stream: FirestoreService().getStoreCampaigns(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      switch (snapshot.hasData && snapshot.data.isNotEmpty) {
                        case true:
                          prepareDayData(snapshot.data);
                          prepareHourData(snapshot.data);
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0, top: 10.0),
                                  child: Text(
                                    'Kampanyaların en çok rağbet gördüğü günler',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Amatic',
                                        color: ColorConstants
                                            .instance.primaryColor),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: charts.BarChart(_chartDayData),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0, top: 20.0),
                                  child: Text(
                                    'Kampanyaların en çok rağbet gördüğü saatler',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Amatic',
                                        color: ColorConstants
                                            .instance.primaryColor),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: charts.BarChart(_chartHourData),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0,
                                      left: 20.0,
                                      bottom: 90.0,
                                      right: 20.0),
                                  child: Text(
                                    '** 1 = (00:00 - 02:00) , 2 = (02:00 - 04:00) , 3 = (04:00 - 06:00) , 4 = (06:00 - 08:00) , 5 = (08:00 - 10:00) , 6 = (10:00 - 12:00) , 7 = (12:00 - 14:00) , 8 = (14:00 - 16:00) , 9 = (16:00 - 18:00) , 10 = (18:00 - 20:00) , 11 = (20:00 - 22:00) , 12 = (22:00 - 00:00)',
                                    style: TextStyle(
                                        color: ColorConstants
                                            .instance.primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                          break;
                        default:
                          return NotFound(
                            notFoundIcon: FontAwesomeIcons.exclamationTriangle,
                            notFoundIconColor:
                                ColorConstants.instance.primaryColor,
                            notFoundIconSize: 60,
                            notFoundText:
                                'Şu an yayınlamış olduğunuz hiçbir kampanya bulunmamaktadır.',
                            notFoundTextColor:
                                ColorConstants.instance.hintColor,
                            notFoundTextSize: 20.0,
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
