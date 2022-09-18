import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solaris_mobile_app/widgets/metric_card_builder.dart';
import '../models/metric_line_chart.dart';
import '../models/network_helper.dart';
import '../models/record.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/get_local_json.dart';
import '../widgets/metric_line_chart_builder.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<MetricLineChart> futureLineChart;
  late Future<Record> record;
  late DateTime time;

  @override
  void initState() {
    super.initState();
    record = fetchMetricCardData();
    futureLineChart = fetchLineChartData();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        futureLineChart = fetchLineChartData();
      });
    });
  }

  Future<MetricLineChart> fetchLineChartData() async {
    // Map<String, dynamic> lineChartData =
    // json.decode(await getLocalLineChartJson());
    NetworkHelper networkHelper = NetworkHelper(
      Uri(
          scheme: 'https',
          host: 'solaris-web-server.herokuapp.com',
          path: 'records/list_of_recent_records/1'),
    ); // 'https://solaris-web-server.herokuapp.com'
    Map<String, dynamic> lineChartData = await networkHelper.getData();
    return MetricLineChart.fromJson(lineChartData);
  }

  Future<Record> fetchMetricCardData() async {
    time = DateTime.now();
    NetworkHelper networkHelper = NetworkHelper(
      Uri(
          scheme: 'https',
          host: 'solaris-web-server.herokuapp.com',
          path: 'records/most_recent/1'),
    ); // 'https://solaris-web-server.herokuapp.com'
    // Map<String, dynamic> data = json.decode(await getLocalMetricCardJson());
    Map<String, dynamic> data = await networkHelper.getData();
    return Record.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kThemeOffWhiteColor,
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'solaris',
                      style: kDashboardLogoTextStyle,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'Metrics',
                            style: kDashboardHeadingTextStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '(refreshed at ${currentDayFormatter.format(time)})',
                              style: kMetricsHeadingTextStyle,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                record = fetchMetricCardData();
                                time = DateTime.now();
                              });
                            },
                            splashRadius: 20,
                            icon: const Icon(
                              Icons.refresh,
                              size: 25.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  MetricCardBuilder(
                    futureRecord: record,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  MetricLineChartBuilder(
                    futureLineChart: futureLineChart,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
