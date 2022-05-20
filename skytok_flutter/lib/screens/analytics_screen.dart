import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/app_time.dart';
import 'package:skytok_flutter/services/api_requests.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _getAnalytics();
  }

  int percentMale = 0;
  int percentFemale = 0;
  int percentDiverse = 0;
  int followersCount = 0;
  List<AppTime> appTimes = [];

  int maxDuration = 0;

  _getAnalytics() async {
    var response = await Api().getAnalytics(context);
    var followerObjResponse = response['followerObj'];
    followersCount = int.parse(followerObjResponse['followersCount']);
    percentMale = followerObjResponse['percentMale'];
    percentFemale = followerObjResponse['percentFemale'];
    percentDiverse = followerObjResponse['percentDivers'];
    Iterable appTimeList = response['appTime'];
    appTimes = appTimeList.map((appTime) => AppTime.fromJson(appTime)).toList();
    for (var i = 0; i < appTimes.length; i++) {
      if (appTimes[i].duration > maxDuration) {
        maxDuration = appTimes[i].duration;
      }
      spots.add(
        FlSpot(i.toDouble(), appTimes[i].duration.toDouble()),
      );
    }
    setState(() {});
  }

  List<PieChartSectionData> pieChartData = [];
  List<FlSpot> spots = [];

  @override
  Widget build(BuildContext context) {
    pieChartData.clear();
    pieChartData.add(PieChartSectionData(
        color: Colors.blue, value: percentMale.toDouble(), title: 'Male'));
    pieChartData.add(PieChartSectionData(
        color: Colors.red, value: percentFemale.toDouble(), title: "Female"));

    return Scaffold(
        appBar: AppBar(
          title: Text('Analytics'),
        ),
        body: Column(children: [
          Container(
            height: 100,
            child: PieChart(
              PieChartData(
                  sections: pieChartData,
                  borderData: FlBorderData(show: false, border: Border())),
              swapAnimationDuration: Duration(milliseconds: 150), // Optional

              // swapAnimationCurve: Curves.linear, // Optional
            ),
          ),
          SizedBox(height: 10),
          Container(
              height: 400,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: appTimes.length.toDouble(),
                  minY: 0,
                  maxY: maxDuration.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                    ),
                  ],
                  // read about it in the LineChartData section
                ),
                swapAnimationDuration: Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ))
        ]));
  }
}
