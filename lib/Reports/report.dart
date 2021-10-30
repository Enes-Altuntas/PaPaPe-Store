import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papape_store/Components/not_found.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/camapign_model.dart';
import 'package:papape_store/Models/chart_day_model.dart';
import 'package:papape_store/Services/firestore_service.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key key}) : super(key: key);

  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  bool isLoading = false;
  List<DayChart> _dayData = [];
  List<charts.Series<DayChart, String>> _chartData = [];

  void prepareData(List<Campaign> campaigns) {
    _dayData = [];
    _chartData = [];

    for (var i = 1; i <= 7; i++) {
      int dayCounter = 0;
      for (var element in campaigns) {
        if (element.createdAt.toDate().weekday == i) {
          dayCounter = dayCounter + element.campaignUsers.length;
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

    _chartData.add(charts.Series(
      id: 'Days',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      data: _dayData,
      domainFn: (DayChart dayChart, _) => dayChart.day,
      measureFn: (DayChart dayChart, _) => dayChart.counter,
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
                          prepareData(snapshot.data);
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0, top: 10.0),
                                  child: Text(
                                    'Kampanyaların en çok rağbet gördüğü günler',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.bebasNeue(
                                        fontSize: 20.0,
                                        color: ColorConstants
                                            .instance.primaryColor),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: charts.BarChart(_chartData),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0, top: 20.0),
                                  child: Text(
                                    'Kampanyaların en çok rağbet gördüğü saatler',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.bebasNeue(
                                        fontSize: 20.0,
                                        color: ColorConstants
                                            .instance.primaryColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 80.0),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: charts.BarChart(_chartData),
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
